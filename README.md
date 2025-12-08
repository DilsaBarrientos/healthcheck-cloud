# HealthCheck Cloud

Sistema de monitoreo de salud de servicios web que permite agregar servicios, realizar health checks automáticos, visualizar métricas y recibir alertas cuando un servicio está caído.

## Arquitectura

- **Frontend**: React.js alojado en S3 (Static Website Hosting)
- **Backend**: Python Flask en EC2
- **API Gateway**: Proxy HTTP a EC2
- **Base de Datos**: DynamoDB (Services, HealthChecks, Alerts)
- **Serverless**: Lambda functions para health checks automáticos y procesamiento S3
- **Monitoreo**: CloudWatch Dashboard y Alarmas
- **Alertas**: SNS para notificaciones por email

## Ejecución Local

### Prerrequisitos

- Docker y Docker Compose
- AWS CLI configurado (para crear tablas en DynamoDB Local)

### Pasos

1. **Crear tablas en DynamoDB Local**:
   ```bash
   ./scripts/setup-dynamodb-local.sh
   ```

2. **Iniciar servicios con Docker Compose**:
   ```bash
   docker-compose --profile local up
   ```

3. **Acceder a la aplicación**:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:5000

4. **Detener servicios**:
   ```bash
   docker-compose --profile local down
   ```

## Despliegue en AWS con Terraform

### Prerrequisitos

- Terraform >= 1.0
- AWS CLI configurado con credenciales
- Ansible (para despliegue automático)
- Key Pair de EC2 creado en AWS

### Variables Requeridas

Crea `infrastructure/terraform/terraform.tfvars` basado en `terraform.tfvars.example`:

```hcl
aws_region   = "us-east-1"
project_name = "healthcheck-cloud"
ec2_key_name = "tu-key-pair-name"  # Key Pair existente en AWS
alert_email  = "tu-email@ejemplo.com"
```

### Despliegue

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

Terraform creará toda la infraestructura y ejecutará Ansible automáticamente para desplegar el backend en EC2 y el frontend en S3.

### Outputs

Después del despliegue, obtén las URLs:

```bash
terraform output s3_website_url    # URL del frontend
terraform output api_gateway_url  # URL de la API
```

### Destruir Infraestructura

```bash
terraform destroy
```

## Estructura del Proyecto

```
.
├── backend/              # Backend Python Flask
├── frontend/             # Frontend React.js
├── lambda/               # Funciones Lambda
├── infrastructure/
│   ├── terraform/        # Infraestructura como Código
│   └── ansible/          # Despliegue automático
├── scripts/              # Scripts de utilidad
└── docker-compose.yml   # Configuración local
```

## Tecnologías

- **Backend**: Python, Flask, Gunicorn, boto3
- **Frontend**: React.js, Chart.js, Axios
- **Infraestructura**: Terraform, Ansible
- **AWS Services**: EC2, S3, API Gateway, Lambda, DynamoDB, CloudWatch, SNS, VPC
