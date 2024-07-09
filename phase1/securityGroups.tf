resource "aws_security_group" "eks_cluster_sg_pep" {
  name        = "eks-cluster-sg-pep"
  description = "EKS Cluster security group"
  vpc_id      = aws_vpc.vpc_pep.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_nodes_inbound" {
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_sg_pep.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_nodes_outbound" {
  type              = "egress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_sg_pep.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_cluster_api_server" {
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  security_group_id         = aws_security_group.eks_cluster_sg_pep.id
  source_security_group_id  = aws_security_group.eks_cluster_sg_pep.id
}