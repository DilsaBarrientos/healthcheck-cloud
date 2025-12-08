import React, { useState } from 'react';
import { deleteService } from '../services/api';
import ServiceCard from './ServiceCard';

const ServiceList = ({ services, onDelete, onRefresh }) => {
  const [deleting, setDeleting] = useState(null);
  const [error, setError] = useState(null);

  const handleDelete = async (serviceId) => {
    if (!window.confirm('¿Estás seguro de eliminar este servicio?')) {
      return;
    }

    try {
      setDeleting(serviceId);
      setError(null);
      await deleteService(serviceId);
      onDelete();
    } catch (err) {
      setError('Error eliminando servicio: ' + err.message);
      console.error('Error:', err);
    } finally {
      setDeleting(null);
    }
  };

  if (services.length === 0) {
    return (
      <div className="card">
        <p>No hay servicios registrados. Agrega uno para comenzar a monitorear.</p>
      </div>
    );
  }

  return (
    <div>
      {error && <div className="error">{error}</div>}
      
      <div className="card" style={{ marginBottom: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2>Servicios Monitoreados ({services.length})</h2>
          <button className="btn btn-primary" onClick={onRefresh}>
            🔄 Actualizar
          </button>
        </div>
      </div>

      <div className="grid">
        {services.map((service) => (
          <ServiceCard
            key={service.serviceId}
            service={service}
            onDelete={handleDelete}
            isDeleting={deleting === service.serviceId}
          />
        ))}
      </div>
    </div>
  );
};

export default ServiceList;


