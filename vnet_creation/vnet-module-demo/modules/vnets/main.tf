resource "azurerm_resource_group" "vneta_rg" {
  name     = var.vneta_rg_name
  location = "Central US"
}

resource "azurerm_resource_group" "vnetb_rg" {
  name     = var.vnetb_rg_name
  location = "Central US"
}

resource "azurerm_virtual_network" "vneta" {
  name                = var.vneta_name
  location            = azurerm_resource_group.vneta_rg.location
  resource_group_name = azurerm_resource_group.vneta_rg.name

  address_space = ["10.10.0.0/16"]
}

resource "azurerm_virtual_network" "vnetb" {
  name                = var.vnetb_name
  location            = azurerm_resource_group.vnetb_rg.location
  resource_group_name = azurerm_resource_group.vnetb_rg.name

  address_space = ["10.20.0.0/16"]
}
