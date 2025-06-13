provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "eks-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_dns_hostnames   = true
  
  # Let the module create a new EIP instead of using an existing one
  reuse_nat_ips          = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.3"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  # Ensure cluster has proper networking configuration
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Configure node groups with improved networking settings
  eks_managed_node_groups = {
    default = {
      desired_size   = var.desired_capacity
      max_size       = var.max_capacity
      min_size       = var.min_capacity
      instance_types = [var.node_instance_type]
      
      # Add proper subnet configuration
      subnet_ids     = module.vpc.private_subnets
      
      # Add proper IAM configuration
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }

  enable_irsa = true
  
  # Add dependency on VPC to ensure proper order
  depends_on = [module.vpc]
}