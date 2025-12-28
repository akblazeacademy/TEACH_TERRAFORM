#!/bin/bash
set -e

LAB_DIR="$HOME/var-priority-lab"

echo "======================================"
echo "Terraform Variable Priority Lab Setup"
echo "======================================"

# ------------------------------
# 1. Create lab directory
# ------------------------------
echo "[1] Creating lab directory..."
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

# ------------------------------
# 2. variables.tf (declaration only)
# ------------------------------
echo "[2] Creating variables.tf..."
cat <<EOF > variables.tf
variable "filename" {
  type = string
}
EOF

# ------------------------------
# 3. main.tf (uses variable)
# ------------------------------
echo "[3] Creating main.tf..."
cat <<EOF > main.tf
resource "local_file" "demo" {
  filename = var.filename
  content  = "Terraform variable priority proof"
}
EOF

# ------------------------------
# 4. terraform.tfvars (auto-loaded)
# ------------------------------
echo "[4] Creating terraform.tfvars..."
cat <<EOF > terraform.tfvars
filename = "/tmp/from-terraform-tfvars.txt"
EOF

# ------------------------------
# 5. auto-loaded tfvars
# ------------------------------
echo "[5] Creating a.auto.tfvars..."
cat <<EOF > a.auto.tfvars
filename = "/tmp/from-auto-tfvars.txt"
EOF

# ------------------------------
# 6. custom tfvars (manual load)
# ------------------------------
echo "[6] Creating tx.tfvars..."
cat <<EOF > tx.tfvars
filename = "/tmp/from-tx-tfvars.txt"
EOF

echo
echo "======================================"
echo "SETUP COMPLETE"
echo "======================================"
echo "Next steps (run manually):"
echo "  terraform init"
echo "  terraform apply"
echo "  terraform apply -var-file=tx.tfvars"
echo "  terraform apply -var=\"filename=/tmp/from-cli.txt\""
echo

