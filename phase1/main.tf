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
    key    = "phase-1/terraform.tfstate"
  }
}