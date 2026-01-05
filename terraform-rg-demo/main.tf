provider "azurerm" {
  features {}
}

module "rg_module" {
  source = "./modules/rg-module"

  count_rg_count = var.count_rg_count
  foreach_rgs    = var.foreach_rgs
}
