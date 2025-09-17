# Create public ips.
module "avm-res-network-publicipaddress" {
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.2.0"
  enable_telemetry    = var.enable_telemetry
  for_each            = { for k, v in var.pips : k => v }
  location            = var.location
  resource_group_name = each.value.resource_group_name
  name                = each.key
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  zones               = each.value.zones
  tags                = var.tags
}

# Create firewalls.
module "avm-res-network-azurefirewall" {
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  version             = "0.3.0"
  enable_telemetry    = var.enable_telemetry
  for_each            = { for k, v in var.firewalls : k => v }
  location            = var.location
  resource_group_name = each.value.resource_group_name
  name                = each.key
  firewall_sku_tier   = each.value.firewall_sku_tier
  firewall_sku_name   = each.value.firewall_sku_name
  firewall_zones      = each.value.firewall_zones
  firewall_ip_configuration = [
    for ipconfig in each.value.firewall_ip_configuration : {
      name                 = ipconfig.name
      subnet_id            = ipconfig.subnet_id
      public_ip_address_id = module.avm-res-network-publicipaddress[ipconfig.public_ip_address_id].public_ip_id
    }
  ]
  firewall_management_ip_configuration = {
    name                 = each.value.firewall_management_ip_configuration.name
    subnet_id            = each.value.firewall_management_ip_configuration.subnet_id
    public_ip_address_id = module.avm-res-network-publicipaddress[each.value.firewall_management_ip_configuration.public_ip_address_id].public_ip_id
  }
  firewall_policy_id  = module.avm-res-network-firewallpolicy[each.value.firewall_policy_id].resource_id
  diagnostic_settings = each.value.diagnostic_settings
  tags                = var.tags
}
