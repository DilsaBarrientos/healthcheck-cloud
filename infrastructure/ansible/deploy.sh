#!/bin/bash
# Script principal para desplegar con Ansible usando outputs de Terraform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"
ANSIBLE_DIR="${SCRIPT_DIR}"

echo "🚀 Iniciando despliegue automatizado..."

# 1. Exportar outputs de Terraform
echo "📤 Exportando outputs de Terraform..."
cd "${TERRAFORM_DIR}"
terraform output -json > terraform-outputs.json
cd "${ANSIBLE_DIR}"

# 2. Verificar que el inventory script es ejecutable
chmod +x "${ANSIBLE_DIR}/inventory/terraform_inventory.sh"

# 3. Verificar que jq está instalado (necesario para el inventory script)
if ! command -v jq &> /dev/null; then
    echo "❌ jq no está instalado. Instalando..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq || sudo yum install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    fi
fi

# 4. Ejecutar playbook de backend
echo "🔧 Desplegando backend a EC2..."
ansible-playbook playbooks/backend.yml -v

# 5. Ejecutar playbook de frontend
echo "🎨 Build y despliegue del frontend a S3..."
ansible-playbook playbooks/frontend.yml -v

echo "✅ Despliegue completado!"
echo ""
echo "📋 URLs:"
cd "${TERRAFORM_DIR}"
API_URL=$(terraform output -raw api_gateway_url)
S3_BUCKET=$(terraform output -raw s3_bucket_name)
EC2_IP=$(terraform output -raw ec2_public_ip)

echo "  Frontend: http://${S3_BUCKET}.s3-website-us-east-1.amazonaws.com"
echo "  API Gateway: ${API_URL}"
echo "  Backend Directo: http://${EC2_IP}:5000"

