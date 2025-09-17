# Deploy management logging resources.
module "avm-ptn-alz-management" {
  source                                           = "Azure/avm-ptn-alz-management/azurerm"
  version                                          = "0.7.0"
  enable_telemetry                                 = var.enable_telemetry
  for_each                                         = { for k, v in var.management_resource_groups : k => v }
  location                                         = var.location
  resource_group_name                              = each.value.resource_group_name
  resource_group_creation_enabled                  = each.value.resource_group_creation_enabled
  log_analytics_workspace_name                     = each.value.log_analytics_workspace_name
  automation_account_name                          = each.value.automation_account_name
  automation_account_local_authentication_enabled  = each.value.automation_account_local_authentication_enabled
  automation_account_public_network_access_enabled = each.value.automation_account_public_network_access_enabled
  automation_account_sku_name                      = each.value.automation_account_sku_name
  linked_automation_account_creation_enabled       = each.value.linked_automation_account_creation_enabled
  data_collection_rules                            = each.value.data_collection_rules
  log_analytics_solution_plans                     = each.value.log_analytics_solution_plans
  log_analytics_workspace_daily_quota_gb           = each.value.log_analytics_workspace_daily_quota_gb
  log_analytics_workspace_retention_in_days        = each.value.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku                      = each.value.log_analytics_workspace_sku
  sentinel_onboarding                              = each.value.sentinel_onboarding
  user_assigned_managed_identities = {
    for k, v in each.value.user_assigned_managed_identities : k => {
      name     = v.name
      enabled  = v.enabled
      location = var.location
      tags     = var.tags
    }
  }
  tags = var.tags
}
