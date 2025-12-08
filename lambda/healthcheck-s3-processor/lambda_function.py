"""
Lambda function para procesar eventos de S3
Trigger: S3 PUT event (cuando se sube un archivo)
Cumple requisito: Evento de almacenamiento (S3)
"""

import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

SERVICES_TABLE = 'Services'

def lambda_handler(event, context):
    """
    Handler para eventos de S3
    Se activa cuando se sube un archivo al bucket configurado
    """
    try:
        # Procesar cada registro del evento
        for record in event['Records']:
            # Obtener información del evento S3
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            event_name = record['eventName']
            
            print(f"Evento S3: {event_name}")
            print(f"Bucket: {bucket_name}")
            print(f"Objeto: {object_key}")
            
            # Si es un archivo de configuración de servicios (JSON)
            if object_key.endswith('.json') and 'services' in object_key.lower():
                process_service_config(bucket_name, object_key)
            
            # Registrar el evento en CloudWatch Logs
            log_s3_event(bucket_name, object_key, event_name)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'S3 event processed successfully',
                'processed': len(event['Records'])
            })
        }
    except Exception as e:
        print(f"Error procesando evento S3: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def process_service_config(bucket_name, object_key):
    """
    Procesar archivo de configuración de servicios desde S3
    """
    try:
        # Descargar archivo de S3
        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        content = response['Body'].read().decode('utf-8')
        services_config = json.loads(content)
        
        # Procesar servicios (ejemplo: actualizar o crear servicios)
        table = dynamodb.Table(SERVICES_TABLE)
        
        if isinstance(services_config, list):
            for service in services_config:
                # Validar y crear/actualizar servicio
                if 'serviceId' in service and 'name' in service and 'url' in service:
                    table.put_item(Item=service)
                    print(f"Servicio procesado: {service.get('name')}")
        
        print(f"Configuración procesada desde {object_key}")
    except Exception as e:
        print(f"Error procesando configuración: {str(e)}")

def log_s3_event(bucket_name, object_key, event_name):
    """
    Registrar evento S3 en logs
    """
    log_entry = {
        'timestamp': datetime.utcnow().isoformat(),
        'bucket': bucket_name,
        'object': object_key,
        'event': event_name
    }
    print(f"S3 Event logged: {json.dumps(log_entry)}")


