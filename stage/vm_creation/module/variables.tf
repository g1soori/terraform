variable "resource_grp" {
  type              = string  
  description       = "rg"
  default           = "aks"
}

variable "location" {
  type              = string  
  description       = "location of rg"
  default           = "eastus"
}

variable "resource_prefix" {
  type        = string
  description = "prefix"
  default     = "aks"
}

variable "vm_size" {
  type        = string
  description = "vm size"
  default     = "Standard_B2s"
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "server_count" {
  type        = number
  description = "No of servers to be created"
}

variable "subnet_id" {
  type        = string
  description = "No of servers to be created"
}

variable "core_rg_name" {
  type        = string
  description = "No of servers to be created"
}

variable "admin_secret" {
  type        = string
  description = "No of servers to be created"
}

# variable "image_id" {
#   type        = string
#   description = "No of servers to be created"
# }