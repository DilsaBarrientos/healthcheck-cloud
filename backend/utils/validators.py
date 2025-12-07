"""
Validadores para datos de entrada
"""

from typing import Optional, Dict, Any
import re

def validate_url(url: str) -> bool:
    """Validar formato de URL"""
    url_pattern = re.compile(
        r'^https?://'  # http:// o https://
        r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'  # dominio
        r'localhost|'  # localhost
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'  # IP
        r'(?::\d+)?'  # puerto opcional
        r'(?:/?|[/?]\S+)$', re.IGNORECASE)
    return bool(url_pattern.match(url))

def validate_service_data(data: Dict[str, Any]) -> Optional[str]:
    """Validar datos de servicio"""
    if not data:
        return "Datos vacíos"
    
    # Validar nombre
    if 'name' not in data or not data['name']:
        return "El nombre es requerido"
    
    if len(data['name']) > 100:
        return "El nombre no puede exceder 100 caracteres"
    
    # Validar URL
    if 'url' not in data or not data['url']:
        return "La URL es requerida"
    
    if not validate_url(data['url']):
        return "URL inválida. Debe ser http:// o https://"
    
    # Validar checkInterval
    if 'checkInterval' in data:
        interval = data['checkInterval']
        if not isinstance(interval, int) or interval < 1 or interval > 60:
            return "checkInterval debe ser un número entre 1 y 60 minutos"
    
    # Validar timeout
    if 'timeout' in data:
        timeout = data['timeout']
        if not isinstance(timeout, int) or timeout < 1000 or timeout > 30000:
            return "timeout debe ser un número entre 1000 y 30000 milisegundos"
    
    # Validar expectedStatus
    if 'expectedStatus' in data:
        status = data['expectedStatus']
        if not isinstance(status, int) or status < 100 or status > 599:
            return "expectedStatus debe ser un código HTTP válido (100-599)"
    
    return None

