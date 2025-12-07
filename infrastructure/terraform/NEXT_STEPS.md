# Próximos Pasos - Despliegue Completado ✅

## Recursos Creados

- ✅ **EC2 Instance**: `i-03a571d10543484a3` (IP: 54.165.218.98)
- ✅ **API Gateway**: https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod/api
- ✅ **S3 Bucket**: `healthcheck-cloud-frontend-b3967a4e`
- ✅ **S3 Website**: http://healthcheck-cloud-frontend-b3967a4e.s3-website-us-east-1.amazonaws.com
- ✅ **DynamoDB Tables**: Services, HealthChecks, Alerts (creadas por Terraform)
- ✅ **Lambda Functions**: monitor, s3-processor
- ✅ **VPC**: vpc-07079f577bc782a36

---

## Paso 1: Verificar Backend en EC2

La instancia EC2 ya tiene Python y dependencias instaladas (por user_data), pero necesitas desplegar el código.

### Conectar a EC2

```bash
ssh -i ~/.ssh/devops-key.pem ec2-user@54.165.218.98
```

### Desplegar Código del Backend

```bash
# Dentro de EC2
cd /home/ec2-user

# Clonar tu repositorio (o subir código)
git clone https://github.com/TU-USUARIO/healthcheck-cloud.git
# O usar scp para subir el código:
# scp -r -i ~/.ssh/devops-key.pem backend/ ec2-user@54.165.218.98:/home/ec2-user/

cd healthcheck-cloud/backend

# Instalar dependencias (si no están)
pip3 install -r requirements.txt

# Probar que funciona
python3 app.py
# Debería iniciar en http://0.0.0.0:5000
```

### Configurar como Servicio Systemd

Crear `/etc/systemd/system/healthcheck-api.service`:

```ini
[Unit]
Description=HealthCheck API
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/healthcheck-cloud/backend
Environment="AWS_REGION=us-east-1"
Environment="DYNAMODB_SERVICES_TABLE=Services"
Environment="DYNAMODB_CHECKS_TABLE=HealthChecks"
Environment="DYNAMODB_ALERTS_TABLE=Alerts"
Environment="FLASK_ENV=production"
Environment="PORT=5000"
Environment="HOST=0.0.0.0"
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Habilitar y iniciar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable healthcheck-api
sudo systemctl start healthcheck-api
sudo systemctl status healthcheck-api
```

### Verificar Backend

```bash
# Desde tu máquina local
curl http://54.165.218.98:5000/health
# Debería responder: {"status":"ok","message":"HealthCheck Cloud Backend is running"}
```

---

## Paso 2: Desplegar Frontend a S3

### Build del Frontend

```bash
cd /home/dbarrientos/Documents/Finalproject/frontend

# Crear archivo .env.production con la URL de API Gateway
echo "REACT_APP_API_URL=https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod" > .env.production

# Instalar dependencias y build
npm install
npm run build
```

### Subir a S3

```bash
# Subir archivos del build
aws s3 sync build/ s3://healthcheck-cloud-frontend-b3967a4e --delete

# Verificar que se subió
aws s3 ls s3://healthcheck-cloud-frontend-b3967a4e
```

---

## Paso 3: Probar la Aplicación

### URLs de Acceso

1. **Frontend (S3 Website)**:
   http://healthcheck-cloud-frontend-b3967a4e.s3-website-us-east-1.amazonaws.com

2. **API Gateway**:
   https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod/api

3. **Backend Directo (EC2)**:
   http://54.165.218.98:5000

### Pruebas

```bash
# 1. Health check del backend
curl http://54.165.218.98:5000/health

# 2. Health check vía API Gateway
curl https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod/api/health

# 3. Listar servicios (debería estar vacío inicialmente)
curl https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod/api/services

# 4. Crear un servicio de prueba
curl -X POST https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod/api/services \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Google",
    "url": "https://www.google.com",
    "checkInterval": 5,
    "timeout": 5000,
    "expectedStatus": 200
  }'
```

---

## Paso 4: Verificar Lambda Functions

Las funciones Lambda ya están configuradas y deberían ejecutarse automáticamente:

1. **healthcheck-monitor**: Se ejecuta cada 5 minutos (CloudWatch Events)
2. **healthcheck-s3-processor**: Se ejecuta cuando subes archivos a `s3://healthcheck-cloud-frontend-b3967a4e/config/`

Ver logs en CloudWatch:
- AWS Console > CloudWatch > Log Groups > `/aws/lambda/healthcheck-cloud-monitor`
- AWS Console > CloudWatch > Log Groups > `/aws/lambda/healthcheck-cloud-s3-processor`

---

## Troubleshooting

### Backend no responde

```bash
# Conectar a EC2 y verificar
ssh -i ~/.ssh/devops-key.pem ec2-user@54.165.218.98
sudo systemctl status healthcheck-api
sudo journalctl -u healthcheck-api -f
```

### API Gateway da error

- Verificar que el backend esté corriendo en EC2
- Verificar Security Group permite tráfico desde API Gateway
- Verificar que la URL en API Gateway sea correcta: `http://54.165.218.98:5000`

### Frontend no carga

- Verificar que los archivos estén en S3: `aws s3 ls s3://healthcheck-cloud-frontend-b3967a4e`
- Verificar política pública del bucket
- Verificar que `REACT_APP_API_URL` esté configurado correctamente

---

## Checklist Final

- [ ] Backend desplegado y corriendo en EC2
- [ ] Backend responde en http://54.165.218.98:5000/health
- [ ] API Gateway responde en https://7nhv08m6dl.execute-api.us-east-1.amazonaws.com/prod/api/health
- [ ] Frontend desplegado en S3
- [ ] Frontend accesible en http://healthcheck-cloud-frontend-b3967a4e.s3-website-us-east-1.amazonaws.com
- [ ] Puedo crear un servicio desde el frontend
- [ ] Lambda monitor está ejecutándose (ver CloudWatch Logs)

