provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${terraform.workspace}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}-${terraform.workspace}"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
