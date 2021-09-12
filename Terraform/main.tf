terraform {
  	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "3.57.0"
		}

		kubernetes = {
			source = "hashicorp/kubernetes"
			version = "2.4.1"
		}
  }
}

provider "aws" {
	region = "us-east-1"
}

resource "aws_ecr_repository" "combined-task-repository-backend-image" {
	name                 = "bakirbs-combined-task-image-repository-backend-image"
	image_tag_mutability = "MUTABLE"

	image_scanning_configuration {
		scan_on_push = false
	}

	tags = {
		"Item" = "bakirbs-combined-task-image-repository"
		"Task" = "trello-combined"
	}
}

# data "aws_eks_cluster" "cluster" {
# 	name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
# 	name = module.eks.cluster_id
# }

# provider "kubernetes" {
# 	host                   = data.aws_eks_cluster.cluster.endpoint
# 	cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
# 	token                  = data.aws_eks_cluster_auth.cluster.token
# }

data "aws_availability_zones" "available" {}

locals {
	cluster_name = "bakirbs-combined-task-cluster"
}

module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = ">= 2.58.0"

	name                 = "bakirbs-combined-task-k8s-vpc"
	cidr                 = "172.16.0.0/16"
	azs                  = data.aws_availability_zones.available.names
	private_subnets      = ["172.16.1.0/24"] # , "172.16.2.0/24", "172.16.3.0/24"]
	public_subnets       = ["172.16.4.0/24"] # , "172.16.5.0/24", "172.16.6.0/24"]
	enable_nat_gateway   = true
	single_nat_gateway   = true
	enable_dns_hostnames = true

	public_subnet_tags = {
		"kubernetes.io/cluster/${local.cluster_name}" = "shared"
		"kubernetes.io/role/elb"                      = "1"
		Task = "trello-combined"
		Item = "bakirbs-combined-task-k8s-public-subnet"
	}

	private_subnet_tags = {
		"kubernetes.io/cluster/${local.cluster_name}" = "shared"
		"kubernetes.io/role/internal-elb"             = "1"
		Task = "trello-combined"
		Item = "bakirbs-combined-task-k8s-private-subnet"
	}
	tags = {
		Task = "trello-combined"
		Item = "bakirbs-combined-task-k8s-vpc"
  	}
}

module "eks" {
	source  = "terraform-aws-modules/eks/aws"
	version = "17.18.0"

	cluster_name    = "${local.cluster_name}"
	cluster_version = "1.17"
	subnets         = module.vpc.private_subnets

	vpc_id = module.vpc.vpc_id

	node_groups = {
		first = {
			desired_capacity = 1
			max_capacity     = 3
			min_capacity     = 1

			instance_types = ["t2.micro"]
			disk_size = 8
		}
	}

	workers_additional_policies = ["AmazonEC2ContainerRegistryReadOnly"]

	write_kubeconfig   = true
	kubeconfig_output_path = "./"

	cluster_tags = {
		Task = "trello-combined"
		Item = "bakirbs-combined-task-k8s-cluster"
	}

	tags = {
		Task = "trello-combined"  
		Item = "bakirbs-combined-task-k8s-eks-item"
	}
}