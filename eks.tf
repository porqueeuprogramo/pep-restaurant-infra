resource "aws_eks_cluster" "eks_cluster_pep" {
  name     = "eks_cluster_pep"
  role_arn = aws_iam_role.iam_role_pep.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet_a_pep.id, aws_subnet.subnet_b_pep.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "eks_node_group_pep" {
  cluster_name    = aws_eks_cluster.eks_cluster_pep.name
  node_group_name = "eks_node_group_pep"
  node_role_arn   = aws_iam_role.iam_role_pep.arn
  subnet_ids      = [aws_subnet.subnet_a_pep.id, aws_subnet.subnet_b_pep.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  remote_access {
    ec2_ssh_key = "pep_eks_key"
  }
}