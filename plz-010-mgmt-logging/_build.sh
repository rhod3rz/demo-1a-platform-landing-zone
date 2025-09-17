27/05/2025 - Final :-)

# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant      73578441-dc3d-4ecd-a298-fc5c6f40e191
mana_prd_01 21c8877e-a2da-4483-8ada-25856954e76b

010-avm-ptn-alz-management.tf          = log analytics workspace | managed identity | solutions
020-role-assignment.tf                 = role assignments for log analytics and storage
030-avm-res-storage-storageaccounts.tf = storage account for logging (if required)
040-avm-res-keyvault-vaults.tf         = key vault (if required)

# NORTH - prd
# login as sp_mana_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=plz-010-mgmt-logging" `
  -backend-config="key=prd-nteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"

# WEST - prd
# login as sp_mana_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-wteu-tfstate" `
  -backend-config="storage_account_name=sardzprdwteutfstate" `
  -backend-config="container_name=plz-010-mgmt-logging" `
  -backend-config="key=prd-wteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/wteu/prd-wteu.tfvars"
terraform apply -var-file="environments/prd/wteu/prd-wteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/wteu/prd-wteu.tfvars"
