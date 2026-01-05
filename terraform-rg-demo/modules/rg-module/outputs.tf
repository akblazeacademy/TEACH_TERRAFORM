output "count_rgs" {
  value = azurerm_resource_group.count_rg[*].name
}

output "foreach_rgs" {
  value = keys(azurerm_resource_group.foreach_rg)
}
