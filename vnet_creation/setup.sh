#!/bin/bash

# ================================
# Terraform VNet Module Generator
# ================================

ROOT_DIR="vnet-module-demo"
MODULE_DIR="$ROOT_DIR/modules/vnets"

echo "📁 Creating directory structure..."
mkdir -p "$MODULE_DIR"

# -------------------------------
# Root main.tf
# -------------------------------
cat <<EOF > "$ROOT_DIR/main.tf"
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
EOF

# -------------------------------
# Root variables.tf
# -------------------------------
cat <<EOF > "$ROOT_DIR/variables.tf"
variable "vneta_name" {}
variable "vneta_rg_name" {}

variable "vnetb_name" {}
variable "vnetb_rg_name" {}
EOF

# -------------------------------
# Root terraform.tfvars
# -------------------------------
cat <<EOF > "$ROOT_DIR/terraform.tfvars"
vneta_name    = "VNETA"
vneta_rg_name = "rg-vneta"

vnetb_name    = "VNETB"
vnetb_rg_name = "rg-vnetb"
EOF

# -------------------------------
# Module variables.tf
# -------------------------------
cat <<EOF > "$MODULE_DIR/variables.tf"
variable "vneta_name" {}
variable "vneta_rg_name" {}

variable "vnetb_name" {}
variable "vnetb_rg_name" {}
EOF

# -------------------------------
# Module main.tf
# -------------------------------
cat <<EOF > "$MODULE_DIR/main.tf"
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
EOF

# -------------------------------
# Module outputs.tf
# -------------------------------
cat <<EOF > "$MODULE_DIR/outputs.tf"
output "vneta_id" {
  value = azurerm_virtual_network.vneta.id
}

output "vnetb_id" {
  value = azurerm_virtual_network.vnetb.id
}
EOF

echo "✅ Terraform VNet module structure created successfully!"
echo "📂 Go to $ROOT_DIR and run:"
echo "   terraform init"
echo "   terraform plan"
echo "   terraform apply"

