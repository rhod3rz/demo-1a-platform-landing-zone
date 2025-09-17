#================================================================================================
# Provider Configuration
#================================================================================================
terraform {
  # https://developer.hashicorp.com/terraform/language/expressions/version-constraints
  # https://developer.hashicorp.com/terraform/language/v1-compatibility-promises
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  # We specify 'local' config here.
  backend "local" {}
}

provider "azurerm" {
  # We include subscription_id in here as different environments may be in different subscriptions.
  subscription_id = var.subscription_id
  features {}
  storage_use_azuread = true
}
