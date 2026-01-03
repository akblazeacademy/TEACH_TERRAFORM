provider "azurerm" {
  features {}
}

module "vnets" {
  source = "./modules/vnets"

  vneta_name    = var.vneta_name
  vneta_rg_name = var.vneta_rg_name

  vnetb_name    = var.vnetb_name
  vnetb_rg_name = var.vnetb_rg_name
}
