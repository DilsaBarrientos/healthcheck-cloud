#!/bin/bash
# Script para crear tablas en DynamoDB Local

ENDPOINT_URL="http://localhost:8000"

echo "Creando tablas en DynamoDB Local..."

# Crear tabla Services
echo "Creando tabla Services..."
aws dynamodb create-table \
  --table-name Services \
  --attribute-definitions AttributeName=serviceId,AttributeType=S \
  --key-schema AttributeName=serviceId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url $ENDPOINT_URL \
  2>/dev/null || echo "Tabla Services ya existe o error al crearla"

# Crear tabla HealthChecks
echo "Creando tabla HealthChecks..."
aws dynamodb create-table \
  --table-name HealthChecks \
  --attribute-definitions \
    AttributeName=serviceId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=serviceId,KeyType=HASH \
    AttributeName=timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url $ENDPOINT_URL \
  2>/dev/null || echo "Tabla HealthChecks ya existe o error al crearla"

# Crear tabla Alerts
echo "Creando tabla Alerts..."
aws dynamodb create-table \
  --table-name Alerts \
  --attribute-definitions \
    AttributeName=alertId,AttributeType=S \
    AttributeName=serviceId,AttributeType=S \
  --key-schema \
    AttributeName=alertId,KeyType=HASH \
    AttributeName=serviceId,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url $ENDPOINT_URL \
  2>/dev/null || echo "Tabla Alerts ya existe o error al crearla"

echo ""
echo "Verificando tablas creadas..."
aws dynamodb list-tables --endpoint-url $ENDPOINT_URL

echo ""
echo "Setup completado!"


