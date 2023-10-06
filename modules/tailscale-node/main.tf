data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "tailscale_tailnet_key" "subnet_router" {
  ephemeral     = true # TODO: change to false or make configurable
  preauthorized = true
  reusable      = true # allow the key to be used for multiple machines
  tags          = var.tailscale_device_tags
}

# resource "aws_instance" "tailscale_instance" {
#   ami           = data.aws_ami.ubuntu.image_id
#   instance_type = var.instance_type
#   key_name      = var.instance_key_name

#   vpc_security_group_ids = var.vpc_security_group_ids
#   subnet_id              = var.subnet_id
#   source_dest_check      = false

#   metadata_options {
#     http_endpoint = var.instance_metadata_options["http_endpoint"]
#     http_tokens   = var.instance_metadata_options["http_tokens"]
#   }

#   tags                        = var.instance_tags
#   user_data_replace_on_change = var.instance_user_data_replace_on_change
#   user_data                   = <<EOF
# #!/bin/bash

# # https://tailscale.com/kb/1187/install-ubuntu-2204/
# curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
# curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# apt update
# apt install -y tailscale

# ${var.tailscale_advertise_exit_node == true || length(var.tailscale_advertise_routes) > 0 ? local.ip_forwarding_script : ""}

# tailscale up \
#   --authkey=${tailscale_tailnet_key.subnet_router.key} \
#   ${join(" ", local.tailscale_arguments)}
#     EOF
# }

resource "aws_launch_template" "tailscale_template" {
  name_prefix   = "tailscale-node-"
  image_id           = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type
  key_name      = var.instance_key_name

  vpc_security_group_ids = var.vpc_security_group_ids

  metadata_options {
    http_endpoint = var.instance_metadata_options["http_endpoint"]
    http_tokens   = var.instance_metadata_options["http_tokens"]
  }

  tags = var.instance_tags

  user_data = base64encode(<<EOF
#!/bin/bash

# https://tailscale.com/kb/1187/install-ubuntu-2204/
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt update
apt install -y tailscale

${var.tailscale_advertise_exit_node == true || length(var.tailscale_advertise_routes) > 0 ? local.ip_forwarding_script : ""}

tailscale up \
  --authkey=${tailscale_tailnet_key.subnet_router.key} \
  ${join(" ", local.tailscale_arguments)}
    EOF
  )
}

resource "aws_autoscaling_group" "tailscale_asg" {
  for_each = toset(var.subnet_ids) # Assuming `var.subnet_ids` is a list of subnet IDs

  launch_template {
    id      = aws_launch_template.tailscale_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [each.key]  # Use each subnet id for each ASG
  max_size            = 1          # Assuming one instance per subnet
  min_size            = 1
  desired_capacity    = 1

  tag {
    key                 = "Name"
    value               = "Tailscale-Node"
    propagate_at_launch = true
  }
}

locals {

  ip_forwarding_script = <<EOF
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf
  EOF

  tailscale_arguments = [
    "--hostname=${var.tailscale_hostname}",
    var.tailscale_ssh == true ? "--ssh" : "",
    var.tailscale_advertise_exit_node == true ? "--advertise-exit-node" : "",
    length(var.tailscale_advertise_routes) > 0 ? "--advertise-routes=${join(",", var.tailscale_advertise_routes)}" : "",
  ]
}

