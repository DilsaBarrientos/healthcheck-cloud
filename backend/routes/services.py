"""
Rutas para gestión de servicios
"""

from flask import Blueprint, request, jsonify
from services.dynamodb_client import DynamoDBClient
from models.service import Service
from utils.validators import validate_service_data
import uuid

services_bp = Blueprint('services', __name__)
db = DynamoDBClient()

@services_bp.route('/services', methods=['GET'])
def list_services():
    """Listar todos los servicios"""
    try:
        services = db.list_services()
        return jsonify({'services': services}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@services_bp.route('/services', methods=['POST'])
def create_service():
    """Crear un nuevo servicio"""
    try:
        data = request.get_json()
        
        # Validar datos
        validation_error = validate_service_data(data)
        if validation_error:
            return jsonify({'error': validation_error}), 400
        
        # Crear servicio
        service_id = str(uuid.uuid4())
        service = Service(
            service_id=service_id,
            name=data['name'],
            url=data['url'],
            check_interval=data.get('checkInterval', 5),
            timeout=data.get('timeout', 5000),
            expected_status=data.get('expectedStatus', 200),
            owner_id=data.get('ownerId')
        )
        
        # Guardar en DynamoDB
        db.create_service(service.to_dict())
        
        return jsonify(service.to_dict()), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@services_bp.route('/services/<service_id>', methods=['GET'])
def get_service(service_id):
    """Obtener un servicio específico"""
    try:
        service = db.get_service(service_id)
        if not service:
            return jsonify({'error': 'Servicio no encontrado'}), 404
        return jsonify(service), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@services_bp.route('/services/<service_id>', methods=['PUT'])
def update_service(service_id):
    """Actualizar un servicio"""
    try:
        data = request.get_json()
        
        # Verificar que existe
        existing = db.get_service(service_id)
        if not existing:
            return jsonify({'error': 'Servicio no encontrado'}), 404
        
        # Actualizar
        updated = db.update_service(service_id, data)
        return jsonify(updated), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@services_bp.route('/services/<service_id>', methods=['DELETE'])
def delete_service(service_id):
    """Eliminar un servicio"""
    try:
        # Verificar que existe
        existing = db.get_service(service_id)
        if not existing:
            return jsonify({'error': 'Servicio no encontrado'}), 404
        
        db.delete_service(service_id)
        return jsonify({'message': 'Servicio eliminado correctamente'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@services_bp.route('/services/<service_id>/checks', methods=['GET'])
def get_service_checks(service_id):
    """Obtener historial de health checks de un servicio"""
    try:
        limit = request.args.get('limit', 100, type=int)
        checks = db.get_health_checks(service_id, limit=limit)
        return jsonify({'checks': checks}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@services_bp.route('/services/<service_id>/checks', methods=['POST'])
def create_service_check(service_id):
    """Crear un health check manualmente (para pruebas)"""
    try:
        data = request.get_json()
        import time
        from datetime import datetime
        
        check_data = {
            'serviceId': service_id,
            'timestamp': int(time.time()),
            'status': data.get('status', 'up'),
            'responseTime': data.get('responseTime', 0),
            'httpStatus': data.get('httpStatus', 200),
            'checkedAt': datetime.utcnow().isoformat(),
            'error': data.get('error')
        }
        
        db.create_health_check(check_data)
        return jsonify(check_data), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

