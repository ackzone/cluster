terraform {
  backend "s3" {
    bucket = "cluster.ack.zone-terraform"
    key    = "terraform"
    region = "us-west-2"
  }
}
