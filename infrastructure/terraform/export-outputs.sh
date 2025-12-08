#!/bin/bash
# Script para exportar outputs de Terraform a formato JSON para Ansible

cd "$(dirname "$0")"

# Exportar outputs de Terraform a JSON
terraform output -json > terraform-outputs.json

echo "Outputs exportados a terraform-outputs.json"
cat terraform-outputs.json


