module "core_modules" {
  source = "../../data-sources/"
}

terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    key                   = "key_vault-query.tfstate"
  }
}

data "azurerm_key_vault" "test_build" {
  name                = "keyvault-test-build"
  resource_group_name = "images"
}

data "azurerm_key_vault_secret" "test" {
  name         = "prikey-test-build"
  key_vault_id = data.azurerm_key_vault.test_build.id
}


resource "null_resource" "test" {
  # Set the executable permission for scripts
  provisioner "local-exec" {
    command = "echo '${data.azurerm_key_vault_secret.test.value}' | base64 -d > /tmp/private-key"
  }

}