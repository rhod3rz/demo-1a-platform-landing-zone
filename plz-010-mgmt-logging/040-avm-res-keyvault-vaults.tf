# Create key vaults.
module "avm-res-keyvault-vault" {
  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  version                       = "0.10.0"
  enable_telemetry              = var.enable_telemetry
  for_each                      = { for k, v in var.key_vaults : k => v }
  location                      = var.location
  resource_group_name           = module.avm-ptn-alz-management[each.value.management_resource_group].resource_group.name
  name                          = each.key
  tenant_id                     = each.value.tenant_id
  public_network_access_enabled = each.value.public_network_access_enabled
  network_acls                  = each.value.network_acls
  private_endpoints             = each.value.private_endpoints
  purge_protection_enabled      = each.value.purge_protection_enabled
  role_assignments              = each.value.role_assignments
  sku_name                      = each.value.sku_name
  soft_delete_retention_days    = each.value.soft_delete_retention_days
  diagnostic_settings = {
    # diags = {
    #   name                  = "diags"
    #   workspace_resource_id = module.avm-ptn-alz-management[each.value.management_resource_group].resource_id
    #   log_groups            = ["allLogs", "audit"]
    #   metric_categories     = ["AllMetrics"]
    # }
  }
  tags = var.tags
}
