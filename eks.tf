resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "EKS Cluster security group"
  vpc_id      = aws_vpc.vpc_pep.id

  // Allow inbound traffic from the EKS control plane on port 443 (HTTPS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "18.130.0.0/17",
      "35.178.0.0/16",
      "52.56.0.0/16",
      "52.95.255.0/24"
    ]
  }

  // Allow all traffic within the security group (nodes need to communicate with each other)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  // Allow outbound traffic to the internet for updates and external communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_nodes_inbound" {
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_nodes_outbound" {
  type              = "egress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_cluster_api_server" {
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  security_group_id         = aws_security_group.eks_cluster_sg.id
  source_security_group_id  = aws_security_group.eks_cluster_sg.id
}

resource "aws_eks_cluster" "eks_cluster_pep" {
  name     = "eks_cluster_pep"
  role_arn = aws_iam_role.iam_role_pep.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet_a_pep.id, aws_subnet.subnet_b_pep.id]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
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
  node_role_arn   = aws_iam_role.iam_role_node_group.arn
  subnet_ids      = [aws_subnet.subnet_a_pep.id, aws_subnet.subnet_b_pep.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  ami_type = "AL2_x86_64"
}