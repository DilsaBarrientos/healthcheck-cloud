import React, { useState } from 'react';
import { createService } from '../services/api';

const ServiceForm = ({ onServiceAdded }) => {
  const [formData, setFormData] = useState({
    name: '',
    url: '',
    checkInterval: 5,
    timeout: 5000,
    expectedStatus: 200,
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: name === 'checkInterval' || name === 'timeout' || name === 'expectedStatus'
        ? parseInt(value) || 0
        : value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      await createService(formData);
      setSuccess(true);
      setFormData({
        name: '',
        url: '',
        checkInterval: 5,
        timeout: 5000,
        expectedStatus: 200,
      });
      setTimeout(() => {
        onServiceAdded();
      }, 1500);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="card">
      <h2 style={{ marginBottom: '20px' }}>Agregar Nuevo Servicio</h2>

      {error && <div className="error">{error}</div>}
      {success && (
        <div className="success">
          ✅ Servicio agregado correctamente. Redirigiendo...
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="name">Nombre del Servicio *</label>
          <input
            type="text"
            id="name"
            name="name"
            value={formData.name}
            onChange={handleChange}
            required
            placeholder="Ej: API Principal"
          />
        </div>

        <div className="form-group">
          <label htmlFor="url">URL *</label>
          <input
            type="url"
            id="url"
            name="url"
            value={formData.url}
            onChange={handleChange}
            required
            placeholder="https://ejemplo.com/api"
          />
        </div>

        <div className="form-group">
          <label htmlFor="checkInterval">Intervalo de Verificación (minutos)</label>
          <input
            type="number"
            id="checkInterval"
            name="checkInterval"
            value={formData.checkInterval}
            onChange={handleChange}
            min="1"
            max="60"
            required
          />
          <small style={{ color: '#666', fontSize: '0.9rem' }}>
            Cada cuántos minutos se verificará el servicio
          </small>
        </div>

        <div className="form-group">
          <label htmlFor="timeout">Timeout (milisegundos)</label>
          <input
            type="number"
            id="timeout"
            name="timeout"
            value={formData.timeout}
            onChange={handleChange}
            min="1000"
            max="30000"
            required
          />
          <small style={{ color: '#666', fontSize: '0.9rem' }}>
            Tiempo máximo de espera para la respuesta
          </small>
        </div>

        <div className="form-group">
          <label htmlFor="expectedStatus">HTTP Status Esperado</label>
          <input
            type="number"
            id="expectedStatus"
            name="expectedStatus"
            value={formData.expectedStatus}
            onChange={handleChange}
            min="100"
            max="599"
            required
          />
          <small style={{ color: '#666', fontSize: '0.9rem' }}>
            Código HTTP que se considera como "en línea" (normalmente 200)
          </small>
        </div>

        <button
          type="submit"
          className="btn btn-primary"
          disabled={loading}
          style={{ width: '100%', marginTop: '10px' }}
        >
          {loading ? 'Agregando...' : '➕ Agregar Servicio'}
        </button>
      </form>
    </div>
  );
};

export default ServiceForm;


