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
# 010-avm-ptn-alz-management.tf
#================================================================================================
variable "management_resource_groups" {
  description = "A map of management resource groups to create."
  type        = any
}

#================================================================================================
# 020-role-assignments.tf
#================================================================================================
variable "role_assignments" {
  description = "A map of role assignments to create."
  type        = any
}

#================================================================================================
# 030-avm-res-storage-storageaccounts.tf
#================================================================================================
variable "storage_accounts" {
  description = "A map of storage accounts to create."
  type        = any
}

#================================================================================================
# 040-avm-res-keyvault-vaults.tf
#================================================================================================
variable "key_vaults" {
  description = "A map of key vaults to create."
  type        = any
}
