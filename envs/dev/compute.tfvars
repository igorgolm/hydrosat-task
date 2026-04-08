project_name           = "hydrosat-taskg"
environment            = "dev"
region_short           = "eun1"
networking_state_key   = "envs/dev/networking/terraform.tfstate"
terraform_state_bucket = "hydrosat-taskg-terraform-state"
kubernetes_version     = "1.35"
public_access_cidrs    = ["<your_ip>/32"]
eks_managed_node_groups = {
  primary = {
    name           = "primary"
    min_size       = 1                     # Min available nodes
    max_size       = 4                     # Max available nodes
    desired_size   = 2                     # Actual node count
    ami_type       = "BOTTLEROCKET_x86_64" # Minimal AWS managed AMI for security reasons
    instance_types = ["t3.small"]
    capacity_type  = "SPOT"
  }
}
service_ipv4_cidr = "172.20.0.0/16" # 65534 IPs
additional_tags = {
  Stack = "compute"
}
