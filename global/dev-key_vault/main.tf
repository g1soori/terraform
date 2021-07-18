module "core_modules" {
  source = "../../data-sources/"
}

terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    key                   = "key_vault.tfstate"
  }
}

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "example" {
  name                        = "keyvault-test-build"
  location                    = var.location
  resource_group_name         = module.core_modules.core_rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false
  enabled_for_template_deployment = true
  enabled_for_deployment      = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "deleteissuers",
      "get",
      "getissuers",
      "import",
      "list",
      "listissuers",
      "managecontacts",
      "manageissuers",
      "setissuers",
      "update",
    ]

    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "restore",
      "set",
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    env = "dev"
    app = "app1"
    owner = "jeewan"
  }
}


# Creating the Key by importing the SSH private key 
resource "azurerm_key_vault_secret" "test_build" {
  name         = "prikey-test-build"
  value        = base64encode(file("/root/.ssh/id_rsa"))
  key_vault_id = azurerm_key_vault.example.id

  tags = {
    env = "dev"
    app = "app1"
    owner = "jeewan"
  }
}
