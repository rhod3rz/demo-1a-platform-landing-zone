# Flatten the locations and domain names into a single list.
locals {
  pdns_zones = flatten([
    for k, v in var.pdns_locations : [
      for v2 in var.pdns_domain_names : {
        resource_group_name = v.resource_group_name
        domain_name         = v2
        virtual_network_links = {
          for k, v3 in v.pdns_virtual_network_links : k => {
            vnetlinkname     = v3.vnetlinkname
            vnetid           = v3.vnetid
            autoregistration = v3.autoregistration
          }
        }
      }
    ]
  ])
}

# Create private link DNS zones.
module "avm-res-network-privatednszone" {
  source                = "Azure/avm-res-network-privatednszone/azurerm"
  version               = "0.3.3"
  for_each              = { for i, v in local.pdns_zones : "${v.resource_group_name}-${v.domain_name}" => v }
  enable_telemetry      = var.enable_telemetry
  resource_group_name   = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  domain_name           = each.value.domain_name
  virtual_network_links = each.value.virtual_network_links
  tags                  = var.tags
}
