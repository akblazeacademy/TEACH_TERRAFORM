provider "azurerm" {
  features {}
}

module "network" {
  source   = "./modules/network"
  rg_name  = "rg-output-demo"
  location = "Central US"
}

module "vm" {
  source              = "./modules/vm"
  location            = "Central US"
  resource_group_name = module.network.resource_group_name
  subnet_id           = module.network.subnet_id
}
