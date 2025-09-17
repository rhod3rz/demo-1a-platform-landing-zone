27/05/2025 - Final :-)

# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

# SUBSCRIPTIONS & SERVICE PRINCIPALS

| SUBSCRIPTION        | SERVICE PRINCIPAL      | ROLES
| n/a                 | sp_terraform_global    | owner at root level (this is required for mgmt group changes)
|                     |                        |
| appl_nonprd_01      | sp_appl_nonprd_01      | contributor, user access administrator (rbac)
| appl_prd_01         | sp_appl_prd_01         | contributor, user access administrator (rbac)
|                     |                        |
| conn_nonprd_01      | sp_conn_nonprd_01      | contributor, user access administrator (rbac)
| conn_prd_01         | sp_conn_prd_01         | contributor, user access administrator (rbac)
|                     |                        |
| mana_nonprd_01      | sp_mana_nonprd_01      | contributor, user access administrator (rbac)
| mana_prd_01         | sp_mana_prd_01         | contributor, user access administrator (rbac)

az ad sp create-for-rbac --name sp_appl_prd_01 --years 2
az ad sp create-for-rbac --name sp_conn_prd_01 --years 2
az ad sp create-for-rbac --name sp_mana_prd_01 --years 2

# set sub perms - appl_prd_01
$subscriptionName = "appl_prd_01"
$spName = "sp_appl_prd_01"
az account set --subscription "$subscriptionName"
$subscriptionId = az account show --query "id" -o tsv
$spObjectId = (az ad sp list --all --query "[?displayName=='$spName'].id" -o tsv)
az role assignment create --assignee $spObjectId --role "Contributor" --scope "/subscriptions/$subscriptionId"
az role assignment create --assignee $spObjectId --role "User Access Administrator" --scope "/subscriptions/$subscriptionId"

# set sub perms - conn_prd_01
$subscriptionName = "conn_prd_01"
$spName = "sp_conn_prd_01"
az account set --subscription "$subscriptionName"
$subscriptionId = az account show --query "id" -o tsv
$spObjectId = (az ad sp list --all --query "[?displayName=='$spName'].id" -o tsv)
az role assignment create --assignee $spObjectId --role "Contributor" --scope "/subscriptions/$subscriptionId"
az role assignment create --assignee $spObjectId --role "User Access Administrator" --scope "/subscriptions/$subscriptionId"

# set sub perms - mana_prd_01
$subscriptionName = "mana_prd_01"
$spName = "sp_mana_prd_01"
az account set --subscription "$subscriptionName"
$subscriptionId = az account show --query "id" -o tsv
$spObjectId = (az ad sp list --all --query "[?displayName=='$spName'].id" -o tsv)
az role assignment create --assignee $spObjectId --role "Contributor" --scope "/subscriptions/$subscriptionId"
az role assignment create --assignee $spObjectId --role "User Access Administrator" --scope "/subscriptions/$subscriptionId"

# AZURE DEVOPS AUTHENTICATION
Create service connections for each service principal.
sp_appl_prd_01
sp_conn_prd_01
sp_mana_prd_01
sp_terraform_global_mana_prd_01 (mgmt groups & policies)

# AZURE DEVOPS PERMISSIONS
- Update the build service account for repo '000-tfstate-bootstrap' to allow contribute (to allow git commit/push).

# TFSTATE DESIGN
repo-root/
├── environments/
│   ├── nonprd/
│   │   ├── nteu/
│   │   │   ├── nonprd-nteu.tfstate
│   │   │   ├── nonprd-nteu.tfvars
│   │   ├── wteu/
│   │   │   ├── nonprd-wteu.tfstate
│   │   │   ├── nonprd-wteu.tfvars
│   ├── prd/
│   │   ├── nteu/
│   │   │   ├── prd-nteu.tfstate
│   │   │   ├── prd-nteu.tfvars
│   │   ├── wteu/
│   │   │   ├── prd-wteu.tfstate
│   │   │   ├── prd-wteu.tfvars

# TFSTATE DESIGN PRINCIPLES
- Each file is named to clearly indicate the environment and region.
  This is useful in vscode to avoid confusion when working with multiple files.
  e.g. if all files were named main.tfvars it would be unclear which environment or region you are working on.
- Each region has its own terraform state file to manage resources specific to that region.
  Why? if all regions were managed in a single state file, a failure in one region would impact terraforms ability to query and manage resources in other regions.
  If a region fails, terraform cannot communicate with the resources in that region.
  When terraform plan or apply runs, it queries the cloud provider using the management api and compares the actual deployed infrastructure against the state file.
  If a region is down, terraform will be unable to query that regions resources leading to errors in the pipeline.

# NORTH - prd
# login as sp_mana_prd_01
terraform init -reconfigure `
  -backend-config="path=./environments/prd/nteu/prd-nteu.tfstate"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"

# WEST - prd
# login as sp_mana_prd_01
terraform init -reconfigure `
  -backend-config="path=./environments/prd/wteu/prd-wteu.tfstate"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/wteu/prd-wteu.tfvars"
terraform apply -var-file="environments/prd/wteu/prd-wteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/wteu/prd-wteu.tfvars"

# TFSTATE CONTAINERS
# landing zone - platform
plz-010-mgmt-logging
plz-020-mgmt-groups-policies
plz-030-mgmt-automation
plz-040-hub
plz-050-firewall
plz-060-shared-services
# landing zone - application
alz-010-aks-lz
alz-010-aks-blu
alz-010-aks-grn
alz-020-front-door
