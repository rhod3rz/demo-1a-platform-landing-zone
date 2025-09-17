# Create firewall policy - rule collection groups from CSV.
module "avm-res-network-firewallpolicy-rcg" {
  source                                                   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  version                                                  = "0.3.3"
  for_each                                                 = { for k, v in var.firewall_rule_collection_groups : k => v }
  firewall_policy_rule_collection_group_firewall_policy_id = module.avm-res-network-firewallpolicy[each.value.firewall_policy_name].resource_id
  firewall_policy_rule_collection_group_name               = each.value.rcg_name
  firewall_policy_rule_collection_group_priority           = 1000

  # network rules
  firewall_policy_rule_collection_group_network_rule_collection = [
    for rule_collection_name in distinct([
      for rule in try(csvdecode(file(each.value.network_rule_collection)), []) : rule.rule_collection_name if rule.rule_collection_name != ""
      ]) : {
      action   = [for rule in try(csvdecode(file(each.value.network_rule_collection)), []) : rule.action if rule.rule_collection_name == rule_collection_name][0]
      name     = rule_collection_name
      priority = tonumber([for rule in try(csvdecode(file(each.value.network_rule_collection)), []) : rule.priority if rule.rule_collection_name == rule_collection_name][0])
      rule = [
        for rule in try(csvdecode(file(each.value.network_rule_collection)), []) : {
          name                  = rule.rule_name
          source_addresses      = rule.source_addresses != "" ? split(",", rule.source_addresses) : null
          source_ip_groups      = rule.source_ip_groups != "" ? split(",", rule.source_ip_groups) : null
          destination_addresses = rule.destination_addresses != "" ? split(",", rule.destination_addresses) : null
          destination_fqdns     = rule.destination_fqdns != "" ? split(",", rule.destination_fqdns) : null
          destination_ip_groups = rule.destination_ip_groups != "" ? split(",", rule.destination_ip_groups) : null
          destination_ports     = rule.destination_ports != "" ? split(",", rule.destination_ports) : null
          protocols             = rule.protocols != "" ? split(",", rule.protocols) : ["Any"]
        } if rule.rule_collection_name == rule_collection_name && rule.rule_name != ""
      ]
    }
  ]

  # application rules
  firewall_policy_rule_collection_group_application_rule_collection = [
    for rule_collection_name in distinct([
      for rule in try(csvdecode(file(each.value.application_rule_collection)), []) : rule.rule_collection_name if rule.rule_collection_name != ""
      ]) : {
      action   = [for rule in try(csvdecode(file(each.value.application_rule_collection)), []) : rule.action if rule.rule_collection_name == rule_collection_name][0]
      name     = rule_collection_name
      priority = tonumber([for rule in try(csvdecode(file(each.value.application_rule_collection)), []) : rule.priority if rule.rule_collection_name == rule_collection_name][0])
      rule = [
        for rule in try(csvdecode(file(each.value.application_rule_collection)), []) : {
          name                  = rule.rule_name
          description           = rule.description != "" ? rule.description : null
          destination_addresses = rule.destination_addresses != "" ? split(",", rule.destination_addresses) : null
          destination_fqdns     = rule.destination_fqdns != "" ? split(",", rule.destination_fqdns) : null
          destination_fqdn_tags = rule.destination_fqdn_tags != "" ? split(",", rule.destination_fqdn_tags) : null
          destination_urls      = rule.destination_urls != "" ? split(",", rule.destination_urls) : null
          source_addresses      = rule.source_addresses != "" ? split(",", rule.source_addresses) : null
          source_ip_groups      = rule.source_ip_groups != "" ? split(",", rule.source_ip_groups) : null
          terminate_tls         = rule.terminate_tls != "" ? (rule.terminate_tls == "true" ? true : false) : null
          web_categories        = rule.web_categories != "" ? split(",", rule.web_categories) : null
          protocols = [
            for proto in split(",", rule.protocols) : {
              port = tonumber(rule.destination_ports)
              type = proto
            }
          ]
          http_headers = rule.http_headers != "" ? [for header in split(",", rule.http_headers) : {
            name  = split(":", header)[0]
            value = split(":", header)[1]
          }] : null
        } if rule.rule_collection_name == rule_collection_name && rule.rule_name != ""
      ]
    }
  ]

  # dnat rules
  firewall_policy_rule_collection_group_nat_rule_collection = [
    for rule_collection_name in distinct([
      for rule in try(csvdecode(file(each.value.nat_rule_collection)), []) : rule.rule_collection_name if rule.rule_collection_name != ""
      ]) : {
      action   = [for rule in try(csvdecode(file(each.value.nat_rule_collection)), []) : rule.action if rule.rule_collection_name == rule_collection_name][0]
      name     = rule_collection_name
      priority = tonumber([for rule in try(csvdecode(file(each.value.nat_rule_collection)), []) : rule.priority if rule.rule_collection_name == rule_collection_name][0])
      rule = [
        for rule in try(csvdecode(file(each.value.nat_rule_collection)), []) : {
          name                = rule.rule_name
          protocols           = rule.protocols != "" ? split(",", rule.protocols) : ["Any"]
          translated_port     = rule.translated_port != "" ? rule.translated_port : null
          destination_address = rule.destination_address != "" ? rule.destination_address : null
          destination_ports   = rule.destination_ports != "" ? split(",", rule.destination_ports) : null
          source_addresses    = rule.source_addresses != "" ? split(",", rule.source_addresses) : null
          source_ip_groups    = rule.source_ip_groups != "" ? split(",", rule.source_ip_groups) : null
          translated_address  = rule.translated_address != "" ? rule.translated_address : null
          translated_fqdn     = rule.translated_fqdn != "" ? rule.translated_fqdn : null
        } if rule.rule_collection_name == rule_collection_name && rule.rule_name != ""
      ]
    }
  ]

}
