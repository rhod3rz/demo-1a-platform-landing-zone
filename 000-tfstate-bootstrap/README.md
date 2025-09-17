# Repo Documentation
---

## Summary
---

This repo deploys the foundational building blocks required by Terraform; the 'Remote Terraform State' storage accounts.

NOTE:  

When you start a terraform project you don't have a remote state location. Options to create this are:
- ClickOps
- Custom Script
- Terraform (with local state files)

For this project, terraform with local state files has been chosen.  

Because this repo uses local terraform state, the pipelines are slightly different to the other project repo pipelines. The main differences being the path to the state files and some additional steps to commit the state back to the repo when the apply pipeline runs.  

## Components
---

The following components are deployed via this repo.  
See the **[environment]-[region].tfvars** file for the full configuration details e.g. environments/prd/nteu/prd-nteu.tfvars.

- Resource Groups
- Role Based Access Control
- Storage Accounts & Containers
- Storage Account Settings

Below are links to the detailed documentation:

---

- [1 - Terraform State Design](.artifacts/1-terraform-state-design.md) 🧩

- [2 - Terraform Folder & File Structure](.artifacts/2-terraform-folder-and-file-structure.md) 📁

- [3 - Azure DevOps](.artifacts/3-azure-devops.md) 🤖

- [4 - Branching Strategy](.artifacts/4-branching-strategy.md) 🌿

- [5 - Oddities Of This Repo](.artifacts/5-oddities-of-this-repo.md) 🐙
