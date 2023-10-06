# aws-ec2-instance

This module creates the following:

- an Ubuntu EC2 instance with Tailscale installed via a userdata script
- a Tailnet device key to authenticate the instance to your Tailnet

This module allows configuration of [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh/) and
[Tailscale Subnet Routers and Exit Nodes](https://tailscale.com/kb/1019/subnets/) via module variables. See
[variables.tf](variables.tf) for the available options.

## Considerations

- Routes and Exit Nodes must still be approved in the Tailscale Admin Console. The code can be updated to use [Auto Approvers for routes](https://tailscale.com/kb/1018/acls/#auto-approvers-for-routes-and-exit-nodes) if this is configured in your ACLs.
- Consider using [ACL tags](https://tailscale.com/kb/1068/acl-tags/) to facilitate Auto Approvers as above and to prevent [auth key expiry](https://tailscale.com/kb/1068/acl-tags/#key-expiry-for-tagged-devices).

## Example Usage

See the `examples` folder for complete examples.

```hcl
module "tailscale_aws_ec2" {
  source = "../../"

  subnet_id = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    module.vpc.default_security_group_id,
  ]

  instance_type = "t4g.micro"
  instance_tags = {
    Name = "tailscale"
  }

  # Tailscale-specific configuration
  tailscale_hostname = "tailscale"
  tailscale_device_tags = [
    "tag:auto-approve",
  ]
  tailscale_ssh = true
  tailscale_advertise_exit_node = true
  tailscale_advertise_routes    = [module.vpc.vpc_ipv6_cidr_block]
}
```

