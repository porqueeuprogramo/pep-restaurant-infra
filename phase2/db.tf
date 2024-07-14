# https://github.com/terraform-aws-modules/terraform-aws-rds
module "pep-restaurant-ms-manager-db" {
  source  = "../plugins/terraform-aws-modules/terraform-aws-rds-2.24.0"
  identifier                          = local.pep-restaurant-ms-manager-id
  engine                              = "postgres"
  engine_version                      = "12"
  instance_class                      = "db.t3.medium"
  allocated_storage                   = 200
  name                                = local.pep-restaurant-ms-manager-db-name
  username                            = local.pep-restaurant-ms-manager-db-username
  password                            = random_password.pep-ms-restaurant-db-password.result
  port                                = local.pep-restaurant-ms-manager-db-port
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [local.aws_security_group_db_id, local.aws_security_group_eks_id_output]
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  backup_window                       = "03:00-06:00"
  backup_retention_period             = 7
  tags                                = local.tags
  monitoring_role_arn                 = local.pep_db_enhanced_monitoring_arn_output
  monitoring_interval                 = "30"
  subnet_ids                          = local.vpc_private_subnets
  family                              = "postgres12"
  major_engine_version                = "12"
  snapshot_identifier                 = null
  final_snapshot_identifier           = local.pep-restaurant-ms-manager-id
  performance_insights_enabled        = true
  deletion_protection                 = true
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  storage_encrypted                   = true
  copy_tags_to_snapshot               = true
}

resource "random_password" "pep-ms-restaurant-db-password" {
  length  = 16
  special = true
}