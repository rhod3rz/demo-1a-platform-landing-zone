# Platform Landing Zone - Management Logging Repo

## 1. Repo Structure, Azure DevOps and Branching Strategy
---

The repo follows the standards documented in 000-tfstate-bootstrap.

## 2. Management Logging Repo
---

### 2.1 Summary

This repo deploys the Platform Landing Zone management logging components.  
In addition it deploys storage accounts and key vaults, should they be required.

### 2.2 Components

The following components are deployed via this repo.  
See the **[environment]-[region].tfvars** file for full configuration details.

- Resource Groups
- Log Analytics Workspaces
- Managed Identities
- Solutions
- Storage Accounts
- Key Vaults

### 2.3 Exceptions

None
