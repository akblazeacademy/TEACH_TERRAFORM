# ==========================
# RESOURCE GROUPS USING COUNT
# ==========================
resource "azurerm_resource_group" "count_rg" {
  count    = var.count_rg_count
  name     = "rg-count-${count.index}"
  location = "Central US"
}

# ==========================
# RESOURCE GROUPS USING FOR_EACH
# ==========================
resource "azurerm_resource_group" "foreach_rg" {
  for_each = var.foreach_rgs

  name     = "rg-${each.key}"
  location = each.value
}
