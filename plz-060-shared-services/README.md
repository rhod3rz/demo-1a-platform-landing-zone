# Platform Landing Zone - Shared Services Repo

## 1. Repo Structure, Azure DevOps and Branching Strategy
---

The repo follows the standards documented in 000-tfstate-bootstrap.

## 2. Shared Services Repo
---

### 2.1 Summary

This repo deploys the Platform Landing Zone shared services components.

### 2.2 Components

The following components are deployed via this repo.  
See the **[environment]-[region].tfvars** file for full configuration details.

- Resources Groups
- Route Tables
- Network Security Groups
- Virtual Networks and Subnets
- Virtual Network Peerings
- Private EndPoints
- Dev Center & Managed DevOps Pools
- Diagnostic Virtual Machines (Optional)

### 2.3 Exceptions

None
