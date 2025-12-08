"""
Rutas para dashboard y métricas
"""

from flask import Blueprint, request, jsonify
from services.dynamodb_client import DynamoDBClient
from services.metrics_calculator import MetricsCalculator

dashboard_bp = Blueprint('dashboard', __name__)
db = DynamoDBClient()
calculator = MetricsCalculator()

@dashboard_bp.route('/dashboard/metrics', methods=['GET'])
def get_dashboard_metrics():
    """Obtener métricas generales del dashboard"""
    try:
        services = db.list_services()
        all_metrics = []
        
        for service in services:
            service_id = service['serviceId']
            checks = db.get_health_checks(service_id, limit=1000)
            metrics = calculator.calculate_metrics(checks)
            
            all_metrics.append({
                'serviceId': service_id,
                'serviceName': service.get('name'),
                'url': service.get('url'),
                **metrics
            })
        
        return jsonify({'metrics': all_metrics}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@dashboard_bp.route('/dashboard/uptime/<service_id>', methods=['GET'])
def get_service_uptime(service_id):
    """Obtener uptime de un servicio específico"""
    try:
        service = db.get_service(service_id)
        if not service:
            return jsonify({'error': 'Servicio no encontrado'}), 404
        
        checks = db.get_health_checks(service_id, limit=1000)
        metrics = calculator.calculate_metrics(checks)
        
        return jsonify({
            'serviceId': service_id,
            'serviceName': service.get('name'),
            **metrics
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


