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
# 010-avm-ptn-alz-management.tf
#================================================================================================
management_resource_groups = {
  prd-nteu = {
    resource_group_name                              = "rg-prd-nteu-mgmt"
    resource_group_creation_enabled                  = true
    log_analytics_workspace_name                     = "law-prd-nteu"
    automation_account_name                          = "aa-prd-nteu"
    automation_account_local_authentication_enabled  = true
    automation_account_public_network_access_enabled = false
    automation_account_sku_name                      = "Basic"
    linked_automation_account_creation_enabled       = false
    data_collection_rules = {
      change_tracking = {
        enabled = false
        name    = "dcr-change-tracking"
      }
      vm_insights = {
        enabled = false
        name    = "dcr-vm-insights"
      }
      defender_sql = {
        enabled = false
        name    = "dcr-defender-sql"
      }
    }
    log_analytics_solution_plans = [
      { "product" : "OMSGallery/ContainerInsights", "publisher" : "Microsoft" },
      { "product" : "OMSGallery/VMInsights", "publisher" : "Microsoft" }
    ]
    log_analytics_workspace_daily_quota_gb    = "1"
    log_analytics_workspace_retention_in_days = "30"
    log_analytics_workspace_sku               = "PerGB2018"
    sentinel_onboarding                       = null
    user_assigned_managed_identities = {
      ama = {
        name    = "uami-prd-nteu-ama"
        enabled = true
      }
    }
  }
}

#================================================================================================
# 020-role-assignments.tf
#================================================================================================
role_assignments = {
  ra1 = {
    role_definition_id_or_name       = "Log Analytics Contributor"
    principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
    skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
    management_resource_group        = "prd-nteu"
  }
  ra2 = {
    role_definition_id_or_name       = "Log Analytics Contributor"
    principal_id                     = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
    skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
    management_resource_group        = "prd-nteu"
  }
  # required to set rbac permissions on storage accounts once oauth has been enabled as default.
  ra3 = {
    role_definition_id_or_name       = "Storage Blob Data Owner"
    principal_id                     = "f1bcbd08-65a0-49dc-9141-bd4204a92bd9" # enterprise application > object id | sp_mana_prd_01.
    skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
    management_resource_group        = "prd-nteu"
  }
}

#================================================================================================
# 030-avm-res-storage-storageaccounts.tf
#================================================================================================
storage_accounts = {
  sardzprdnteulogs = {
    management_resource_group        = "prd-nteu"
    access_tier                      = "Hot"
    account_replication_type         = "LRS" # use ZRS in production.
    cross_tenant_replication_enabled = false
    default_to_oauth_authentication  = true # must set 'storage_use_azuread = true' in azurerm provider.
    public_network_access_enabled    = true
    queue_encryption_key_type        = "Service"
    network_rules = {
      default_action = "Deny"
      ip_rules       = ["86.10.95.19"]
      # 86.10.95.19 = rhodri home
      virtual_network_subnet_ids = []
    }
    # initially you will need to access via public ip; once hub & mdp are up, switch to private endpoint.
    private_endpoints = {
      # blob = {
      #   location                        = "northeurope"
      #   resource_group_name             = "rg-prd-nteu-shared"
      #   name                            = "sardzprdnteulogs-blob-pe"
      #   private_service_connection_name = "sardzprdnteulogs-blob-psc"
      #   subresource_name                = "blob"
      #   network_interface_name          = "sardzprdnteulogs-blob-nic"
      #   subnet_resource_id              = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-shared/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-shared/subnets/snet-nteu-pep"
      #   private_dns_zone_group_name     = "default"
      #   private_dns_zone_resource_ids   = ["/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-pdns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
      # }
    }
    blob_properties = {}
    containers = {
      "rdz-logs" = {
        name = "rdz-logs"
      }
    }
    role_assignments = {
      ra1 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "f1bcbd08-65a0-49dc-9141-bd4204a92bd9" # enterprise application > object id | sp_mana_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "cb7d960f-bbe7-44c3-9c09-d64ec7c4bd26" # object id | rhodri.freer@outlook.com.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
    }
  }
}

#================================================================================================
# 040-avm-res-keyvault-vaults.tf
#================================================================================================
key_vaults = {
  kv-prd-nteu = {
    management_resource_group     = "prd-nteu"
    tenant_id                     = "73578441-dc3d-4ecd-a298-fc5c6f40e191"
    public_network_access_enabled = true
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
      ip_rules       = ["86.10.95.19"]
      # 86.10.95.19 = rhodri home
      virtual_network_subnet_ids = []
    }
    # initially you will need to access via public ip; once hub & mdp are up, switch to private endpoint.
    private_endpoints = {
      # default = {
      #   location                        = "northeurope"
      #   resource_group_name             = "rg-prd-nteu-shared"
      #   name                            = "kv-prd-nteu-pe"
      #   private_service_connection_name = "kv-prd-nteu-psc"
      #   network_interface_name          = "kv-prd-nteu-nic"
      #   subnet_resource_id              = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-shared/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-shared/subnets/snet-nteu-pep"
      #   private_dns_zone_group_name     = "default"
      #   private_dns_zone_resource_ids   = ["/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-pdns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
      # }
    }
    purge_protection_enabled = false # set to true for production environment.
    role_assignments = {
      ra1 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id                     = "d08afe7c-ea95-4269-ad22-b9e2f8901242" # enterprise application > object id | sp_terraform_global.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id                     = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra4 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id                     = "f1bcbd08-65a0-49dc-9141-bd4204a92bd9" # enterprise application > object id | sp_mana_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra5 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id                     = "cb7d960f-bbe7-44c3-9c09-d64ec7c4bd26" # object id | rhodri.freer@outlook.com.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra6 = {
        role_definition_id_or_name       = "Contributor"                          # required for pipeline to enable / disable the keyvault firewall.
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra7 = {
        role_definition_id_or_name       = "Contributor"                          # required for pipeline to enable / disable the keyvault firewall.
        principal_id                     = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
    }
    sku_name                            = "standard"
    soft_delete_retention_days          = "7"
    diagnostic_settings_storage_account = "sardzprdnteulogs"
  }
}
