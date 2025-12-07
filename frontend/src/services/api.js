import axios from 'axios';

// Configurar la URL base de la API automáticamente
// Local: http://localhost:5000
// Cloud: URL de API Gateway (configurar REACT_APP_API_URL en build)
const API_BASE_URL = process.env.REACT_APP_API_URL || 
  (process.env.NODE_ENV === 'development' ? 'http://localhost:5000' : 'https://your-api-gateway-url.execute-api.us-east-1.amazonaws.com/prod');

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para manejar errores
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      // El servidor respondió con un código de error
      throw new Error(error.response.data.error || 'Error en la petición');
    } else if (error.request) {
      // La petición se hizo pero no hubo respuesta
      throw new Error('No se pudo conectar con el servidor');
    } else {
      // Algo más causó el error
      throw new Error(error.message);
    }
  }
);

// Servicios API
export const getServices = async () => {
  const response = await api.get('/api/services');
  return response.data;
};

export const getService = async (serviceId) => {
  const response = await api.get(`/api/services/${serviceId}`);
  return response.data;
};

export const createService = async (serviceData) => {
  const response = await api.post('/api/services', serviceData);
  return response.data;
};

export const updateService = async (serviceId, serviceData) => {
  const response = await api.put(`/api/services/${serviceId}`, serviceData);
  return response.data;
};

export const deleteService = async (serviceId) => {
  const response = await api.delete(`/api/services/${serviceId}`);
  return response.data;
};

export const getServiceChecks = async (serviceId, limit = 100) => {
  const response = await api.get(`/api/services/${serviceId}/checks`, {
    params: { limit },
  });
  return response.data;
};

export const getDashboardMetrics = async () => {
  const response = await api.get('/api/dashboard/metrics');
  return response.data;
};

export const getServiceUptime = async (serviceId) => {
  const response = await api.get(`/api/dashboard/uptime/${serviceId}`);
  return response.data;
};

export default api;

