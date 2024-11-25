module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-efs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.efs_csi_driver_role.arn
    }
  }

  eks_managed_node_groups = {
    autonmis_eks_node = {
      instance_types = ["t3.xlarge"]

      ami_type     = "AL2_x86_64"
      min_size     = 1
      max_size     = 4
      desired_size = 3
    }
  }

  depends_on = [module.vpc]
}
