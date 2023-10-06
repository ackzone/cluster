provider "aws" {
  region = local.region
}

locals {
  region = "us-west-2"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ackzone"
  cidr = "10.5.0.0/16"

  azs         = slice(data.aws_availability_zones.available.names, 0, 2)


  private_subnets  = ["10.5.1.0/24", "10.5.2.0/24"]
  public_subnets = ["10.5.101.0/24", "10.5.102.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false

  manage_default_security_group = true
  default_security_group_egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]

}