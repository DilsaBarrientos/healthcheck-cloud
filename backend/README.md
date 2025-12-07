# Backend - HealthCheck API

Backend REST API desarrollado en Python (Flask/FastAPI) que se ejecuta en EC2.

## Estructura

```
backend/
├── app.py                 # Aplicación principal
├── requirements.txt       # Dependencias Python
├── config.py              # Configuración
├── .env.example           # Ejemplo de variables de entorno
├── gunicorn_config.py     # Configuración de Gunicorn
├── models/
│   └── service.py         # Modelos de datos
├── routes/
│   ├── services.py        # Endpoints CRUD de servicios
│   └── dashboard.py       # Endpoints de métricas
├── services/
│   ├── dynamodb_client.py # Cliente DynamoDB
│   └── metrics_calculator.py # Cálculo de métricas
└── utils/
    └── validators.py      # Validación de datos
```

## Instalación

```bash
# Instalar dependencias
pip3 install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus valores

# Ejecutar en desarrollo
python3 app.py

# Ejecutar en producción (con gunicorn)
gunicorn -c gunicorn_config.py app:app
```

## Variables de Entorno

Ver `.env.example` para la lista completa de variables requeridas.

## Endpoints

- `GET /api/services` - Listar todos los servicios
- `POST /api/services` - Crear nuevo servicio
- `GET /api/services/{id}` - Obtener servicio específico
- `PUT /api/services/{id}` - Actualizar servicio
- `DELETE /api/services/{id}` - Eliminar servicio
- `GET /api/services/{id}/checks` - Historial de health checks
- `GET /api/dashboard/metrics` - Métricas del dashboard
- `GET /api/dashboard/uptime/{id}` - Cálculo de uptime por servicio

