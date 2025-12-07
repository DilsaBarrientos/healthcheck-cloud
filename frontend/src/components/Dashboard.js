import React, { useState, useEffect } from 'react';
import { getDashboardMetrics, getServiceChecks } from '../services/api';
import { Line, Doughnut } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  ArcElement,
  Title,
  Tooltip,
  Legend
);

const Dashboard = ({ services }) => {
  const [metrics, setMetrics] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedService, setSelectedService] = useState(null);
  const [serviceChecks, setServiceChecks] = useState([]);

  useEffect(() => {
    loadMetrics();
  }, []);

  useEffect(() => {
    if (selectedService) {
      loadServiceChecks(selectedService);
    }
  }, [selectedService]);

  const loadMetrics = async () => {
    try {
      setLoading(true);
      const data = await getDashboardMetrics();
      setMetrics(data.metrics || []);
      setError(null);
    } catch (err) {
      setError('Error cargando métricas: ' + err.message);
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const loadServiceChecks = async (serviceId) => {
    try {
      const data = await getServiceChecks(serviceId, 50);
      setServiceChecks(data.checks || []);
    } catch (err) {
      console.error('Error cargando checks:', err);
    }
  };

  const getUptimeChartData = () => {
    const labels = metrics.map((m) => m.serviceName || m.serviceId);
    const uptimes = metrics.map((m) => m.uptime || 0);

    return {
      labels,
      datasets: [
        {
          label: 'Uptime %',
          data: uptimes,
          backgroundColor: 'rgba(102, 126, 234, 0.6)',
          borderColor: 'rgba(102, 126, 234, 1)',
          borderWidth: 2,
        },
      ],
    };
  };

  const getLatencyChartData = () => {
    if (!selectedService || serviceChecks.length === 0) {
      return null;
    }

    const sortedChecks = [...serviceChecks].reverse();
    const labels = sortedChecks.map((check, index) => `Check ${index + 1}`);
    const latencies = sortedChecks.map((check) => Number(check.responseTime) || 0);

    return {
      labels,
      datasets: [
        {
          label: 'Tiempo de Respuesta (ms)',
          data: latencies,
          borderColor: 'rgba(39, 174, 96, 1)',
          backgroundColor: 'rgba(39, 174, 96, 0.1)',
          tension: 0.4,
        },
      ],
    };
  };

  const getStatusDistribution = () => {
    const upCount = metrics.filter((m) => (m.uptime || 0) > 50).length;
    const downCount = metrics.length - upCount;

    return {
      labels: ['En Línea', 'Con Problemas'],
      datasets: [
        {
          data: [upCount, downCount],
          backgroundColor: ['rgba(39, 174, 96, 0.8)', 'rgba(231, 76, 60, 0.8)'],
          borderColor: ['rgba(39, 174, 96, 1)', 'rgba(231, 76, 60, 1)'],
          borderWidth: 2,
        },
      ],
    };
  };

  if (loading) {
    return <div className="loading">Cargando métricas...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  if (metrics.length === 0) {
    return (
      <div className="card">
        <p>No hay métricas disponibles. Agrega servicios y espera a que se realicen los health checks.</p>
      </div>
    );
  }

  const uptimeData = getUptimeChartData();
  const latencyData = getLatencyChartData();
  const statusData = getStatusDistribution();

  return (
    <div>
      <div className="card" style={{ marginBottom: '20px' }}>
        <h2>Dashboard de Métricas</h2>
        <p style={{ color: '#666', marginTop: '10px' }}>
          Resumen de todos los servicios monitoreados
        </p>
      </div>

      <div className="grid" style={{ marginBottom: '20px' }}>
        <div className="card">
          <h3>Uptime por Servicio</h3>
          {uptimeData && (
            <Line
              data={uptimeData}
              options={{
                responsive: true,
                plugins: {
                  legend: { display: false },
                  title: { display: false },
                },
                scales: {
                  y: {
                    beginAtZero: true,
                    max: 100,
                    ticks: {
                      callback: function (value) {
                        return value + '%';
                      },
                    },
                  },
                },
              }}
            />
          )}
        </div>

        <div className="card">
          <h3>Distribución de Estado</h3>
          {statusData && (
            <Doughnut
              data={statusData}
              options={{
                responsive: true,
                plugins: {
                  legend: { position: 'bottom' },
                },
              }}
            />
          )}
        </div>
      </div>

      <div className="card">
        <h3>Historial de Latencia</h3>
        <div className="form-group" style={{ marginBottom: '15px' }}>
          <label htmlFor="serviceSelect">Seleccionar Servicio:</label>
          <select
            id="serviceSelect"
            value={selectedService || ''}
            onChange={(e) => setSelectedService(e.target.value)}
            style={{ width: '100%', padding: '10px' }}
          >
            <option value="">-- Selecciona un servicio --</option>
            {metrics.map((m) => (
              <option key={m.serviceId} value={m.serviceId}>
                {m.serviceName || m.serviceId}
              </option>
            ))}
          </select>
        </div>

        {latencyData ? (
          <Line
            data={latencyData}
            options={{
              responsive: true,
              plugins: {
                title: {
                  display: true,
                  text: 'Tiempo de Respuesta (últimos 50 checks)',
                },
              },
              scales: {
                y: {
                  beginAtZero: true,
                  title: {
                    display: true,
                    text: 'Milisegundos',
                  },
                },
              },
            }}
          />
        ) : (
          <p style={{ color: '#666', textAlign: 'center', padding: '20px' }}>
            Selecciona un servicio para ver su historial de latencia
          </p>
        )}
      </div>

      <div className="card" style={{ marginTop: '20px' }}>
        <h3>Resumen de Métricas</h3>
        <div className="grid">
          {metrics.map((metric) => (
            <div key={metric.serviceId} style={{ padding: '15px', border: '1px solid #eee', borderRadius: '5px' }}>
              <h4 style={{ marginBottom: '10px' }}>{metric.serviceName || metric.serviceId}</h4>
              <div style={{ fontSize: '0.9rem', color: '#666' }}>
                <div><strong>Uptime:</strong> {Number(metric.uptime || 0).toFixed(2)}%</div>
                <div><strong>Latencia Promedio:</strong> {Number(metric.averageLatency || 0).toFixed(2)} ms</div>
                <div><strong>Total Checks:</strong> {metric.totalChecks || 0}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

