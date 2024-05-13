provider "aws" {
  region  = "eu-west-2"  # Specify your desired AWS region
  profile = "pep"
  # Add any other required configuration settings here
}

resource "aws_vpc" "vpc_pep" {
  cidr_block       = "10.0.0.0/24"  # Specify the CIDR block for your VPC
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-1-pep"  # Specify a name for your VPC
  }
}

resource "aws_subnet" "subnet_a_pep" {
  vpc_id            = aws_vpc.vpc_pep.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "subnet_b_pep" {
  vpc_id            = aws_vpc.vpc_pep.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "eu-west-2b"
}

resource "aws_eks_cluster" "eks_cluster_pep" {
  name     = "eks_cluster_pep"
  role_arn = aws_iam_role.iam_role_pep.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet_a_pep.id, aws_subnet.subnet_b_pep.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_role_pep" {
  name               = "eks-cluster-pep"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_role_pep.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.iam_role_pep.name
}

