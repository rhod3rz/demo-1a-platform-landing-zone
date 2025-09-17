#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id            = "6e71165a-aad7-4b08-ba1b-628e397e4b18" # conn_prd_01.
subscription_id_management = "21c8877e-a2da-4483-8ada-25856954e76b" # mana_prd_01 | required to pull key vault secrets.
location                   = "northeurope"
enable_telemetry           = false
tags = {
  environment = "prd"
  owner       = "rhod3rz@outlook.com"
}

#================================================================================================
# 010-avm-res-resources-resourcegroup.tf
#================================================================================================
resource_groups = {
  rg-prd-nteu-hub = {
    role_assignments = {}
  }
  rg-prd-pdns = {
    role_assignments = {
      # required to update private dns zones.
      ra1 = {
        role_definition_id_or_name       = "User Access Administrator"            # required as the sp needs to add the aks uami once its created.
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Private DNS Zone Contributor"
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "Private DNS Zone Contributor"
        principal_id                     = "f1bcbd08-65a0-49dc-9141-bd4204a92bd9" # enterprise application > object id | sp_mana_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
    }
  }
  rg-prd-nteu-jump = {
    role_assignments = {}
  }
}

#================================================================================================
# 020-avm-res-network-routetable.tf
#================================================================================================
route_tables = {
  route-snet-nteu-azurefirewallsubnet = {
    resource_group_name = "rg-prd-nteu-hub"
    routes = {
      default = {
        name           = "default"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
      westeurope = {
        name                   = "westeurope"
        address_prefix         = "10.20.0.0/20"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.20.1.4"
      }
    }
  }
  route-snet-nteu-jump = {
    resource_group_name = "rg-prd-nteu-hub"
    routes = {
      default = {
        name                   = "default"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.10.1.4"
      }
    }
  }
}

#================================================================================================
# 030-avm-res-network-networksecuritygroup.tf
#================================================================================================
network_security_groups = {
  nsg-snet-nteu-azurebastionsubnet = { # Name must be lowercase.
    resource_group_name = "rg-prd-nteu-hub"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-azurebastionsubnet.csv"
  }
  nsg-snet-nteu-jump = { # Name must be lowercase.
    resource_group_name = "rg-prd-nteu-hub"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-jump.csv"
  }
}

#================================================================================================
# 040-avm-res-network-virtualnetwork.tf
#================================================================================================
hubs = {
  vnet-prd-nteu-hub = {
    resource_group_name = "rg-prd-nteu-hub"
    name                = "vnet-prd-nteu-hub"
    address_space       = ["10.10.0.0/20"]
    subnets = {
      AzureFirewallSubnet = {
        subnet_name                     = "AzureFirewallSubnet"
        address_prefixes                = ["10.10.1.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-azurefirewallsubnet"
        nsg_name                        = ""
        default_outbound_access_enabled = false
        delegation                      = []
      }
      AzureFirewallManagementSubnet = {
        subnet_name                     = "AzureFirewallManagementSubnet"
        address_prefixes                = ["10.10.2.0/24"]
        assign_generated_route_table    = false
        route_table_name                = ""
        nsg_name                        = ""
        default_outbound_access_enabled = false
        delegation                      = []
      }
      AzureBastionSubnet = {
        subnet_name                     = "AzureBastionSubnet"
        address_prefixes                = ["10.10.3.0/24"]
        assign_generated_route_table    = false
        route_table_name                = ""
        nsg_name                        = "nsg-snet-nteu-azurebastionsubnet"
        default_outbound_access_enabled = false
        delegation                      = []
      }
      snet-nteu-jump = {
        subnet_name                     = "snet-nteu-jump"
        address_prefixes                = ["10.10.4.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-jump"
        nsg_name                        = "nsg-snet-nteu-jump"
        default_outbound_access_enabled = false
        delegation                      = []
      }
    }
    role_assignments = {
      ra1 = {
        role_definition_id_or_name       = "Network Contributor"                  # required for peering.
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Network Contributor"                  # required for peering.
        principal_id                     = "f1bcbd08-65a0-49dc-9141-bd4204a92bd9" # enterprise application > object id | sp_mana_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
    }
  }
}

#================================================================================================
# 050-avm-res-network-virtualnetwork-peering.tf
#================================================================================================
vnet_peerings = {}

#================================================================================================
# 060-avm-res-network-privatednszone.tf
#================================================================================================
pdns_locations = {
  northeurope = {
    resource_group_name = "rg-prd-pdns"
    pdns_virtual_network_links = { # you will need to add these in after the vnets have been created.
      vnet-prd-nteu-hub = {
        vnetlinkname     = "vnet-prd-nteu-hub"
        vnetid           = "/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-nteu-hub/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-hub"
        autoregistration = false
      }
      # vnet-prd-wteu-hub = {
      #   vnetlinkname     = "vnet-prd-wteu-hub"
      #   vnetid           = "/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-wteu-hub/providers/Microsoft.Network/virtualNetworks/vnet-prd-wteu-hub"
      #   autoregistration = false
      # }
      # vnet-prd-nteu-shared = {
      #   vnetlinkname     = "vnet-prd-nteu-shared"
      #   vnetid           = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-shared/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-shared"
      #   autoregistration = false
      # }
      # vnet-prd-wteu-shared = {
      #   vnetlinkname     = "vnet-prd-wteu-shared"
      #   vnetid           = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-wteu-shared/providers/Microsoft.Network/virtualNetworks/vnet-prd-wteu-shared"
      #   autoregistration = false
      # }
      # vnet-prd-nteu-aks = {
      #   vnetlinkname     = "vnet-prd-nteu-aks"
      #   vnetid           = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-nteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-aks"
      #   autoregistration = false
      # }
      # vnet-prd-wteu-aks = {
      #   vnetlinkname     = "vnet-prd-wteu-aks"
      #   vnetid           = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-wteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-wteu-aks"
      #   autoregistration = false
      # }
    }
  }
}
pdns_domain_names = [
  "privatelink.blob.core.windows.net", # storage blob
  "privatelink.database.windows.net",  # sql database
  "privatelink.vaultcore.azure.net",   # key vault
  "privatelink.azurecr.io",            # containers
  "privatelink.northeurope.azmk8s.io", # aks
  "privatelink.westeurope.azmk8s.io"   # aks
]

#================================================================================================
# 070-avm-res-compute-virtualmachine.tf
#================================================================================================
key_vault_name = "kv-prd-nteu"
key_vault_rg   = "rg-prd-nteu-mgmt"
virtual_machines = {
  vm-nteu-jump = {
    resource_group_name               = "rg-prd-nteu-jump"
    os_type                           = "Windows"
    sku_size                          = "Standard_B2s_v2" # 2vCPU, 8GB | Standard_B2ms (v1) | Standard_B2s_v2 (v2).
    zone                              = "1"
    disable_password_authentication   = false
    admin_username                    = "wadmin"
    boot_diagnostics                  = true
    enable_automatic_updates          = true
    secure_boot_enabled               = true
    vtpm_enabled                      = true
    vm_agent_platform_updates_enabled = true
    source_image_reference = {
      publisher = "microsoftwindowsdesktop"
      offer     = "windows-11"
      sku       = "win11-24h2-pro"
      version   = "latest"
    }
    os_disk = {
      storage_account_type     = "StandardSSD_LRS"
      name                     = "vm-nteu-jump-osdisk"
      caching                  = "ReadWrite"
      security_encryption_type = null
    }
    nic_create_public_ip_address  = false
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.4.4"
    private_ip_vnet_name          = "vnet-prd-nteu-hub"
    private_ip_subnet_name        = "snet-nteu-jump"
    shutdown_schedules = {
      test_schedule = {
        daily_recurrence_time = "1900"
        enabled               = true
        timezone              = "GMT Standard Time"
      }
    }
  }
  # basic linux 'ping' vm to test spoke to spoke connectivity.
  vm-10-10-4-99 = {
    resource_group_name               = "rg-prd-nteu-hub"
    os_type                           = "Linux"
    sku_size                          = "Standard_B1s" # 1vCPU, 1GB.
    zone                              = "1"
    disable_password_authentication   = false
    admin_username                    = "ladmin"
    boot_diagnostics                  = true
    enable_automatic_updates          = false
    secure_boot_enabled               = false
    vtpm_enabled                      = false
    vm_agent_platform_updates_enabled = false
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    }
    os_disk = {
      storage_account_type     = "StandardSSD_LRS"
      name                     = "vm-10-10-4-99-osdisk"
      caching                  = "ReadWrite"
      security_encryption_type = null
    }
    nic_create_public_ip_address  = false
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.4.99"
    private_ip_vnet_name          = "vnet-prd-nteu-hub"
    private_ip_subnet_name        = "snet-nteu-jump"
    shutdown_schedules = {
      test_schedule = {
        daily_recurrence_time = "1900"
        enabled               = true
        timezone              = "GMT Standard Time"
      }
    }
  }
}
