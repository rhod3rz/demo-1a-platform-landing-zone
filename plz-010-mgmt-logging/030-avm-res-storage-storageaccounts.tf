# Create storage accounts.
module "avm-res-storage-storageaccount" {
  source                           = "Azure/avm-res-storage-storageaccount/azurerm"
  version                          = "0.6.2"
  enable_telemetry                 = var.enable_telemetry
  for_each                         = { for k, v in var.storage_accounts : k => v }
  location                         = var.location
  resource_group_name              = module.avm-ptn-alz-management[each.value.management_resource_group].resource_group.name
  name                             = each.key
  access_tier                      = each.value.access_tier
  account_replication_type         = each.value.account_replication_type
  cross_tenant_replication_enabled = each.value.cross_tenant_replication_enabled
  default_to_oauth_authentication  = each.value.default_to_oauth_authentication
  public_network_access_enabled    = each.value.public_network_access_enabled
  network_rules                    = each.value.network_rules
  private_endpoints                = each.value.private_endpoints
  blob_properties                  = each.value.blob_properties
  role_assignments                 = each.value.role_assignments
  containers                       = each.value.containers
  diagnostic_settings_storage_account = {
    # diags = {
    #   name                  = "diags"
    #   workspace_resource_id = module.avm-ptn-alz-management[each.value.management_resource_group].resource_id
    #   log_categories        = ["allLogs", "audit"]
    #   metric_categories     = ["Capacity", "Transaction"]
    # }
  }
  diagnostic_settings_blob = {
    # diags = {
    #   name                  = "diags"
    #   workspace_resource_id = module.avm-ptn-alz-management[each.value.management_resource_group].resource_id
    #   log_categories        = ["allLogs", "audit"]
    #   metric_categories     = ["Capacity", "Transaction"]
    # }
  }
  tags = var.tags
}
