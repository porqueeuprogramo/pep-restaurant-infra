provider "aws" {
  region  = "eu-west-2"  # Specify your desired AWS region
  profile = "pep"
  # Add any other required configuration settings here
}

module "phase1" {
  source = "./phase1"
}

module "phase2" {
  source   = "./phase2"
  role_arn = module.phase1.iam_role_arn_output
  role_name = module.phase1.iam_role_name_output
  subnet_a_pep_id = module.phase1.subnet_a_pep_output
  subnet_b_pep_id = module.phase1.subnet_b_pep_output
  eks_cluster_sg_pep_id = module.phase1.eks_cluster_sg_pep_output
  iam_role_node_group_arn = module.phase1.iam_role_node_group_arn_output
}

