terraform {
  backend "azurerm" {
    resource_group_name  = "myprimary"
    storage_account_name = "stgblaze"
    container_name       = "statefile"
    key                  = "import-lab.tfstate"
  }
}

