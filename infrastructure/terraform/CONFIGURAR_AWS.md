# Configurar Credenciales de AWS

## Verificar Cuenta Actual

```bash
aws sts get-caller-identity
```

## Configurar Credenciales

### Opción 1: Usar `aws configure` (Recomendado)

```bash
aws configure
```

Te pedirá:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (ej: us-east-1)
- Default output format (json)

### Opción 2: Usar Variables de Entorno

```bash
export AWS_ACCESS_KEY_ID=tu-access-key
export AWS_SECRET_ACCESS_KEY=tu-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

### Opción 3: Usar Perfiles Múltiples

Si tienes múltiples cuentas, puedes usar perfiles:

```bash
# Configurar un perfil
aws configure --profile nombre-perfil

# Usar el perfil
export AWS_PROFILE=nombre-perfil

# O en Terraform
export AWS_PROFILE=nombre-perfil
terraform apply
```

### Opción 4: Archivo de Credenciales Manual

Editar `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = TU_ACCESS_KEY
aws_secret_access_key = TU_SECRET_KEY

[otra-cuenta]
aws_access_key_id = OTRA_ACCESS_KEY
aws_secret_access_key = OTRA_SECRET_KEY
```

Y en `~/.aws/config`:

```ini
[default]
region = us-east-1

[profile otra-cuenta]
region = us-east-1
```

Luego usar:
```bash
export AWS_PROFILE=otra-cuenta
```

## Verificar Key Pairs en la Cuenta

```bash
# Listar todos los Key Pairs
aws ec2 describe-key-pairs --region us-east-1

# Ver solo los nombres
aws ec2 describe-key-pairs --region us-east-1 --query 'KeyPairs[*].KeyName' --output table
```

## Importante

- Las credenciales se guardan en `~/.aws/credentials` y `~/.aws/config`
- Terraform usa las credenciales de AWS CLI automáticamente
- Si cambias de cuenta, verifica que el Key Pair exista en esa cuenta

