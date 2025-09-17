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
  description = "Defines if telemetry should be enabled."
  type        = bool
}
variable "tags" {
  description = "A map of the environment specific tags which are merged into resource tags."
  type        = map(string)
}

#================================================================================================
# 010-resource-group.tf
#================================================================================================
variable "resource_groups" {
  description = "A list of resource groups to create."
  type = map(object({
    role_assignments = any
  }))
}

#================================================================================================
# 020-avm-res-storage-storageaccounts.tf
#================================================================================================
variable "storage_accounts" {
  description = "A map of storage accounts to create."
  type        = any
}
