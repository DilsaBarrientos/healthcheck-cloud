# Lambda Functions

Funciones Lambda esenciales para el proyecto.

## Estructura

```
lambda/
├── healthcheck-monitor/        # Health checks automáticos
├── healthcheck-s3-processor/   # Procesamiento de eventos S3
└── README.md
```

## Funciones

### healthcheck-monitor

Realiza health checks automáticos a todos los servicios registrados.

- Trigger: CloudWatch Events (cada 5 minutos)
- Runtime: Python 3.9+
- Permisos: DynamoDB (read/write), SNS (publish), CloudWatch Logs

### healthcheck-s3-processor

Procesa eventos cuando se suben archivos a S3. Cumple requisito Módulo 3: Evento de almacenamiento (S3)

- Trigger: S3 ObjectCreated event
- Runtime: Python 3.9+
- Permisos: S3 (read), DynamoDB (write), CloudWatch Logs

## Despliegue

### Opción 1: AWS Console

1. Crear función Lambda en AWS Console
2. Subir código desde el directorio correspondiente
3. Configurar trigger:
   - healthcheck-monitor: CloudWatch Events (cron: `rate(5 minutes)`)
   - healthcheck-s3-processor: S3 bucket event
4. Configurar IAM Role con permisos necesarios

### Opción 2: AWS CLI

1. Crear paquete ZIP:
```bash
cd healthcheck-monitor
zip -r function.zip lambda_function.py
```

2. Crear función:
```bash
aws lambda create-function \
  --function-name healthcheck-monitor \
  --runtime python3.9 \
  --role arn:aws:iam::account-id:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip
```

3. Configurar trigger CloudWatch Events:
```bash
aws events put-rule \
  --name healthcheck-schedule \
  --schedule-expression "rate(5 minutes)"

aws lambda add-permission \
  --function-name healthcheck-monitor \
  --statement-id allow-cloudwatch \
  --action lambda:InvokeFunction \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:region:account:rule/healthcheck-schedule

aws events put-targets \
  --rule healthcheck-schedule \
  --targets "Id=1,Arn=arn:aws:lambda:region:account:function:healthcheck-monitor"
```

## Configuración

### Variables de Entorno

Configurar en cada función Lambda:

- `SERVICES_TABLE`: Nombre de la tabla Services (default: Services)
- `CHECKS_TABLE`: Nombre de la tabla HealthChecks (default: HealthChecks)
- `ALERTS_TABLE`: Nombre de la tabla Alerts (default: Alerts)
- `SNS_TOPIC_ARN`: ARN del topic SNS para alertas (solo healthcheck-monitor)

### IAM Role

El IAM Role debe tener permisos para:

- DynamoDB: Read/Write en las tablas del proyecto
- SNS: Publish al topic de alertas (solo healthcheck-monitor)
- S3: GetObject en el bucket configurado (solo healthcheck-s3-processor)
- CloudWatch Logs: Write logs

## Testing

Probar función manualmente desde AWS Console:

1. Ir a la función Lambda
2. Click en "Test"
3. Crear evento de prueba
4. Ejecutar y revisar logs
