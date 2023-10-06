variable "subnet_ids" {
  type = list(string)
}
variable "vpc_security_group_ids" {
  type = set(string)
}

variable "instance_type" {
  type = string
}
variable "instance_tags" {
  type = map(string)
}
variable "instance_user_data_replace_on_change" {
  type    = bool
  default = true
}
variable "instance_key_name" {
  type    = string
  default = ""
}
variable "instance_metadata_options" {
  type = map(string)
  # IMDSv2 - not required, but recommended
  default = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

#
# Tailscale-specific configuration
#
variable "tailscale_device_tags" {
  description = "ACL tags to assign to the device"
  type        = set(string)
  default     = []
}
variable "tailscale_hostname" {
  description = "Machine name to assign to the device"
  type        = string
}
variable "tailscale_ssh" {
  description = "Boolean flag to enable Tailscale SSH"
  type        = bool
  default     = true
}
variable "tailscale_advertise_exit_node" {
  description = "Boolean flag to enable Tailscale Exit Node"
  type        = bool
  default     = false
}
variable "tailscale_advertise_routes" {
  description = "List of subnets to advertise"
  type        = set(string)
  default     = []
}

