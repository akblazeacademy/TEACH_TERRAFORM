############################################
# AZURE PROVIDER
############################################
provider "azurerm" {
  features {}
}

############################################
# RESOURCE GROUP
# Uses:
# - vm_config (object)
# - location (string)
############################################
resource "azurerm_resource_group" "rg" {
  # Object variable access:
  # var.vm_config.name → VM name from object
  name     = "${var.vm_config.name}-rg"

  # String variable
  location = var.location
}

############################################
# VIRTUAL NETWORK
# Uses:
# - location (string)
############################################
resource "azurerm_virtual_network" "vnet" {
  name                = "vm-vnet"
  address_space       = ["10.0.0.0/16"]

  # String variable
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

############################################
# SUBNET
############################################
resource "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  # Fixed CIDR block
  address_prefixes     = ["10.0.1.0/24"]
}

############################################
# PUBLIC IP
# Uses:
# - enable_public_ip (bool)
############################################
resource "azurerm_public_ip" "pip" {
  # Boolean variable decides
  # whether Public IP is created or not
  count = var.enable_public_ip ? 1 : 0

  name                = "vm-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

############################################
# NETWORK SECURITY GROUP
# Uses:
# - allowed_ports (set of numbers)
############################################
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # Dynamic block creates one rule per port
  # for_each iterates over SET variable
  dynamic "security_rule" {
    for_each = var.allowed_ports

    content {
      # Each rule name uses the port number
      name = "allow-${security_rule.value}"

      # Priority must be unique → derived from port
      priority = 100 + security_rule.value

      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"

      source_port_range      = "*"
      destination_port_range = security_rule.value
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    }
  }
}

############################################
# NETWORK INTERFACE
# Uses:
# - enable_public_ip (bool)
############################################
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

    # Conditional Public IP attachment
    # If enable_public_ip = true → attach PIP
    # If false → null
    public_ip_address_id = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null
  }
}

############################################
# LINUX VIRTUAL MACHINE
# Uses ALL variable types
############################################
resource "azurerm_linux_virtual_machine" "vm" {

  # Object variable
  name                = var.vm_config.name
  admin_username      = var.vm_config.admin

  # String variable
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  # Map variable
  # env (from object) → maps to correct VM size
  size = var.vm_sizes[var.vm_config.env]

  disable_password_authentication = true

  # NIC attachment
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  # List variable (Availability Zones)
  zones = var.zones

  ##########################################
  # SSH CONFIGURATION
  ##########################################
  admin_ssh_key {
    username   = var.vm_config.admin
    public_key = file("~/.ssh/id_rsa.pub")
  }

  ##########################################
  # OS DISK CONFIG
  # Uses number variable
  ##########################################
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  ##########################################
  # OS IMAGE
  # Uses tuple variable (fixed order)
  ##########################################
  source_image_reference {
    publisher = var.os_image[0]
    offer     = var.os_image[1]
    sku       = var.os_image[2]
    version   = var.os_image[3]
  }
}

