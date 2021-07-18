# Terraform repository for managing the Azure Infrastructure

References for Terraform documentation
* [Terraform Website](https://www.terraform.io)
* [AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)
* [AzureRM Provider Usage Examples](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples)


## Overview
This repository contains the Terraform configuration files for Azure resource creation. This will alllow the cloud support team to create, modify, destroy Azure resources while collaborating same set of Terraform templates. 
Below folder structure is designed to isolate different resouces and ensure maximum reuse of Terraform cord across all the templates.

**global**				= Common underline infrastructure that going to be shared with many other resources. Examples - vnet, image gallery, Azure Container Registry, Key Vault, etc  
**mgmt**				= Active Directory, user and group acces management, etc  
**prod**				= Production resources. Examples - webapp, mssql db, etc  
**stage**				= Development/QA resouces. Examples - vm, webapp, mssql db, etc  
**data-sources**		= Details about shared resources. For an exmaple, while creating virtual machines, image gallery details and os image version can be obtained from here. Refer the document inside this folder for more details.


## Usage Guide
create a variable file terraform.tfvars withe below login details for Azure. If you run the terraform without these parameters, it will prompt for those values everytime you run it. Please note below example has some bogus values,
you will need to use what is relevent to your system.
```

subscription_id = "81e9c123230-7f32-4b7e-9c7e-0a9425db123123"  
client_id       = "933e1232ba-7174-454d-9045-b09001231395eb"  
client_secret   = "c91c4d1232-c88f-4f27-9167-994132a123324d5"  
tenant_id       = "fbe7f12320-be31-4562-95c6-a4da712323e187b"  

```
### TBD

Further [usage documentation is available on the Terraform website](https://www.terraform.io/docs/providers/azurerm/index.html).

