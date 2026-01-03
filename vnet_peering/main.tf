terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------
# Existing VNET-A (Data Source)
# -----------------------------
data "azurerm_virtual_network" "vneta" {
  name                = var.vneta_name
  resource_group_name = var.vneta_rg_name
}

# -----------------------------
# Existing VNET-B (Data Source)
# -----------------------------
data "azurerm_virtual_network" "vnetb" {
  name                = var.vnetb_name
  resource_group_name = var.vnetb_rg_name
}

# -----------------------------
# Peering: VNET-A → VNET-B
# -----------------------------
resource "azurerm_virtual_network_peering" "a_to_b" {
  name                      = "peer-${var.vneta_name}-to-${var.vnetb_name}"
  resource_group_name       = data.azurerm_virtual_network.vneta.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.vneta.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnetb.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

# -----------------------------
# Peering: VNET-B → VNET-A
# -----------------------------
resource "azurerm_virtual_network_peering" "b_to_a" {
  name                      = "peer-${var.vnetb_name}-to-${var.vneta_name}"
  resource_group_name       = data.azurerm_virtual_network.vnetb.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.vnetb.name
  remote_virtual_network_id = data.azurerm_virtual_network.vneta.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

