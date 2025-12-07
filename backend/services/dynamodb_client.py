"""
Cliente DynamoDB para operaciones de base de datos
"""

import boto3
from botocore.exceptions import ClientError
from typing import List, Dict, Any, Optional
from config import Config

class DynamoDBClient:
    """Cliente para interactuar con DynamoDB"""
    
    def __init__(self):
        # Configurar cliente DynamoDB (con soporte para DynamoDB Local y Cloud)
        dynamodb_kwargs = {'region_name': Config.AWS_REGION}
        
        # Si usamos DynamoDB Local, configurar endpoint y credenciales dummy
        if Config.IS_LOCAL and Config.AWS_ENDPOINT_URL:
            dynamodb_kwargs['endpoint_url'] = Config.AWS_ENDPOINT_URL
            dynamodb_kwargs['aws_access_key_id'] = 'dummy'
            dynamodb_kwargs['aws_secret_access_key'] = 'dummy'
        # En cloud, boto3 usará las credenciales del IAM Role de EC2 automáticamente
        
        self.dynamodb = boto3.resource('dynamodb', **dynamodb_kwargs)
        self.services_table = self.dynamodb.Table(Config.DYNAMODB_SERVICES_TABLE)
        self.checks_table = self.dynamodb.Table(Config.DYNAMODB_CHECKS_TABLE)
        self.alerts_table = self.dynamodb.Table(Config.DYNAMODB_ALERTS_TABLE)
    
    # Operaciones con Services
    def create_service(self, service_data: Dict[str, Any]) -> Dict[str, Any]:
        """Crear un nuevo servicio"""
        try:
            self.services_table.put_item(Item=service_data)
            return service_data
        except ClientError as e:
            raise Exception(f"Error creando servicio: {str(e)}")
    
    def get_service(self, service_id: str) -> Optional[Dict[str, Any]]:
        """Obtener un servicio por ID"""
        try:
            response = self.services_table.get_item(
                Key={'serviceId': service_id}
            )
            return response.get('Item')
        except ClientError as e:
            raise Exception(f"Error obteniendo servicio: {str(e)}")
    
    def list_services(self) -> List[Dict[str, Any]]:
        """Listar todos los servicios"""
        try:
            response = self.services_table.scan()
            return response.get('Items', [])
        except ClientError as e:
            raise Exception(f"Error listando servicios: {str(e)}")
    
    def update_service(self, service_id: str, update_data: Dict[str, Any]) -> Dict[str, Any]:
        """Actualizar un servicio"""
        try:
            # Construir expresión de actualización
            update_expression = "SET "
            expression_values = {}
            
            for key, value in update_data.items():
                if key != 'serviceId':  # No actualizar la clave
                    update_expression += f"{key} = :{key}, "
                    expression_values[f":{key}"] = value
            
            update_expression = update_expression.rstrip(', ')
            update_expression += ", updatedAt = :updatedAt"
            expression_values[":updatedAt"] = __import__('datetime').datetime.utcnow().isoformat()
            
            response = self.services_table.update_item(
                Key={'serviceId': service_id},
                UpdateExpression=update_expression,
                ExpressionAttributeValues=expression_values,
                ReturnValues='ALL_NEW'
            )
            return response.get('Attributes', {})
        except ClientError as e:
            raise Exception(f"Error actualizando servicio: {str(e)}")
    
    def delete_service(self, service_id: str) -> bool:
        """Eliminar un servicio"""
        try:
            self.services_table.delete_item(Key={'serviceId': service_id})
            return True
        except ClientError as e:
            raise Exception(f"Error eliminando servicio: {str(e)}")
    
    # Operaciones con HealthChecks
    def get_health_checks(self, service_id: str, limit: int = 100) -> List[Dict[str, Any]]:
        """Obtener health checks de un servicio"""
        try:
            response = self.checks_table.query(
                KeyConditionExpression='serviceId = :serviceId',
                ExpressionAttributeValues={':serviceId': service_id},
                Limit=limit,
                ScanIndexForward=False  # Orden descendente (más recientes primero)
            )
            return response.get('Items', [])
        except ClientError as e:
            raise Exception(f"Error obteniendo health checks: {str(e)}")
    
    def create_health_check(self, check_data: Dict[str, Any]) -> Dict[str, Any]:
        """Crear un health check"""
        try:
            self.checks_table.put_item(Item=check_data)
            return check_data
        except ClientError as e:
            raise Exception(f"Error creando health check: {str(e)}")

