# Create resource groups.
resource "azurerm_ip_group" "ig" {
  for_each            = { for k, v in var.ip_groups : k => v }
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                = each.key
  cidrs               = local.ip_groups[each.value.cidrs_key]
  tags                = var.tags
}
