variable "role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "role_name" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "subnet_a_pep_id" {
  description = "Subnet a pep id"
  type        = string
}

variable "subnet_b_pep_id" {
  description = "Subnet b pep id"
  type        = string
}

variable "eks_cluster_sg_pep_id" {
  description = "Eks Security Group pep id"
  type        = string
}

variable "iam_role_node_group_arn" {
  description = "The ARN of the IAM role for the EKS cluster Node Group"
  type        = string
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = var.role_name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = var.role_name
}

resource "aws_eks_cluster" "eks_cluster_pep" {
  name     = "eks_cluster_pep"
  role_arn = var.role_arn

  vpc_config {
    subnet_ids = [var.subnet_a_pep_id, var.subnet_a_pep_id]
    security_group_ids = [var.eks_cluster_sg_pep_id]
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
  node_role_arn   = var.iam_role_node_group_arn
  subnet_ids      = [var.subnet_a_pep_id, var.subnet_b_pep_id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  ami_type = "AL2_x86_64"
}