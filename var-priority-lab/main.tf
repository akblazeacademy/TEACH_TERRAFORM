resource "local_file" "demo" {
  filename = var.filename
  content  = "Terraform variable priority proof"
}
