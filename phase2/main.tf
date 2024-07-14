provider "aws" {
  region  = "eu-west-2"  # Specify your desired AWS region
  profile = "pep"
  # Add any other required configuration settings here
}

data "terraform_remote_state" "terraform-state-phase1" {
  backend  = "s3"
  config   = {
    bucket = "terraform-state-pep"
    region = "eu-west-2"
    key    = "phase1/terraform.tfstate"
  }
}

locals {
  pep-restaurant-ms-manager-id          = "pep-restaurant-ms-manager-id"
  pep-restaurant-ms-manager-db-name     = "PepRestaurantMsManagerDb"
  pep-restaurant-ms-manager-db-username = "porqueeuprogramo"
  pep-restaurant-ms-manager-db-port     = 5432
  aws_security_group_db_id              = data.terraform_remote_state.terraform-state-phase1.outputs.aws_security_group_db_id_output
  vpc_private_subnets                   = data.terraform_remote_state.terraform-state-phase1.outputs.vpc_private_subnets_output
  vpc_public_subnets_output             = data.terraform_remote_state.terraform-state-phase1.outputs.vpc_public_subnets_output
  vpc_intra_subnets_output              = data.terraform_remote_state.terraform-state-phase1.outputs.vpc_intra_subnets_output
  vpc_id_output                         = data.terraform_remote_state.terraform-state-phase1.outputs.vpc_id_output
  pep_db_enhanced_monitoring_arn_output = data.terraform_remote_state.terraform-state-phase1.outputs.pep_db_enhanced_monitoring_arn_output
  pep-restaurant-ms-manager-db-endpoint = replace("${module.pep-restaurant-ms-manager-db.this_db_instance_endpoint}", ":${module.pep-restaurant-ms-manager-db.this_db_instance_port}", "")
  tags = {
    Rds = "rds"
  }
}
