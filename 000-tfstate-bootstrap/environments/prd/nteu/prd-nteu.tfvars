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
# 010-resource-groups.tf
#================================================================================================
resource_groups = {
  rg-prd-nteu-tfstate = {
    role_assignments = {
      # required to set rbac permissions on storage accounts once oauth has been enabled as default.
      ra1 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "f1bcbd08-65a0-49dc-9141-bd4204a92bd9" # enterprise application > object id | sp_mana_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Contributor"                          # required for pipeline to enable / disable the storage account firewall.
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "Contributor"                          # required for pipeline to enable / disable the storage account firewall.
        principal_id                     = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
    }
  }
}

#================================================================================================
# 020-avm-res-storage-storageaccounts.tf
#================================================================================================
storage_accounts = {
  sardzprdnteutfstate = {
    resource_group_name              = "rg-prd-nteu-tfstate"
    access_tier                      = "Hot"
    account_replication_type         = "LRS" # use ZRS in production.
    cross_tenant_replication_enabled = false
    default_to_oauth_authentication  = true
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
      #   name                            = "sardzprdnteutfstate-blob-pe"
      #   private_service_connection_name = "sardzprdnteutfstate-blob-psc"
      #   subresource_name                = "blob"
      #   network_interface_name          = "sardzprdnteutfstate-blob-nic"
      #   subnet_resource_id              = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-shared/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-shared-01/subnets/snet-nteu-pep-01"
      #   private_dns_zone_group_name     = "default"
      #   private_dns_zone_resource_ids   = ["/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-pdns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
      # }
    }
    blob_properties = {
      delete_retention_policy = {
        days = "7"
      }
      container_delete_retention_policy = {
        days = "7"
      }
      restore_policy = {
        days = "6"
      }
      versioning_enabled            = true
      change_feed_enabled           = true
      change_feed_retention_in_days = "7"
    }
    containers = {
      # landing zone - platform
      "plz-010-mgmt-logging" = {
        name = "plz-010-mgmt-logging"
      }
      "plz-020-mgmt-groups-policies" = {
        name = "plz-020-mgmt-groups-policies"
      }
      "plz-030-mgmt-automation" = {
        name = "plz-030-mgmt-automation"
      }
      "plz-040-hub" = {
        name = "plz-040-hub"
      }
      "plz-050-firewall" = {
        name = "plz-050-firewall"
      }
      "plz-060-shared-services" = {
        name = "plz-060-shared-services"
      }
      # landing zone - application
      "alz-010-aks-lz" = {
        name = "alz-010-aks-lz"
      }
      "alz-020-aks-clusters" = {
        name = "alz-020-aks-clusters"
      }
      "alz-040-front-door" = {
        name = "alz-040-front-door"
      }
    }
    role_assignments = {
      ra1 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "d08afe7c-ea95-4269-ad22-b9e2f8901242" # enterprise application > object id | sp_terraform_global.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra4 = {
        role_definition_id_or_name       = "Storage Blob Data Owner"
        principal_id                     = "cb7d960f-bbe7-44c3-9c09-d64ec7c4bd26" # object id | rhodri.freer@outlook.com.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
    }
  }
}
