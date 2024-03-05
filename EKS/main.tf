
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


module "EKS" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "EKS-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true



  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  
  
  eks_managed_node_groups = {
    nodes = {
    min_size = 1
    max_size = 3
    desired_size = 2
    
     instance_types = ["t2-small"]


    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
  





