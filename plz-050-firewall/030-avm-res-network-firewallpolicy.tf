# Create firewall policys.
module "avm-res-network-firewallpolicy" {
  source                         = "Azure/avm-res-network-firewallpolicy/azurerm"
  version                        = "0.3.3"
  enable_telemetry               = var.enable_telemetry
  for_each                       = { for k, v in var.firewall_policys : k => v }
  location                       = var.location
  resource_group_name            = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                           = each.key
  firewall_policy_base_policy_id = each.value.firewall_policy_base_policy_id
  firewall_policy_dns            = each.value.firewall_policy_dns
  firewall_policy_identity       = each.value.firewall_policy_identity
  # firewall_policy_intrusion_detection = {
  #   mode = each.value.firewall_policy_intrusion_detection
  # }
  firewall_policy_sku                      = each.value.firewall_policy_sku
  firewall_policy_threat_intelligence_mode = each.value.firewall_policy_threat_intelligence_mode
  firewall_policy_tls_certificate          = each.value.firewall_policy_tls_certificate
  role_assignments                         = each.value.role_assignments
  diagnostic_settings                      = each.value.diagnostic_settings
  tags                                     = var.tags
}
