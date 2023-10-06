terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.53.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.13.7"
    }
  }
}


