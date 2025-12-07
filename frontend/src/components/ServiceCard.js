import React, { useState, useEffect } from 'react';
import { getServiceChecks } from '../services/api';

const ServiceCard = ({ service, onDelete, isDeleting }) => {
  const [lastCheck, setLastCheck] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadLastCheck();
  }, [service.serviceId]);

  const loadLastCheck = async () => {
    try {
      setLoading(true);
      const data = await getServiceChecks(service.serviceId, 1);
      if (data.checks && data.checks.length > 0) {
        setLastCheck(data.checks[0]);
      }
    } catch (err) {
      console.error('Error cargando último check:', err);
    } finally {
      setLoading(false);
    }
  };

  const getStatus = () => {
    if (!lastCheck) return { status: 'unknown', label: 'Sin verificar', color: '#999' };
    return lastCheck.status === 'up'
      ? { status: 'up', label: 'En línea', color: '#27ae60' }
      : { status: 'down', label: 'Caído', color: '#e74c3c' };
  };

  const status = getStatus();

  return (
    <div className="card">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '15px' }}>
        <div style={{ flex: 1 }}>
          <h3 style={{ marginBottom: '10px', color: '#333' }}>{service.name}</h3>
          <p style={{ color: '#666', fontSize: '0.9rem', wordBreak: 'break-all' }}>
            {service.url}
          </p>
        </div>
        <span
          className={`status-badge status-${status.status}`}
          style={{ marginLeft: '10px' }}
        >
          {status.label}
        </span>
      </div>

      {lastCheck && (
        <div style={{ marginTop: '15px', paddingTop: '15px', borderTop: '1px solid #eee' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem', color: '#666' }}>
            <span>
              <strong>Última verificación:</strong>{' '}
              {new Date(lastCheck.checkedAt).toLocaleString('es-ES')}
            </span>
          </div>
          {lastCheck.responseTime != null && (
            <div style={{ marginTop: '5px', fontSize: '0.9rem', color: '#666' }}>
              <strong>Tiempo de respuesta:</strong> {Number(lastCheck.responseTime).toFixed(2)} ms
            </div>
          )}
          {lastCheck.httpStatus && (
            <div style={{ marginTop: '5px', fontSize: '0.9rem', color: '#666' }}>
              <strong>HTTP Status:</strong> {lastCheck.httpStatus}
            </div>
          )}
        </div>
      )}

      {loading && !lastCheck && (
        <div style={{ marginTop: '15px', color: '#999', fontSize: '0.9rem' }}>
          Cargando estado...
        </div>
      )}

      <div style={{ marginTop: '15px', display: 'flex', gap: '10px' }}>
        <button
          className="btn btn-danger"
          onClick={() => onDelete(service.serviceId)}
          disabled={isDeleting}
          style={{ flex: 1 }}
        >
          {isDeleting ? 'Eliminando...' : '🗑️ Eliminar'}
        </button>
      </div>
    </div>
  );
};

export default ServiceCard;

