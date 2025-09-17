# Create role assignments.
resource "azurerm_role_assignment" "ra" {
  for_each                         = { for k, v in var.role_assignments : k => v }
  role_definition_id               = can(regex("^/subscriptions/.*/providers/Microsoft.Authorization/roleDefinitions/.*$", each.value.role_definition_id_or_name)) ? each.value.role_definition_id_or_name : null
  role_definition_name             = can(regex("^/subscriptions/.*/providers/Microsoft.Authorization/roleDefinitions/.*$", each.value.role_definition_id_or_name)) ? null : each.value.role_definition_id_or_name
  principal_id                     = each.value.principal_id
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
  scope                            = module.avm-ptn-alz-management[each.value.management_resource_group].resource_id
}
