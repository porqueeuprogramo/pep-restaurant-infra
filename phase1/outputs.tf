output "aws_security_group_db_id_output" {
  value = aws_security_group.db.id
}

output "aws_security_group_eks_id_output" {
  value = aws_security_group.eks.id
}

output "vpc_private_subnets_output" {
  value = module.vpc.private_subnets
}

output "vpc_public_subnets_output" {
  value = module.vpc.public_subnets
}

output "vpc_intra_subnets_output" {
  value = module.vpc.intra_subnets
}

output "vpc_id_output" {
  value = module.vpc.vpc_id
}