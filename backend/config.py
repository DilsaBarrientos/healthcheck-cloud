import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configuración de la aplicación"""
    
    # AWS Configuration
    AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')
    AWS_ENDPOINT_URL = os.getenv('AWS_ENDPOINT_URL', None)  # Para DynamoDB Local
    
    # Detectar si estamos en local o cloud
    # Si AWS_ENDPOINT_URL está configurado, asumimos que es local
    IS_LOCAL = AWS_ENDPOINT_URL is not None
    
    # DynamoDB Tables
    DYNAMODB_SERVICES_TABLE = os.getenv('DYNAMODB_SERVICES_TABLE', 'Services')
    DYNAMODB_CHECKS_TABLE = os.getenv('DYNAMODB_CHECKS_TABLE', 'HealthChecks')
    DYNAMODB_ALERTS_TABLE = os.getenv('DYNAMODB_ALERTS_TABLE', 'Alerts')
    
    # Application
    FLASK_ENV = os.getenv('FLASK_ENV', 'production')
    DEBUG = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    PORT = int(os.getenv('PORT', 5000))
    HOST = os.getenv('HOST', '0.0.0.0')

