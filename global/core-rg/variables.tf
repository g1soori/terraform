provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    features {}
}

variable "subscription_id" {
    description = "Enter subscription_id"
}

variable "client_id" {
    description = "Enter client_id"
}

variable "client_secret" {
    description = "Enter client_secret"
}

variable "tenant_id" {
    description = "Enter tenant_id"
}

variable "resource_grp" {
  type              = string  
  description       = "rg"
}

variable "location" {
  type              = string  
  description       = "location of rg"
}

variable "resource_prefix" {
  type        = string
  description = "prefix"
}