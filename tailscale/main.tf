terraform {
  backend "s3" {
    bucket = "cluster.ack.zone-terraform"
    key    = "tailscale" 
    region = "us-west-2"
  }
}
