data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.networking_state_key
    region = var.region
  }
}

locals {
  combined_tags = merge(var.common_tags, var.additional_tags)
}

module "eks" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks?ref=6bac707d5496f4b494ce8bf63bfc8d245aead592" # 21.17.1

  name               = "${var.project_name}-${var.environment}-${var.region_short}-eks"
  kubernetes_version = var.kubernetes_version

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.public_access_cidrs

  vpc_id                   = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.networking.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.networking.outputs.public_subnets

  eks_managed_node_groups = var.eks_managed_node_groups

  service_ipv4_cidr = var.service_ipv4_cidr

  # Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns    = {}
    kube-proxy = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    vpc-cni = {
      before_compute = true
      addon_version  = "v1.21.1-eksbuild.7"
    }
    kube-state-metrics = {} # Exposes metrics about the state of Kubernetes objects (Pods, Deployments, Nodes, etc.)
    metrics-server     = {} # Collects and exposes resource usage metrics from Kubelets and the Kubernetes control plane.
  }

  tags = local.combined_tags
}

## EBS CSI Pod Identity
module "aws_ebs_csi_pod_identity" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks-pod-identity?ref=776d089cf8b13dbff25e32e78272f8f693f5cb29" # 2.7.0

  name = "${var.project_name}-${var.environment}-${var.region_short}-ebs-csi"

  attach_aws_ebs_csi_policy = true

  associations = {
    this = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = local.combined_tags
}

## AWS Load Balancer Controller\
# https://github.com/kubernetes-sigs/aws-load-balancer-controller
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "3.2.1"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller-sa"
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.networking.outputs.vpc_id
  }

  depends_on = [module.eks, module.aws_lb_controller_pod_identity]
}

## Load Balancer Controller Pod Identity
module "aws_lb_controller_pod_identity" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks-pod-identity?ref=776d089cf8b13dbff25e32e78272f8f693f5cb29" # 2.7.0

  name = "${var.project_name}-${var.environment}-${var.region_short}-lb-id"

  attach_aws_lb_controller_policy = true

  associations = {
    this = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller-sa"
    }
  }
  tags = local.combined_tags
}

## VPC CNI Pod Identity
module "aws_vpc_cni_ipv4_pod_identity" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks-pod-identity?ref=776d089cf8b13dbff25e32e78272f8f693f5cb29" # 2.7.0

  name = "${var.project_name}-${var.environment}-${var.region_short}-vpc-cni"

  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true

  associations = {
    this = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-node"
    }
  }

  tags = local.combined_tags
}
