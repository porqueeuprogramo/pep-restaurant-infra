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

resource "aws_db_instance" "pep-restaurant-ms-manager-db" {
  identifier            = local.pep-restaurant-ms-manager-id
  allocated_storage     = 200
  engine                = "postgres"
  engine_version        = "12"
  instance_class        = "db.t3.medium"
  db_name               = local.pep-restaurant-ms-manager-db-name
  username              = local.pep-restaurant-ms-manager-db-username
  password              = random_password.pep-ms-restaurant-db-password.result

  # Enable IAM database authentication
  iam_database_authentication_enabled = true

  # Set the VPC security group IDs (example assumes you have a security group defined)
  vpc_security_group_ids = [local.aws_security_group_db_id]

  # Specify the subnet group where the DB instance will be deployed
  db_subnet_group_name = local.vpc_private_subnets

  # Backup and maintenance window configurations
  backup_retention_period = 7
  maintenance_window      = "Mon:00:00-Mon:03:00"

  # Optionally enable deletion protection
  deletion_protection = false

  # Tags for identification
  tags = {
    Name = "pep-restaurant-ms-manager-db"
    Environment = "Dev"
  }
}