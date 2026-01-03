#!/bin/bash

set -e

LAB_DIR="azure-vm-variables-lab"

echo "Creating lab directory..."
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

echo "Creating variables.tf..."
cat << 'EOF' > variables.tf
variable "location" {
  type    = string
  default = "centralindia"
}

variable "disk_size_gb" {
  type    = number
  default = 30
}

variable "enable_public_ip" {
  type    = bool
  default = true
}

variable "zones" {
  type    = list(string)
  default = ["1", "2"]
}

variable "vm_sizes" {
  type = map(string)
  default = {
    dev  = "Standard_B1s"
    prod = "Standard_B2s"
  }
}

variable "allowed_ports" {
  type    = set(number)
  default = [22, 80, 443]
}

variable "vm_config" {
  type = object({
    name  = string
    admin = string
    env   = string
  })

  default = {
    name  = "tfvm01"
    admin = "azureuser"
    env   = "dev"
  }
}

variable "os_image" {
  type = tuple([string, string, string, string])
  default = [
    "Canonical",
    "0001-com-ubuntu-server-jammy",
    "22_04-lts",
    "latest"
  ]
}
EOF

echo "Creating main.tf..."
cat << 'EOF' > main.tf
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "\${var.vm_config.name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "vm-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.allowed_ports
    content {
      name                       = "allow-\${security_rule.value}"
      priority                   = 100 + security_rule.value
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_config.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_sizes[var.vm_config.env]
  admin_username      = var.vm_config.admin
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.nic.id]
  zones               = var.zones

  admin_ssh_key {
    username   = var.vm_config.admin
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = var.os_image[0]
    offer     = var.os_image[1]
    sku       = var.os_image[2]
    version   = var.os_image[3]
  }
}
EOF

echo "Creating terraform.tfvars (optional overrides)..."
cat << 'EOF' > terraform.tfvars
# Example overrides
# enable_public_ip = false
# disk_size_gb     = 64

# vm_config = {
#   name  = "tfvm-prod"
#   admin = "azureuser"
#   env   = "prod"
# }
EOF

echo "✅ Azure VM Terraform lab files created successfully"
ls -l

