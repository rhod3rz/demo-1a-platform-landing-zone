# Create managed devops pools.
module "avm-res-devopsinfrastructure-pool" {
  source                                      = "Azure/avm-res-devopsinfrastructure-pool/azurerm"
  version                                     = "0.2.3"
  enable_telemetry                            = var.enable_telemetry
  for_each                                    = { for k, v in var.managed_devops_pools : k => v }
  location                                    = var.location
  resource_group_name                         = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                                        = each.key
  dev_center_project_resource_id              = azurerm_dev_center_project.dcp[each.value.dev_center_project_name].id
  version_control_system_organization_name    = each.value.version_control_system_organization_name
  agent_profile_grace_period_time_span        = each.value.agent_profile_grace_period_time_span
  agent_profile_max_agent_lifetime            = each.value.agent_profile_max_agent_lifetime
  agent_profile_kind                          = each.value.agent_profile_kind
  agent_profile_resource_prediction_profile   = each.value.agent_profile_resource_prediction_profile
  fabric_profile_images                       = each.value.fabric_profile_images
  fabric_profile_os_disk_storage_account_type = each.value.fabric_profile_os_disk_storage_account_type
  fabric_profile_sku_name                     = each.value.fabric_profile_sku_name
  maximum_concurrency                         = each.value.maximum_concurrency
  diagnostic_settings                         = each.value.diagnostic_settings
  subnet_id                                   = module.avm-res-network-virtualnetwork[each.value.vnet_name].subnets[each.value.subnet_name].resource_id
  tags                                        = var.tags
}
