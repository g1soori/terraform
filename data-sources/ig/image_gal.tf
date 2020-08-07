
# Data block for Azure image gallery VM image

# data "azurerm_shared_image_version" "rhel" {
#   name                = "1.0.0"
#   image_name          = "myImageDefinition"
#   gallery_name        = "image_gallery"
#   resource_group_name = "images"
# }

# output "image_id" {
#   value       = data.azurerm_shared_image_version.rhel.id
#   description = "image"
# }