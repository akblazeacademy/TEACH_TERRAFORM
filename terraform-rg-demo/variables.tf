variable "count_rg_count" {
  description = "Number of RGs created using count"
  type        = number
}

variable "foreach_rgs" {
  description = "Map of RGs created using for_each"
  type        = map(string)
}
