# Platform Landing Zone - Hub Repo

## 1. Repo Structure, Azure DevOps and Branching Strategy
---

The repo follows the standards documented in 000-tfstate-bootstrap.

## 2. Hub Repo
---

### 2.1 Summary

This repo deploys the Platform Landing Zone hub components.

### 2.2 Components

The following components are deployed via this repo.  
See the **[environment]-[region].tfvars** file for full configuration details.

- Resources Groups
- Route Tables
- Network Security Groups
- Virtual Networks and Subnets
- Virtual Network Peerings
- Private DNS Zones
- Jump Box Virtual Machines

### 2.3 Exceptions

None
