############################################
# STRING VARIABLE
# Used for text values like region, names
############################################
variable "location" {
  type    = string
  # Azure region where resources will be created
  default = "centralindia"
}

############################################
# NUMBER VARIABLE
# Used for numeric values (size, count, ports)
############################################
variable "disk_size_gb" {
  type    = number
  # OS disk size in GB for the VM
  default = 30
}

############################################
# BOOLEAN VARIABLE
# Used for true / false decisions
############################################
variable "enable_public_ip" {
  type    = bool
  # If true → create Public IP
  # If false → no Public IP
  default = true
}

############################################
# LIST VARIABLE
# Ordered collection, index starts from 0
# All values must be same type (string)
############################################
variable "zones" {
  type    = list(string)
  # Availability Zones where VM can be deployed
  # zones[0] = "1", zones[1] = "2"
  default = ["1", "2"]
}

############################################
# MAP VARIABLE
# Key → Value pairs
# All values must be same type (string)
############################################
variable "vm_sizes" {
  type = map(string)

  # Environment-based VM sizes
  # dev  → Standard_B1s
  # prod → Standard_B2s
  default = {
    dev  = "Standard_B1s"
    prod = "Standard_B2s"
  }
}

############################################
# SET VARIABLE
# Similar to list but NO DUPLICATE values
# Order is NOT guaranteed
############################################
variable "allowed_ports" {
  type    = set(number)
  # NSG allowed inbound ports
  # Duplicate ports are NOT allowed in a set
  default = [22, 80, 443]
}

############################################
# OBJECT VARIABLE
# Used to group related attributes
# Can mix multiple data types
############################################
variable "vm_config" {
  type = object({
    name  = string  # VM name
    admin = string  # Admin username
    env   = string  # Environment (dev / prod)
  })

  # Complete VM configuration
  default = {
    name  = "tfvm01"
    admin = "azureuser"
    env   = "dev"
  }
}

############################################
# TUPLE VARIABLE
# Fixed order + fixed data types
# Index-based access only
############################################
variable "os_image" {
  type = tuple([
    string, # publisher
    string, # offer
    string, # sku
    string  # version
  ])

  # OS image definition in fixed order
  # os_image[0] → publisher
  # os_image[1] → offer
  # os_image[2] → sku
  # os_image[3] → version
  default = [
    "Canonical",
    "0001-com-ubuntu-server-jammy",
    "22_04-lts",
    "latest"
  ]
}

