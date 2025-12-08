"""
Modelo de datos para Servicios
"""

from datetime import datetime
from typing import Optional, Dict, Any

class Service:
    """Modelo de servicio a monitorear"""
    
    def __init__(
        self,
        service_id: str,
        name: str,
        url: str,
        check_interval: int = 5,
        timeout: int = 5000,
        expected_status: int = 200,
        owner_id: Optional[str] = None,
        created_at: Optional[str] = None,
        updated_at: Optional[str] = None
    ):
        self.service_id = service_id
        self.name = name
        self.url = url
        self.check_interval = check_interval  # minutos
        self.timeout = timeout  # milisegundos
        self.expected_status = expected_status
        self.owner_id = owner_id
        self.created_at = created_at or datetime.utcnow().isoformat()
        self.updated_at = updated_at or datetime.utcnow().isoformat()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convertir a diccionario para DynamoDB"""
        return {
            'serviceId': self.service_id,
            'name': self.name,
            'url': self.url,
            'checkInterval': self.check_interval,
            'timeout': self.timeout,
            'expectedStatus': self.expected_status,
            'ownerId': self.owner_id,
            'createdAt': self.created_at,
            'updatedAt': self.updated_at
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Service':
        """Crear instancia desde diccionario de DynamoDB"""
        return cls(
            service_id=data.get('serviceId'),
            name=data.get('name'),
            url=data.get('url'),
            check_interval=data.get('checkInterval', 5),
            timeout=data.get('timeout', 5000),
            expected_status=data.get('expectedStatus', 200),
            owner_id=data.get('ownerId'),
            created_at=data.get('createdAt'),
            updated_at=data.get('updatedAt')
        )


