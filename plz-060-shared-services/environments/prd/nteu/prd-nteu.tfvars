#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id  = "21c8877e-a2da-4483-8ada-25856954e76b" # mana_prd_01.
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
  rg-prd-nteu-shared = {
    role_assignments = {}
  }
}

#================================================================================================
# 020-avm-res-network-routetable.tf
#================================================================================================
route_tables = {
  route-snet-nteu-pep = {
    resource_group_name = "rg-prd-nteu-shared"
    routes = {
      default = {
        name                   = "default"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.10.1.4"
      }
    }
  }
  route-snet-nteu-mdp = {
    resource_group_name = "rg-prd-nteu-shared"
    routes = {
      default = {
        name                   = "default"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.10.1.4"
      }
    }
  }
  route-snet-nteu-diags = {
    resource_group_name = "rg-prd-nteu-shared"
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
  nsg-snet-nteu-pep = { # Name must be lowercase.
    location            = "northeurope"
    resource_group_name = "rg-prd-nteu-shared"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-pep.csv"
  }
  nsg-snet-nteu-mdp = { # Name must be lowercase.
    location            = "northeurope"
    resource_group_name = "rg-prd-nteu-shared"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-mdp.csv"
  }
  nsg-snet-nteu-diags = { # Name must be lowercase.
    location            = "northeurope"
    resource_group_name = "rg-prd-nteu-shared"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-diags.csv"
  }
}

#================================================================================================
# 040-avm-res-network-virtualnetwork.tf
#================================================================================================
spokes = {
  vnet-prd-nteu-shared = {
    resource_group_name = "rg-prd-nteu-shared"
    name                = "vnet-prd-nteu-shared"
    address_space       = ["10.11.0.0/20"]
    subnets = {
      snet-nteu-pep = {
        subnet_name                     = "snet-nteu-pep"
        address_prefixes                = ["10.11.1.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-pep"
        nsg_name                        = "nsg-snet-nteu-pep"
        default_outbound_access_enabled = false
        delegation                      = []
      }
      snet-nteu-mdp = {
        subnet_name                     = "snet-nteu-mdp"
        address_prefixes                = ["10.11.2.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-mdp"
        nsg_name                        = "nsg-snet-nteu-mdp"
        default_outbound_access_enabled = false
        delegation = [
          {
            name = "mdp-delegation"
            service_delegation = {
              name    = "Microsoft.DevOpsInfrastructure/pools"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        ]
      }
      snet-nteu-diags = {
        subnet_name                     = "snet-nteu-diags"
        address_prefixes                = ["10.11.3.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-diags"
        nsg_name                        = "nsg-snet-nteu-diags"
        default_outbound_access_enabled = false
        delegation                      = []
      }
    }
    role_assignments = {
      # requirement for managed devops pools.
      ra1 = {
        principal_id               = "e335f233-e399-4073-a94c-adfd9d4a3672" # enterprise application > object id | DevOpsInfrastructure.
        role_definition_id_or_name = "Reader"
      }
      # requirement for managed devops pools.
      ra2 = {
        principal_id               = "e335f233-e399-4073-a94c-adfd9d4a3672" # enterprise application > object id | DevOpsInfrastructure.
        role_definition_id_or_name = "Network Contributor"
      }
      # requirement to link the vnet to private dns zones.
      ra3 = {
        principal_id               = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
        role_definition_id_or_name = "Private DNS Zone Contributor"
      }
    }
  }
}

#================================================================================================
# 050-avm-res-network-virtualnetwork-peering.tf
#================================================================================================
vnet_peerings = {
  northshared_to_northhub = {
    virtual_network                      = "vnet-prd-nteu-shared"
    remote_subscription_id               = "6e71165a-aad7-4b08-ba1b-628e397e4b18" # conn_prd_01.
    remote_resource_group                = "rg-prd-nteu-hub"
    remote_virtual_network_name          = "vnet-prd-nteu-hub"
    name                                 = "northshared-to-northhub"
    allow_virtual_network_access         = true  # enable access between vnets.
    allow_forwarded_traffic              = true  # allow traffic forwarding for inter vnet communication.
    allow_gateway_transit                = false # west vnet doesnt act as a transit gateway (e.g. no vpn or expressroute gateway).
    use_remote_gateways                  = false # west vnet doesnt need to use a transit gateway in north.
    create_reverse_peering               = true  # set up reverse peering automatically.
    reverse_name                         = "northhub-to-northshared"
    reverse_allow_virtual_network_access = true  # enable access between vnets.
    reverse_allow_forwarded_traffic      = true  # allow traffic forwarding for inter vnet communication.
    reverse_allow_gateway_transit        = false # north vnet doesnt act as a transit gateway (e.g. no vpn or expressroute gateway).
    reverse_use_remote_gateways          = false # north vnet doesnt need to use a transit gateway in west.
  }
}

#================================================================================================
# 060-avm-res-devcenter-devcenter.tf
#================================================================================================
devcenters = {
  devctr-prd-nteu = {
    resource_group_name = "rg-prd-nteu-shared"
    projects = [
      "proj-prd-nteu-mdp"
    ]
  }
}

#================================================================================================
# 070-avm-res-devopsinfrastructure-pool.tf
#================================================================================================
managed_devops_pools = {
  mdp-prd-nteu = {
    resource_group_name                       = "rg-prd-nteu-shared"
    dev_center_project_name                   = "proj-prd-nteu-mdp"
    version_control_system_organization_name  = "rhod3rz01"
    agent_profile_grace_period_time_span      = "01:00:00" # 1 hour | Max time stateful agent lives after running a workload.
    agent_profile_max_agent_lifetime          = "01:00:00" # 1 hour | Max time stateful or standby agents should live before recycling.
    agent_profile_kind                        = "Stateful"
    agent_profile_resource_prediction_profile = "Off" # Off | Manual | Automatic.
    fabric_profile_images = [
      {
        aliases               = ["ubuntu-22.04", "ubuntu-22.04/latest"]
        buffer                = "100"
        well_known_image_name = "ubuntu-22.04"
      }
    ]
    fabric_profile_os_disk_storage_account_type = "Premium"
    fabric_profile_sku_name                     = "Standard_B2s_v2"
    maximum_concurrency                         = "2"
    diagnostic_settings = {
      # diags = {
      #   name                  = "diag"
      #   workspace_resource_id = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu"
      #   log_groups            = ["allLogs"]
      #   metric_categories     = ["AllMetrics"]
      # }
    }
    vnet_name   = "vnet-prd-nteu-shared"
    subnet_name = "snet-nteu-mdp"
  }
}

#================================================================================================
# 080-avm-res-compute-virtualmachine.tf
#================================================================================================
key_vault_name = "kv-prd-nteu"
key_vault_rg   = "rg-prd-nteu-mgmt"
virtual_machines = {
  # basic linux 'ping' vm to test spoke to spoke connectivity.
  vm-10-11-3-99 = {
    resource_group_name               = "rg-prd-nteu-shared"
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
      name                     = "vm-10-11-3-99-osdisk"
      caching                  = "ReadWrite"
      security_encryption_type = null
    }
    nic_create_public_ip_address  = false
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.11.3.99"
    private_ip_vnet_name          = "vnet-prd-nteu-shared"
    private_ip_subnet_name        = "snet-nteu-diags"
    shutdown_schedules = {
      test_schedule = {
        daily_recurrence_time = "1900"
        enabled               = true
        timezone              = "GMT Standard Time"
      }
    }
  }
}
