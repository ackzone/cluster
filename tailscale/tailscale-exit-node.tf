data "aws_availability_zones" "available" {}

locals {
  exit_node_tags = {
    Name = "exit-node-${basename(path.cwd)}"
  }

  subnet_tags = {
    Name = "subnet-router-${basename(path.cwd)}"
  }
}

module "tailscale_aws_exit_node" {
  source = "../modules/tailscale-node"

  subnet_ids = module.vpc.public_subnets

  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  instance_type = "t4g.small"
  instance_tags = local.exit_node_tags

  depends_on = [module.vpc.aws_nat_gateway]

  # Tailscale-specific configuration
  tailscale_hostname = "exit-node"
  tailscale_device_tags = [
   "tag:auto-approve",
  ]
  tailscale_ssh                 = true
  tailscale_advertise_exit_node = true
}

module "tailscale_aws_subnet_router" {
  source = "../modules/tailscale-node"
  subnet_ids = module.vpc.private_subnets

  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  instance_type = "t4g.small"
  instance_tags = local.subnet_tags

  # Tailscale-specific configuration
  tailscale_hostname = "subnet-router"
  tailscale_device_tags = [
    "tag:auto-approve",
  ]
  tailscale_advertise_routes = [module.vpc.vpc_cidr_block]
  tailscale_ssh                 = true
}
