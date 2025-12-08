"""
Lambda function para realizar health checks automáticos
Trigger: CloudWatch Events (cada 5 minutos)
"""

import json
import boto3
import urllib.request
import time
from datetime import datetime
from typing import Dict, Any, List
from decimal import Decimal
import os

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# Obtener nombres de tablas desde variables de entorno
SERVICES_TABLE = os.environ.get('SERVICES_TABLE', 'Services')
CHECKS_TABLE = os.environ.get('CHECKS_TABLE', 'HealthChecks')
ALERTS_TABLE = os.environ.get('ALERTS_TABLE', 'Alerts')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN', '')

def lambda_handler(event, context):
    """
    Handler principal de la función Lambda
    """
    try:
        # Obtener todos los servicios activos
        services = get_active_services()
        
        results = []
        for service in services:
            # Realizar health check
            check_result = perform_health_check(service)
            
            # Guardar resultado en DynamoDB
            save_health_check(check_result)
            
            # Si el servicio está caído, enviar alerta
            if check_result['status'] == 'down':
                send_alert_if_needed(service, check_result)
            
            results.append(check_result)
        
        # Convertir Decimal a float para JSON serialization
        json_results = []
        for result in results:
            json_result = {}
            for key, value in result.items():
                if isinstance(value, Decimal):
                    json_result[key] = float(value)
                else:
                    json_result[key] = value
            json_results.append(json_result)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Health checks completados: {len(json_results)}',
                'results': json_results
            })
        }
    except Exception as e:
        print(f"Error en health check: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def get_active_services() -> List[Dict[str, Any]]:
    """Obtener todos los servicios activos de DynamoDB"""
    table = dynamodb.Table(SERVICES_TABLE)
    response = table.scan()
    return response.get('Items', [])

def perform_health_check(service: Dict[str, Any]) -> Dict[str, Any]:
    """
    Realizar health check a un servicio
    """
    url = service['url']
    timeout = service.get('timeout', 5000) / 1000  # convertir a segundos
    expected_status = service.get('expectedStatus', 200)
    
    result = {
        'serviceId': service['serviceId'],
        'timestamp': int(time.time()),
        'checkedAt': datetime.utcnow().isoformat()
    }
    
    try:
        start_time = time.time()
        
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'HealthCheck-Cloud/1.0')
        
        with urllib.request.urlopen(req, timeout=timeout) as response:
            response_time = (time.time() - start_time) * 1000  # en ms
            status_code = response.getcode()
            
            result.update({
                'status': 'up' if status_code == expected_status else 'down',
                'httpStatus': status_code,
                'responseTime': Decimal(str(round(response_time, 2))),  # Convertir a Decimal para DynamoDB
                'error': None
            })
            
    except urllib.error.HTTPError as e:
        result.update({
            'status': 'down',
            'httpStatus': e.code,
            'responseTime': None,
            'error': f'HTTP Error: {e.code}'
        })
    except urllib.error.URLError as e:
        result.update({
            'status': 'down',
            'httpStatus': None,
            'responseTime': None,
            'error': f'URL Error: {str(e)}'
        })
    except Exception as e:
        result.update({
            'status': 'down',
            'httpStatus': None,
            'responseTime': None,
            'error': f'Error: {str(e)}'
        })
    
    return result

def save_health_check(check_result: Dict[str, Any]):
    """Guardar resultado del health check en DynamoDB"""
    table = dynamodb.Table(CHECKS_TABLE)
    
    # Convertir valores numéricos a Decimal para DynamoDB
    item = {}
    for key, value in check_result.items():
        if isinstance(value, float):
            item[key] = Decimal(str(value))
        elif isinstance(value, int) and key == 'timestamp':
            item[key] = value  # timestamp puede ser int
        else:
            item[key] = value
    
    table.put_item(Item=item)

def send_alert_if_needed(service: Dict[str, Any], check_result: Dict[str, Any]):
    """
    Enviar alerta si el servicio está caído
    Solo enviar si es la primera vez o si no se ha enviado recientemente
    """
    # Verificar si ya hay una alerta reciente
    alerts_table = dynamodb.Table(ALERTS_TABLE)
    
    # Buscar alertas recientes para este servicio
    # (implementación simplificada - puedes mejorarla)
    
    # Enviar alerta vía SNS
    message = f"""
    ⚠️ ALERTA: Servicio caído
    
    Servicio: {service.get('name', 'Unknown')}
    URL: {service.get('url')}
    Estado: {check_result.get('status')}
    Error: {check_result.get('error', 'N/A')}
    Timestamp: {check_result.get('checkedAt')}
    """
    
    try:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"Alerta: {service.get('name')} está caído",
            Message=message
        )
        
        # Guardar alerta en DynamoDB
        alert_id = f"{service['serviceId']}-{check_result['timestamp']}"
        alerts_table.put_item(Item={
            'alertId': alert_id,
            'serviceId': service['serviceId'],
            'type': 'service_down',
            'message': message,
            'sentAt': datetime.utcnow().isoformat(),
            'resolvedAt': None
        })
    except Exception as e:
        print(f"Error enviando alerta: {str(e)}")

