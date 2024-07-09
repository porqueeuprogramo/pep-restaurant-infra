output "iam_role_arn_output" {
  value = aws_iam_role.iam_role_pep.arn
}

output "iam_role_name_output" {
  value = aws_iam_role.iam_role_pep.name
}

output "subnet_a_pep_output" {
  value = aws_subnet.subnet_a_pep.id
}

output "subnet_b_pep_output" {
  value = aws_subnet.subnet_b_pep.id
}

output "eks_cluster_sg_pep_output" {
  value = aws_security_group.eks_cluster_sg_pep.id
}

output "iam_role_node_group_arn_output" {
  description = "The name of the IAM role for the node group"
  value       = aws_iam_role.iam_role_node_group.arn
}