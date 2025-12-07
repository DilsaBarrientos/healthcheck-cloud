"""
HealthCheck Cloud - Backend API
Aplicación Flask para gestión de servicios y métricas
"""

from flask import Flask
from flask_cors import CORS
from config import Config
from routes.services import services_bp
from routes.dashboard import dashboard_bp

app = Flask(__name__)
app.config.from_object(Config)

# Habilitar CORS
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Registrar blueprints
app.register_blueprint(services_bp, url_prefix='/api')
app.register_blueprint(dashboard_bp, url_prefix='/api')

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return {
        'status': 'healthy',
        'service': 'healthcheck-api',
        'environment': 'local' if Config.IS_LOCAL else 'cloud'
    }, 200

@app.route('/', methods=['GET'])
def index():
    """Root endpoint"""
    return {
        'message': 'HealthCheck Cloud API',
        'version': '1.0.0',
        'environment': 'local' if Config.IS_LOCAL else 'cloud',
        'endpoints': {
            'services': '/api/services',
            'dashboard': '/api/dashboard/metrics',
            'health': '/health'
        }
    }, 200

if __name__ == '__main__':
    app.run(
        host=app.config['HOST'],
        port=app.config['PORT'],
        debug=app.config['DEBUG']
    )
