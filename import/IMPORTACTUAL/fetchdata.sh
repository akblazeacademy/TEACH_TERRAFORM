#!/bin/bash
set -e

# ==============================
# USER INPUT
# ==============================
RESOURCE_GROUP="rg-lifecycle-demo"
VM_NAME="vm-demo"

# ==============================
# FETCH VM DATA
# ==============================

echo "🔍 Fetching VM details from Azure..."
echo "----------------------------------"

LOCATION=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "location" -o tsv)
VM_SIZE=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "hardwareProfile.vmSize" -o tsv)
ADMIN_USERNAME=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query "osProfile.adminUsername" -o tsv)

NIC_ID=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "networkProfile.networkInterfaces[0].id" -o tsv)

OS_DISK_NAME=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "storageProfile.osDisk.name" -o tsv)

OS_DISK_TYPE=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "storageProfile.osDisk.managedDisk.storageAccountType" -o tsv)

IMAGE_PUBLISHER=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "storageProfile.imageReference.publisher" -o tsv)

IMAGE_OFFER=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "storageProfile.imageReference.offer" -o tsv)

IMAGE_SKU=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "storageProfile.imageReference.sku" -o tsv)

IMAGE_VERSION=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" \
  --query "storageProfile.imageReference.version" -o tsv)

# ==============================
# OUTPUT FOR terraform.tfvars
# ==============================

echo
echo "📄 COPY BELOW INTO terraform.tfvars"
echo "----------------------------------"

cat <<EOF
rg_name  = "$RESOURCE_GROUP"
location = "$LOCATION"

vm_name        = "$VM_NAME"
vm_size        = "$VM_SIZE"
admin_username = "$ADMIN_USERNAME"

nic_id = "$NIC_ID"

os_disk_name         = "$OS_DISK_NAME"
storage_account_type = "$OS_DISK_TYPE"

image_publisher = "$IMAGE_PUBLISHER"
image_offer     = "$IMAGE_OFFER"
image_sku       = "$IMAGE_SKU"
image_version   = "$IMAGE_VERSION"
EOF

echo
echo "✅ Done."

