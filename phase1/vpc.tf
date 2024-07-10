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

  tags = {
    "kubernetes.io/cluster/eks_cluster_pep" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

resource "aws_subnet" "subnet_b_pep" {
  vpc_id            = aws_vpc.vpc_pep.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "eu-west-2b"

  tags = {
    "kubernetes.io/cluster/eks_cluster_pep" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}