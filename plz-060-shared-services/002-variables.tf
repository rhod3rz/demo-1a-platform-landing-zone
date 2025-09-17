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
# 020-avm-res-network-routetable.tf
#================================================================================================
variable "route_tables" {
  description = "A map of route tables to create."
  type        = any
}

#================================================================================================
# 030-avm-res-network-networksecuritygroup.tf
#================================================================================================
variable "network_security_groups" {
  description = "A map of network security groups to create."
  type        = any
}

#================================================================================================
# 040-avm-res-network-virtualnetwork.tf
#================================================================================================
variable "spokes" {
  description = "A map of spoke settings."
  type        = any
}

#================================================================================================
# 050-avm-res-network-virtualnetwork-peering.tf
#================================================================================================
variable "vnet_peerings" {
  description = "A map of vnet peering settings."
  type        = any
}

#================================================================================================
# 060-avm-res-devcenter-devcenter.tf
#================================================================================================
variable "devcenters" {
  description = "A map of dev centers to create."
  type        = any
}

#================================================================================================
# 070-avm-res-devopsinfrastructure-pool.tf
#================================================================================================
variable "managed_devops_pools" {
  description = "A map of managed devops pools to create."
  type        = any
}

#================================================================================================
# 080-avm-res-compute-virtualmachine.tf
#================================================================================================
variable "key_vault_name" {
  description = "The key vault containing the admin passwords."
  type        = any
}
variable "key_vault_rg" {
  description = "The key vault resource group."
  type        = any
}
variable "virtual_machines" {
  description = "A map of virtual machines to create."
  type        = any
}
