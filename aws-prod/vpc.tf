################################################################################
# VPC MODULE                                                                   #
# This module will create 3 public and private subnets in 3 different AZs      #
# It will also set some needed tags for EKS to work                            #
################################################################################

module "vpc" {
  source            = "terraform-aws-modules/vpc/aws"
  version           = "2.70.0"

  name               = "production-vpc"
  cidr               = local.vpc_cidr
  azs                = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets    = local.private_subnets_cidrs
  public_subnets     = local.public_subnets_cidrs
  enable_ipv6        = false

  enable_nat_gateway = true # provisions a nat gateway for private subnets
  single_nat_gateway = true

  # Tags
  public_subnet_tags = {
    "Name"                            : "production-public-subnet"
    "kubernetes.io/role/elb"          : "1"
    "kubernetes.io/cluster/eks"       : "shared"
  }

  private_subnet_tags = {
    "Name"                            : "production-private-subnet"
    "kubernetes.io/role/internal-elb" : "1"
  }

  tags = {
    Owner       = "Mauricio Bahamonde"
    Environment = "production-poc"
  }

  vpc_tags = {
    Name = "production-vpc"
  }
}
