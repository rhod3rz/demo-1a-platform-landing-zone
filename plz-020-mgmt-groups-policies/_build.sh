27/05/2025 - Final :-)

# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant      73578441-dc3d-4ecd-a298-fc5c6f40e191
mana_prd_01 21c8877e-a2da-4483-8ada-25856954e76b

# prd-nteu (even though management groups and policies are global you have to pick a location)
# login as sp_terraform_global or rhodri.freer@outlook.com
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=plz-020-mgmt-groups-policies" `
  -backend-config="key=prd-nteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"
