#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id  = "6e71165a-aad7-4b08-ba1b-628e397e4b18" # conn_prd_01.
location         = "northeurope"
enable_telemetry = false
tags = {
  environment = "prd"
  owner       = "rhod3rz@outlook.com"
}

#================================================================================================
# 010-avm-res-resources-resourcegroup.tf
#================================================================================================
resource_groups = {
  rg-prd-nteu-firewall = {
    role_assignments = {}
  }
}

#================================================================================================
# 020-ip-groups.tf
#================================================================================================
# See 003-locals.tf for ip lists.
ip_groups = {
  # diagnostic vms.
  ipg-prd-nteu-vms-diagnostic = {
    resource_group_name = "rg-prd-nteu-firewall"
    cidrs_key           = "diagnostic_vms"
  }
  # jumpbox vms.
  ipg-prd-nteu-vms-jumpbox = {
    resource_group_name = "rg-prd-nteu-firewall"
    cidrs_key           = "jumpbox_vms"
  }
  # managed devops pools service.
  ipg-prd-nteu-svc-mdp = {
    resource_group_name = "rg-prd-nteu-firewall"
    cidrs_key           = "managed_devops_pools_subnets"
  }
  # private endpoints service.
  ipg-prd-nteu-svc-pep = {
    resource_group_name = "rg-prd-nteu-firewall"
    cidrs_key           = "private_endpoint_subnets"
  }
  # aks service.
  ipg-prd-nteu-svc-aks = {
    resource_group_name = "rg-prd-nteu-firewall"
    cidrs_key           = "aks_subnets"
  }
}

#================================================================================================
# 030-avm-res-network-firewallpolicy.tf
#================================================================================================
firewall_policys = {
  fwpol-prd-nteu = {
    resource_group_name            = "rg-prd-nteu-firewall"
    firewall_policy_base_policy_id = null
    firewall_policy_dns            = null # required for rules that use dns names | standard sku required.
    # firewall_policy_dns = {
    #   proxy_enabled = true
    #   servers       = []
    # }
    firewall_policy_identity = null
    # comment out until ready to use else terraform wants to keep installing something.
    # firewall_policy_intrusion_detection      = null    # Alert | Deny | Off | Must be set to null if not using higher tier sku.
    firewall_policy_sku                      = "Basic" # Basic | Standard | Premium
    firewall_policy_threat_intelligence_mode = null    # Alert | Deny | Off | Must be set to null if not using higher tier sku.
    firewall_policy_tls_certificate          = null
    role_assignments                         = {}
    diagnostic_settings                      = null
  }
}

#================================================================================================
# 040-avm-res-network-firewallpolicy-rcg.tf
#================================================================================================
# DNAT rules should have a higher priority (smaller priority field value) than network rules.
# Network rules should have a higher priority (smaller priority field value) than application rules.
# DNAT start at 10000 | Network start at 20000 | Application start at 30000.
firewall_rule_collection_groups = {
  # for ease of administration & troubleshooting, try and keep the rulesets the same for north & west.
  rcg-nteu-northsouth = {
    rcg_name                    = "rcg-northsouth"
    firewall_policy_name        = "fwpol-prd-nteu"
    application_rule_collection = "environments/prd/nteu/rcg-nteu-northsouth-application.csv"
    # comment; 80/443 application rules work for aks installation, however not the cert-manager helm installation, that needed a 443 network rule.
    network_rule_collection = "environments/prd/nteu/rcg-nteu-northsouth-network.csv"
    # nat rules cannot be set until the public ip of the firewall is known | create the firewall first then update the csv with the public ip.
    # nat_rule_collection = null
    nat_rule_collection = "environments/prd/nteu/rcg-nteu-northsouth-dnat.csv"
  }
  rcg-nteu-eastwest = {
    rcg_name                    = "rcg-eastwest"
    firewall_policy_name        = "fwpol-prd-nteu"
    application_rule_collection = null
    network_rule_collection     = "environments/prd/nteu/rcg-nteu-eastwest-network.csv"
    nat_rule_collection         = null
  }
}

#================================================================================================
# 050-avm-res-network-azurefirewall.tf
#================================================================================================
pips = {
  fw-prd-nteu-pip = {
    resource_group_name = "rg-prd-nteu-hub"
    allocation_method   = "Static"
    sku                 = "Standard"
    zones               = ["1", "2", "3"]
  }
  fw-prd-nteu-pip-mgmt = {
    resource_group_name = "rg-prd-nteu-hub"
    allocation_method   = "Static"
    sku                 = "Standard"
    zones               = ["1", "2", "3"]
  }
}
firewalls = {
  fw-prd-nteu = {
    resource_group_name = "rg-prd-nteu-hub"
    firewall_sku_tier   = "Basic"
    firewall_sku_name   = "AZFW_VNet"
    firewall_zones      = []
    firewall_ip_configuration = [
      {
        name                 = "AzureFirewallIpConfiguration0"
        subnet_id            = "/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-nteu-hub/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-hub/subnets/AzureFirewallSubnet"
        public_ip_address_id = "fw-prd-nteu-pip"
      }
    ]
    firewall_management_ip_configuration = {
      name                 = "AzureFirewallMgmtIpConfiguration"
      subnet_id            = "/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-nteu-hub/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-hub/subnets/AzureFirewallManagementSubnet"
      public_ip_address_id = "fw-prd-nteu-pip-mgmt"
    }
    firewall_policy_id = "fwpol-prd-nteu"
    diagnostic_settings = {
      diags = {
        name                  = "diags"
        workspace_resource_id = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu-250714"
        log_groups            = ["allLogs"]
        metric_categories     = ["allMetrics"]
      }
    }
  }
}
