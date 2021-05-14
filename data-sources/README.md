# Terraform repository for managing the Azure Infrastructure

Version 2.0 of the AzureRM Provider requires Terraform 0.12.x and later.

* [Terraform Website](https://www.terraform.io)
* [AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)
* [AzureRM Provider Usage Examples](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples)
*

## Overview
This repository contains the Terraform configuration files for Azure resource creation. This will alllow the cloud support team to create, modify, destroy Azure resources while collaborating same set of Terraform templates. 
Below folder structure is designed to isolate different resouces and ensure maximum reuse of Terraform cord across all the templates.

global				= Common underline infrastructure that going to be shared with many other resources. Examples - vnet, image gallery, Azure Container Registry, Key Vault, etc
mgmt				= Active Directory, user and group acces management, etc
prod				= Production resources. Examples - webapp, mssql db, etc
stage				= Development/QA resouces. Examples - vm, webapp, mssql db, etc
data-sources		= Details about shared resources. For an exmaple, while creating virtual machines, image gallery details and os image version can be obtained from here. Refer the document inside this folder for more details.


## Usage Example

```
# Configure the Microsoft Azure Provider
provider "azurerm" {
  # We recommend pinning to the specific version of the Azure Provider you're using
  # since new versions are released frequently
  version = "=2.0.0"

  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # http://terraform.io/docs/providers/azurerm/index.html

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "production-resources"
  location = "West US"
}

# Create a virtual network in the production-resources resource group
resource "azurerm_virtual_network" "test" {
  name                = "production-network"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  address_space       = ["10.0.0.0/16"]
}
```

Further [usage documentation is available on the Terraform website](https://www.terraform.io/docs/providers/azurerm/index.html).

