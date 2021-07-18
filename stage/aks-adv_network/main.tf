terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-dev-state"
    key                   = "terraform-aks.tfstate"
  }
}

module data_src {
  source = "../../data-sources/"
}


resource "azurerm_resource_group" "aks" {
  name     = "${var.resource_prefix}-k8s-resources"
  location = var.location
}

resource "azurerm_route_table" "aks" {
  name                = "${var.resource_prefix}-routetable"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_virtual_network" "aks" {
  name                = "${var.resource_prefix}-network"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.aks.name
  address_prefixes     = ["10.1.0.0/22"]
  virtual_network_name = azurerm_virtual_network.aks.name
}

resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.aks.id
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_prefix}-k8s"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.resource_prefix}-k8s"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vm_size
    
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  # agent_pool_profile {
  #   name            = "agentpool"
  #   count           = "1"
  #   vm_size         = var.vm_size
  #   os_type         = "Linux"
  #   os_disk_size_gb = 30

  #   # Required for advanced networking
  #   vnet_subnet_id = azurerm_subnet.aks.id
  # }

  linux_profile {
    admin_username = "adminuser"

        ssh_key {
        key_data = file(var.ssh_public_key)
    }
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = "development"
  }
  
  network_profile {
    network_plugin = "azure"
  }

}
