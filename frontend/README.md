# Frontend - HealthCheck Cloud

Frontend desarrollado en React para el dashboard de monitoreo de servicios.

## Prerrequisitos

- Node.js 16+ instalado
- npm o yarn

## Instalación

```bash
cd frontend
npm install
```

## Configuración

### Desarrollo Local

El frontend detecta automáticamente que está en desarrollo y usa `http://localhost:5000` como URL de la API.

### Producción

Crear archivo `.env.production`:

```
REACT_APP_API_URL=https://tu-api-gateway-url.execute-api.region.amazonaws.com/prod
```

## Ejecutar en Desarrollo

```bash
npm start
```

La aplicación se abrirá en http://localhost:3000

## Build para Producción

```bash
npm run build
```

Esto creará una carpeta `build/` con los archivos estáticos listos para subir a S3.

## Estructura

```
frontend/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── ServiceList.js      # Lista de servicios
│   │   ├── ServiceCard.js      # Tarjeta de servicio
│   │   ├── ServiceForm.js      # Formulario para agregar servicios
│   │   └── Dashboard.js        # Dashboard con gráficos
│   ├── services/
│   │   └── api.js              # Cliente API
│   ├── App.js                  # Componente principal
│   ├── App.css                 # Estilos de la app
│   ├── index.js                # Punto de entrada
│   └── index.css               # Estilos globales
└── package.json
```

## Características

- Lista de servicios monitoreados
- Agregar nuevos servicios
- Dashboard con gráficos (Chart.js)
- Visualización de uptime y latencia
- Estado en tiempo real de cada servicio
- Historial de health checks

## Dependencias Principales

- React 18: Framework UI
- Axios: Cliente HTTP para API
- Chart.js + react-chartjs-2: Gráficos
- React Router: Navegación

## Configuración de API

La URL de la API se configura automáticamente:

- Desarrollo: `http://localhost:5000` (automático)
- Producción: Variable de entorno `REACT_APP_API_URL` (requerido)

## Despliegue a S3

1. Build del proyecto:
```bash
npm run build
```

2. Subir a S3:
```bash
aws s3 sync build/ s3://tu-bucket-name --delete
```

3. Configurar bucket para hosting estático en la consola de AWS.

## Solución de Problemas

### Error de CORS

Si ves errores de CORS, asegúrate de que API Gateway tenga CORS habilitado para el origen del frontend.

### No se cargan los servicios

- Verifica que la URL de la API sea correcta
- Revisa la consola del navegador para errores
- Verifica que el backend esté corriendo
- Verifica que API Gateway esté configurado correctamente

### Build falla

- Verifica que todas las dependencias estén instaladas: `npm install`
- Revisa errores en la consola
- Asegúrate de tener Node.js 16+ instalado
