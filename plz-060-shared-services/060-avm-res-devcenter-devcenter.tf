# Create dev centers.
module "avm-res-devcenter-devcenter" {
  source              = "Azure/avm-res-devcenter-devcenter/azurerm"
  version             = "0.1.0"
  enable_telemetry    = var.enable_telemetry
  for_each            = { for k, v in var.devcenters : k => v }
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  dev_center_name     = each.key
  tags                = var.tags
}

# Create dev center projects.
locals {
  dev_center_projects = flatten([
    for k, v in var.devcenters : [
      for i in v.projects : {
        dev_center_id       = module.avm-res-devcenter-devcenter[k].resource_id
        location            = var.location
        resource_group_name = module.avm-res-resources-resourcegroup[v.resource_group_name].name
        project_name        = i
      }
    ]
  ])
}
# output "dev_center_projects" { value = local.dev_center_projects }
resource "azurerm_dev_center_project" "dcp" {
  for_each            = { for i in local.dev_center_projects : i.project_name => i }
  dev_center_id       = each.value.dev_center_id
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                = each.value.project_name
  tags                = var.tags
}
