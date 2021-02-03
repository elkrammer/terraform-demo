################################################################################
# EKS Module                                                                   #
# This module sets up an EKS cluster.                                          #
# To save costs it uses EC2 Spot Instances                                     #
################################################################################

# Retrieve information about the current EKS Cluster.
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# kubernetes provider configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "14.0.0"
  cluster_name    = local.eks_cluster_name
  cluster_version = local.eks_cluster_version
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  map_roles       = local.eks_map_roles
  enable_irsa     = true

  worker_groups_launch_template = [
    {
      name                    = "spot-main"
      override_instance_types = [local.eks_instance_type]
      spot_price              = local.eks_spot_price
      spot_instance_pools     = 1
      asg_max_size            = 1
      asg_desired_capacity    = 1
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = false
    },
  ]
}
