#!/bin/bash
# Dynamic inventory script para Ansible que lee outputs de Terraform

# Obtener el directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TERRAFORM_DIR="${INFRASTRUCTURE_DIR}/terraform"
OUTPUT_FILE="${TERRAFORM_DIR}/terraform-outputs.json"

# Si no existe el archivo de outputs, generarlo
if [ ! -f "$OUTPUT_FILE" ]; then
    cd "$TERRAFORM_DIR"
    terraform output -json > terraform-outputs.json
    cd - > /dev/null
fi

# Leer outputs de Terraform
EC2_IP=$(jq -r '.ec2_public_ip.value' "$OUTPUT_FILE" 2>/dev/null)
EC2_INSTANCE_ID=$(jq -r '.ec2_instance_id.value' "$OUTPUT_FILE" 2>/dev/null)
S3_BUCKET=$(jq -r '.s3_bucket_name.value' "$OUTPUT_FILE" 2>/dev/null)
API_GATEWAY_URL=$(jq -r '.api_gateway_url.value' "$OUTPUT_FILE" 2>/dev/null)

# Generar inventory en formato JSON para Ansible
cat <<EOF
{
  "backend": {
    "hosts": ["${EC2_IP}"],
    "vars": {
      "ansible_user": "ec2-user",
      "ansible_ssh_private_key_file": "~/.ssh/devops-key.pem",
      "ec2_instance_id": "${EC2_INSTANCE_ID}",
      "s3_bucket": "${S3_BUCKET}",
      "api_gateway_url": "${API_GATEWAY_URL}"
    }
  },
  "_meta": {
    "hostvars": {
      "${EC2_IP}": {
        "ansible_user": "ec2-user",
        "ansible_ssh_private_key_file": "~/.ssh/devops-key.pem"
      }
    }
  }
}
EOF

