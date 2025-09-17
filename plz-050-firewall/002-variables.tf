#================================================================================================
# Environment Configuration Values (e.g. dev.tfvars)
#================================================================================================
variable "subscription_id" {
  description = "The subscription id."
  type        = string
}
variable "location" {
  description = "The location to deploy resources."
  type        = string
}
variable "enable_telemetry" {
  description = "Do you want to enable telemetry."
  type        = bool
}
variable "tags" {
  description = "A map of the environment specific tags which are merged into resource tags."
  type        = map(string)
}

#================================================================================================
# 010-avm-res-resources-resourcegroup.tf
#================================================================================================
variable "resource_groups" {
  description = "A list of resource groups to create."
  type = map(object({
    role_assignments = any
  }))
}

#================================================================================================
# 020-ip-groups.tf
#================================================================================================
variable "ip_groups" {
  description = "A map of ip groups to create."
  type        = any
}

#================================================================================================
# 030-avm-res-network-firewallpolicy.tf
#================================================================================================
variable "firewall_policys" {
  description = "A map of firewall policys to create."
  type        = any
}

#================================================================================================
# 040-avm-res-network-firewallpolicy-rcg.tf
#================================================================================================
variable "firewall_rule_collection_groups" {
  description = "A map of firewall rule collection groups to create."
  type        = any
}

#================================================================================================
# 050-avm-res-network-azurefirewall.tf
#================================================================================================
variable "pips" {
  description = "A map of public ips to create."
  type        = any
}
variable "firewalls" {
  description = "A map of firewalls to create."
  type        = any
}
