#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id  = "21c8877e-a2da-4483-8ada-25856954e76b" # mana_prd_01.
location         = "northeurope"
environment      = "prd"
region_code      = "nteu"
enable_telemetry = false

#================================================================================================
# 010-avm-ptn-alz.tf
#================================================================================================
avm-ptn-alz = {
  architecture_name = "custom"
  subscription_placement = {
    appl_prd_01 = {
      subscription_id       = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
      management_group_name = "alz1-prd-onli"
    }
    conn_prd_01 = {
      subscription_id       = "6e71165a-aad7-4b08-ba1b-628e397e4b18"
      management_group_name = "alz1-prd-conn"
    }
    mana_prd_01 = {
      subscription_id       = "21c8877e-a2da-4483-8ada-25856954e76b"
      management_group_name = "alz1-prd-mana"
    }
  }
}

policy_assignments_to_modify = {
  # Root Level
  alz1-prd-root = {
    policy_assignments = {
      Audit-ResourceRGLocation = {
        resource_selectors = [
          {
            name = "ResourceTypeExclusions"
            resource_selector_selectors = [
              {
                kind = "resourceType"
                not_in = [
                  "microsoft.network/networkwatchers"
                ]
              }
            ]
          }
        ]
      }
      Deploy-AzActivity-Log = {
        parameters = {
          logAnalytics = "{\"value\": \"/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourcegroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu-250714\"}"
        }
      }
    }
  }
  # Landing Zones Level
  alz1-prd-land = {
    policy_assignments = {
      Enforce-GR-KeyVault = {
        parameters = {
          effectKvPurgeProtection   = "{\"value\": \"Audit\"}"
          keyVaultSecretContentType = "{\"value\": \"Audit\"}"
          secretsValidPeriod        = "{\"value\": \"Disabled\"}"
        }
      }
      Deny-Privileged-AKS = {
        parameters = {
          excludedNamespaces = "{\"value\": [\"kube-system\", \"gatekeeper-system\", \"azure-arc\", \"azure-extensions-usage-system\", \"azure-alb-system\"]}"
        }
      }
      Deny-Priv-Esc-AKS = {
        parameters = {
          excludedNamespaces = "{\"value\": [\"kube-system\", \"gatekeeper-system\", \"azure-arc\", \"azure-extensions-usage-system\", \"azure-alb-system\"]}"
        }
      }
    }
  }
  # Platform Level
  alz1-prd-plat = {
    policy_assignments = {
      Enforce-GR-KeyVault = {
        parameters = {
          effectKvPurgeProtection   = "{\"value\": \"Audit\"}"
          keyVaultSecretContentType = "{\"value\": \"Audit\"}"
          secretsValidPeriod        = "{\"value\": \"Disabled\"}"
        }
      }
      # DenyAction-DeleteUAMIAMA = {
      #   parameters = {
      #     resourceName = "{\"value\": \"uami-prd-nteu-ama\"}"
      #   }
      # }
    }
  }
}
