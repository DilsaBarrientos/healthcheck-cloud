# Terraform - Infrastructure as Code

Infraestructura completa de HealthCheck Cloud en AWS.

## Estructura

```
terraform/
├── main.tf              # Configuración principal
├── variables.tf         # Variables
├── outputs.tf           # Outputs
├── terraform.tfvars.example  # Ejemplo de variables
└── modules/
    ├── vpc/             # VPC y networking
    ├── dynamodb/        # Tablas DynamoDB
    ├── iam/             # Roles IAM
    ├── ec2/             # Instancia EC2
    ├── s3/              # Bucket S3
    ├── api_gateway/     # API Gateway
    ├── lambda/          # Funciones Lambda
    └── sns/             # SNS para alertas
```

## Uso

### 1. Configurar variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Planificar cambios

```bash
terraform plan
```

### 4. Aplicar (ejecuta Ansible automáticamente)

```bash
terraform apply
```

**Nota**: Terraform ejecutará Ansible automáticamente después de crear la infraestructura:
- Despliega el backend a EC2
- Build y despliega el frontend a S3

### 5. Ver outputs

```bash
terraform output
```

## Variables Requeridas

Antes de ejecutar `terraform apply`, debes configurar estas variables en `terraform.tfvars`:

### 1. `ec2_key_name` (REQUERIDO)
Nombre del Key Pair de EC2 que ya tienes creado en AWS.

**Cómo obtenerlo:**
- Ve a AWS Console > EC2 > Key Pairs
- Si no tienes uno, crea uno nuevo (tipo: RSA, formato: .pem)
- Copia el nombre exacto del Key Pair

**Ejemplo:**
```hcl
ec2_key_name = "my-ec2-key-pair"
```

### 2. `alert_email` (REQUERIDO)
Email donde recibirás alertas cuando un servicio esté caído.

**Ejemplo:**
```hcl
alert_email = "admin@example.com"
```

### Variables Opcionales (tienen valores por defecto)

- `aws_region`: Región de AWS (default: `us-east-1`)
- `project_name`: Nombre del proyecto (default: `healthcheck-cloud`)
- `vpc_cidr`: CIDR block para VPC (default: `10.0.0.0/16`)

## Destruir Infraestructura

```bash
terraform destroy
```

