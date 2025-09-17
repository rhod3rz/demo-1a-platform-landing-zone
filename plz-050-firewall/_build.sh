27/05/2025 - Final :-)

# 1. build locally.
# 2. switch to ado pipeline once built locally.
# 3. switch to mdp pipeline once mdp created & update to private endpoints (if any).

tenant      73578441-dc3d-4ecd-a298-fc5c6f40e191
conn_prd_01 6e71165a-aad7-4b08-ba1b-628e397e4b18

# run once  = start with 'nat_rule_collection = null'
# run twice = once pip is known; update 'rcg-nteu-northsouth-dnat.csv', update 'nat_rule_collection = null' and run again.

# NORTH - prd
# login as sp_conn_prd_01
terraform init -reconfigure `
  -backend-config="resource_group_name=rg-prd-nteu-tfstate" `
  -backend-config="storage_account_name=sardzprdnteutfstate" `
  -backend-config="container_name=plz-050-firewall" `
  -backend-config="key=prd-nteu.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/prd/nteu/prd-nteu.tfvars"
terraform apply -var-file="environments/prd/nteu/prd-nteu.tfvars" -auto-approve
terraform destroy -var-file="environments/prd/nteu/prd-nteu.tfvars"

# -- STOP -- #
# Firewall.
Connect-AzAccount -TenantId "73578441-dc3d-4ecd-a298-fc5c6f40e191"
Set-AzContext -SubscriptionId "6e71165a-aad7-4b08-ba1b-628e397e4b18"
# north
$azfw = Get-AzFirewall -Name "fw-nonprod-nteu-01" -ResourceGroupName "rg-nonprod-nteu-hub"
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw
# AKS.
Set-AzContext -SubscriptionId "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
Stop-AzAksCluster -ResourceGroupName "rg-nonprod-nteu-aks-blu" -Name "aks-nonprod-nteu-blu-01"

# -- START -- #
# Firewall.
Connect-AzAccount -TenantId "73578441-dc3d-4ecd-a298-fc5c6f40e191"
Set-AzContext -SubscriptionId "6e71165a-aad7-4b08-ba1b-628e397e4b18"
# north
$azfw = Get-AzFirewall -Name "fw-nonprod-nteu-01" -ResourceGroupName "rg-nonprod-nteu-hub"
$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-nonprod-nteu-hub" -Name "vnet-nonprod-nteu-hub-01"
$pip = Get-AzPublicIpAddress -ResourceGroupName "rg-nonprod-nteu-hub" -Name "fw-nonprod-nteu-01-pip"
$pipMgmt = Get-AzPublicIpAddress -ResourceGroupName "rg-nonprod-nteu-hub" -Name "fw-nonprod-nteu-01-pip-mgmt"
$azfw.Allocate($vnet, $pip, $pipMgmt)
$azfw | Set-AzFirewall
# AKS.
Set-AzContext -SubscriptionId "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
Start-AzAksCluster -ResourceGroupName "rg-dev-nteu-aks-blu" -Name "aks-dev-nteu-blu-01"

# firewall / network troubleshooting
sudo apt update && sudo apt install traceroute hping3 -y
# testing north/south
ip a
ping 8.8.8.8 > does not work via azure default internet access without a public ip attached
curl -s http://ifconfig.me         # lists ip
curl -s https://ifconfig.me        # lists ip
curl -s http://example.com         # return web content
curl -s https://example.com        # return web content
sudo hping3 -S portquiz.net -p 80  # tests a port
sudo hping3 -S portquiz.net -p 443 # tests a port
# testing east/west
