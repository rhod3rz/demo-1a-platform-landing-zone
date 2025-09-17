#================================================================================================
# Environment Configuration Values (e.g. dev.tfvars)
#================================================================================================
variable "subscription_id" {
  description = "The subscription id."
  type        = string
}
variable "location" {
  description = "The location to deploy to."
  type        = string
}
variable "environment" {
  description = "The environment."
  type        = string
}
variable "region_code" {
  description = "The region code."
  type        = string
}
variable "enable_telemetry" {
  description = "Do you want to enable telemetry."
  type        = bool
}

#================================================================================================
# 010-avm-ptn-alz.tf
#================================================================================================
variable "avm-ptn-alz" {
  description = "A map of landing zones."
  type        = any
}
variable "policy_assignments_to_modify" {
  description = "A map of policy assignments to modify."
  type        = any
}
