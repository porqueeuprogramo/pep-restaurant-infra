resource "random_password" "pep-ms-restaurant-db-password" {
  length  = 16
  special = false
}

#resource "aws_ssm_parameter" "pep-restaurant-ms-manager-db-password" {
#  name        = "/pep/ms/manager/database/db-password"
#  description = "DB Password for pep-restaurant-ms-manager"
#  type        = "SecureString"
#  value       = random_password.pep-ms-restaurant-db-password.result
#  tags        = local.tags
#  lifecycle {
#    ignore_changes = [
#      value
#    ]
#  }
#}

# Data source to retrieve a single subnet in eu-west-2a
data "aws_subnet" "az_a" {
  vpc_id            = local.vpc_id
  availability_zone = "eu-west-2a"

   filter {
     name   = "tag:Name"
     values = ["vpc_pep-private-eu-west-2a"]
   }
}

# Data source to retrieve a single subnet in eu-west-2b
data "aws_subnet" "az_b" {
  vpc_id            = local.vpc_id
  availability_zone = "eu-west-2b"

   filter {
     name   = "tag:Name"
     values = ["vpc_pep-private-eu-west-2b"]
   }
}

# Use the subnet IDs retrieved from the data sources
resource "aws_db_subnet_group" "aws_db_subnet_group" {
  name       = "aws_db_subnet_group"
  subnet_ids = [
    data.aws_subnet.az_a.id,
    data.aws_subnet.az_b.id,
  ]

  tags = {
    Name = "example-db-subnet-group"
  }
}


# https://github.com/terraform-aws-modules/terraform-aws-rds
module "pep-restaurant-ms-manager-db" {
  source                              = "../plugins/terraform-aws-modules/terraform-aws-rds-6.7.0"
  identifier                          = local.pep-restaurant-ms-manager-id
  engine                              = "postgres"
  engine_version                      = "12"
  instance_class                      = "db.t3.medium"
  allocated_storage                   = 200
  db_name                             = local.pep-restaurant-ms-manager-db-name
  username                            = local.pep-restaurant-ms-manager-db-username
  password                            = random_password.pep-ms-restaurant-db-password.result
  port                                = local.pep-restaurant-ms-manager-db-port
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = aws_db_subnet_group.aws_db_subnet_group.subnet_ids
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  backup_retention_period             = 7
  tags                                = local.tags
  monitoring_role_arn                 = local.pep_db_enhanced_monitoring_arn
  monitoring_interval                 = "30"
  subnet_ids                          = local.vpc_private_subnets
  family                              = "postgres12"
  major_engine_version                = "12"
  snapshot_identifier                 = null
  performance_insights_enabled        = true
  deletion_protection                 = true
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  storage_encrypted                   = true
  copy_tags_to_snapshot               = true
}