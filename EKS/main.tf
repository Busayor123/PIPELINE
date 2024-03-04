module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "EKS-vpc"
  cidr                 = var.vpc_cidr
  private_subnets      = var.private_subnets
  public_subnet_names   =var.public_subnets
  enable_dns_hostnames = true
  azs                  = data.aws_availability_zones.AZS.names

 tags = {
   
                                          
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
 }

 public_subnet_tags = {

    "kubernetes.io/cluster/" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
 private_subnet_tags =  {

    "kubernetes.io/cluster/" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
 }
 


module "EKS_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "EKS sg"
  description = "Security group for EKS"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "EKS-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = "vpc-1234556abcdef"
  subnet_ids               = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::123456789012:role/something"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
  

output "public_ip" {
  value = module.ec2_instance.public_ip
}



