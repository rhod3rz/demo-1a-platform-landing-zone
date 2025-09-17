27/05/2025 - Final :-) However, not deployed as leaving out private endpoints for now to keep things simple.

# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant      73578441-dc3d-4ecd-a298-fc5c6f40e191
mana_prd_01 21c8877e-a2da-4483-8ada-25856954e76b

# pre-requisites
az provider register --namespace 'Microsoft.DevOpsInfrastructure'
az provider register --namespace 'Microsoft.DevCenter'
# add the service principal (sp_terraform_global) to azure devops agent pools as an administrator (project level).
# add the service principal (sp_mana_prd_01) to azure devops agent pools as an administrator (project level).
# each mdp requires its own subnet dedicated to microsoft.devopsinfrastructure/pools.
# ensure the DevOpsInfrastructure sp has reader and network contributor perms on the vnet.

# NORTH - prd
# login as sp_mana_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=plz-060-shared-services" `
  -backend-config="key=prd-nteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"
