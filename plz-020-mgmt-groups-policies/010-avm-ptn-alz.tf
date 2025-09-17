# Deploy management groups and policies.
module "avm-ptn-alz" {
  source                       = "Azure/avm-ptn-alz/azurerm"
  version                      = "0.12.0"
  enable_telemetry             = var.enable_telemetry
  location                     = var.location
  architecture_name            = var.avm-ptn-alz.architecture_name
  parent_resource_id           = data.azapi_client_config.current.tenant_id
  subscription_placement       = var.avm-ptn-alz.subscription_placement
  policy_assignments_to_modify = var.policy_assignments_to_modify
  # Crazy timeouts required when using a service principle to authenticate; bug logged.
  # This environment variable is also required: $env:AZAPI_RETRY_GET_AFTER_PUT_MAX_TIME = "20m".
  # Its been added to the pipeline :-)
  retries = {
    management_groups = {
      error_message_regex = [
        "AuthorizationFailed",
        "Failed to retrieve resource",
      ]
    }
    role_definition = {
      error_message_regex = [
        "AuthorizationFailed"
      ]
    }
  }
  timeouts = {
    management_group = {
      create = "20m"
      delete = "20m"
      read   = "20m"
      update = "20m"
    }
    role_definition = {
      create = "20m"
      delete = "20m"
      read   = "20m"
      update = "20m"
    }
  }
}
