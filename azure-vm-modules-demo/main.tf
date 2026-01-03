module "vm" {
  source = "./modules/vm"

  vm_name        = var.vm_name
  location       = var.location
  admin_username = var.admin_username
  admin_password = var.admin_password
}
