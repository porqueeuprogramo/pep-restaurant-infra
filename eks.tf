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
  cluster_name    = aws_eks_cluster.eks_cluster_pep
  node_group_name = "eks_node_group_pep"
  node_role_arn   = aws_iam_role.iam_role_pep
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

resource "aws_security_group" "eks_aws_security_group_pep" {
  name        = "eks_aws_security_group_pep"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc_pep

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

resource "aws_launch_configuration" "eks_aws_launch_configuration_pep" {
  name          = "eks_aws_launch_configuration_pep"
  image_id      = "ami-12345678"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"

  security_groups = [
    aws_security_group.eks_aws_security_group_pep
  ]

  key_name = "my-key"  # Replace with your key pair name

  lifecycle {
    create_before_destroy = true
  }
}
#aws ssm get-parameters --names /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id --region eu-west-2 --query "Parameters[0].Value" --output text

resource "aws_autoscaling_group" "eks_aws_autoscaling_group_pep" {
  launch_configuration = aws_launch_configuration.example.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.subnet_a_pep.id, aws_subnet.subnet_b_pep.id]

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.eks_cluster_pep}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "example-ec2-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}