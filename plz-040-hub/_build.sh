27/05/2025 - Final :-)

# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant      73578441-dc3d-4ecd-a298-fc5c6f40e191
conn_prd_01 6e71165a-aad7-4b08-ba1b-628e397e4b18

az feature register --namespace "Microsoft.Compute" --name "EncryptionAtHost"
az feature show --namespace "Microsoft.Compute" --name "EncryptionAtHost" --query properties.state
az provider register --namespace Microsoft.Compute # wait till above says 'registered' then run this.

# NORTH - prd
# login as sp_conn_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=plz-040-hub" `
  -backend-config="key=prd-nteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"
