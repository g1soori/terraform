# Remote backend  configured in storage account
terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-dev-state"
    key                   = "terraform-appsvc.tfstate"
  }
  required_version = ">= 0.12"
}

resource "azurerm_resource_group" "app" {
  name     = "tailspin"
  location = var.location
}

resource "azurerm_app_service_plan" "app" {
  name                = "tailspin-appserviceplan-g1soori"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  #kind                = "Linux"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  count = var.app_count

  name                = "app-service-${var.resource_prefix}-tailspin${format("%02d",count.index+1)}"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  app_service_plan_id = azurerm_app_service_plan.app.id

  connection_string {
    name  = "tailspin-space-game-web-dev-${format("%02d",count.index+1)}"
    #name  = "DefaultConnection"
    type  = "SQLAzure"
    value = var.cs
  }

  # site_config {
  #   #dotnet_framework_version = "v4.0"
  #   scm_type                 = "GitHub"
  # }

}