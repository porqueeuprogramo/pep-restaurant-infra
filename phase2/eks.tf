locals {
  role_arn = data.terraform_remote_state.terraform-state-phase1.outputs.iam_role_arn_output
  role_name = data.terraform_remote_state.terraform-state-phase1.outputs.iam_role_name_output
  subnet_a_pep_id = data.terraform_remote_state.terraform-state-phase1.outputs.subnet_a_pep_output
  subnet_b_pep_id = data.terraform_remote_state.terraform-state-phase1.outputs.subnet_b_pep_output
  eks_cluster_sg_pep_id = data.terraform_remote_state.terraform-state-phase1.outputs.eks_cluster_sg_pep_id_output
  iam_role_node_group_arn = data.terraform_remote_state.terraform-state-phase1.outputs.iam_role_node_group_arn_output
  iam_role_node_group_name = data.terraform_remote_state.terraform-state-phase1.outputs.iam_role_node_group_name_output
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = local.role_name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = local.role_name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = local.iam_role_node_group_name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = local.iam_role_node_group_name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = local.iam_role_node_group_name
}

resource "aws_eks_cluster" "eks_cluster_pep" {
  name     = "eks_cluster_pep"
  role_arn = local.role_arn

  vpc_config {
    subnet_ids = [local.subnet_a_pep_id, local.subnet_b_pep_id]
    security_group_ids = [local.eks_cluster_sg_pep_id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}

resource "aws_eks_node_group" "eks_node_group_pep" {
  cluster_name    = aws_eks_cluster.eks_cluster_pep.name
  node_group_name = "eks_node_group_pep"
  node_role_arn   = local.iam_role_node_group_arn
  subnet_ids      = [local.subnet_a_pep_id, local.subnet_b_pep_id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  ami_type = "AL2_x86_64"
}

resource "aws_subnet_tag" "subnet_a_cluster_tag" {
  subnet_id = local.subnet_a_pep_id

  key   = "kubernetes.io/cluster/eks_cluster_pep"
  value = "shared"
}

resource "aws_subnet_tag" "subnet_a_internal_elb_tag" {
  subnet_id = local.subnet_a_pep_id

  key   = "kubernetes.io/role/internal-elb"
  value = "1"
}

resource "aws_subnet_tag" "subnet_b_cluster_tag" {
  subnet_id = local.subnet_b_pep_id

  key   = "kubernetes.io/cluster/eks_cluster_pep"
  value = "shared"
}

resource "aws_subnet_tag" "subnet_b_internal_elb_tag" {
  subnet_id = local.subnet_b_pep_id

  key   = "kubernetes.io/role/internal-elb"
  value = "1"
}

