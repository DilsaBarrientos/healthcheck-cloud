import React, { useState, useEffect } from 'react';
import ServiceList from './components/ServiceList';
import ServiceForm from './components/ServiceForm';
import Dashboard from './components/Dashboard';
import { getServices } from './services/api';
import './App.css';

function App() {
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState('services'); // 'services', 'dashboard', 'add'

  useEffect(() => {
    loadServices();
  }, []);

  const loadServices = async () => {
    try {
      setLoading(true);
      const data = await getServices();
      setServices(data.services || []);
      setError(null);
    } catch (err) {
      setError('Error cargando servicios: ' + err.message);
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleServiceAdded = () => {
    loadServices();
    setActiveTab('services');
  };

  const handleServiceDeleted = () => {
    loadServices();
  };

  return (
    <div className="App">
      <div className="header">
        <div className="container">
          <h1>🏥 HealthCheck Cloud</h1>
          <p>Monitor de Salud de Servicios Web</p>
        </div>
      </div>

      <div className="container">
        {/* Navegación por tabs */}
        <div className="tabs">
          <button
            className={`tab ${activeTab === 'services' ? 'active' : ''}`}
            onClick={() => setActiveTab('services')}
          >
            Servicios
          </button>
          <button
            className={`tab ${activeTab === 'dashboard' ? 'active' : ''}`}
            onClick={() => setActiveTab('dashboard')}
          >
            Dashboard
          </button>
          <button
            className={`tab ${activeTab === 'add' ? 'active' : ''}`}
            onClick={() => setActiveTab('add')}
          >
            + Agregar Servicio
          </button>
        </div>

        {error && <div className="error">{error}</div>}

        {loading && activeTab === 'services' && (
          <div className="loading">Cargando servicios...</div>
        )}

        {activeTab === 'services' && !loading && (
          <ServiceList
            services={services}
            onDelete={handleServiceDeleted}
            onRefresh={loadServices}
          />
        )}

        {activeTab === 'dashboard' && (
          <Dashboard services={services} />
        )}

        {activeTab === 'add' && (
          <ServiceForm onServiceAdded={handleServiceAdded} />
        )}
      </div>
    </div>
  );
}

export default App;


