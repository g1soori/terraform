terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    key                   = "terraform-imagegallery.tfstate"
  }
}

resource "azurerm_resource_group" "image_tr" {
    name            = var.resource_grp
    location        = var.location

}

resource "azurerm_shared_image_gallery" "image_tr" {
  name                = "image_gallery"
  resource_group_name = azurerm_resource_group.image_tr.name
  location            = azurerm_resource_group.image_tr.location
}

resource "azurerm_shared_image" "image_tr" {
  name                = "myImageDefinition"
  gallery_name        = azurerm_shared_image_gallery.image_tr.name
  resource_group_name = azurerm_resource_group.image_tr.name
  location            = azurerm_resource_group.image_tr.location
  os_type             = "Linux"

  identifier {
    publisher = "myPublisher"
    offer     = "myOffer"
    sku       = "mySKU"
  }
}

resource "azurerm_shared_image_version" "image_tr" {
  name                = "1.0.0"
  gallery_name        = azurerm_shared_image.image_tr.gallery_name
  image_name          = azurerm_shared_image.image_tr.name
  resource_group_name = azurerm_shared_image.image_tr.resource_group_name
  location            = azurerm_shared_image.image_tr.location
  managed_image_id    = "/subscriptions/81e9cde0-7f32-4b7e-9c7e-0a9425db18f2/resourceGroups/lab6-resources/providers/Microsoft.Compute/images/linux-image"

  target_region {
    name                   = azurerm_shared_image.image_tr.location
    regional_replica_count = "1"
    storage_account_type   = "Standard_LRS"
  }
}