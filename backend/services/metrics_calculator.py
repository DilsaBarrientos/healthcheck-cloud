"""
Calculadora de métricas para servicios
"""

from typing import List, Dict, Any
from datetime import datetime, timedelta

class MetricsCalculator:
    """Calcula métricas de uptime y latencia"""
    
    @staticmethod
    def calculate_uptime(checks: List[Dict[str, Any]]) -> float:
        """Calcular porcentaje de uptime"""
        if not checks:
            return 0.0
        
        total_checks = len(checks)
        up_checks = sum(1 for check in checks if check.get('status') == 'up')
        
        return (up_checks / total_checks) * 100 if total_checks > 0 else 0.0
    
    @staticmethod
    def calculate_average_latency(checks: List[Dict[str, Any]]) -> float:
        """Calcular latencia promedio en milisegundos"""
        if not checks:
            return 0.0
        
        latencies = [
            check.get('responseTime', 0) 
            for check in checks 
            if check.get('responseTime') is not None
        ]
        
        return sum(latencies) / len(latencies) if latencies else 0.0
    
    @staticmethod
    def get_recent_checks(checks: List[Dict[str, Any]], hours: int = 24) -> List[Dict[str, Any]]:
        """Obtener checks de las últimas N horas"""
        cutoff_time = datetime.utcnow() - timedelta(hours=hours)
        cutoff_timestamp = int(cutoff_time.timestamp())
        
        return [
            check for check in checks
            if check.get('timestamp', 0) >= cutoff_timestamp
        ]
    
    @staticmethod
    def calculate_metrics(checks: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calcular todas las métricas"""
        recent_checks = MetricsCalculator.get_recent_checks(checks, hours=24)
        
        return {
            'totalChecks': len(checks),
            'recentChecks': len(recent_checks),
            'uptime': MetricsCalculator.calculate_uptime(checks),
            'recentUptime': MetricsCalculator.calculate_uptime(recent_checks),
            'averageLatency': MetricsCalculator.calculate_average_latency(checks),
            'recentAverageLatency': MetricsCalculator.calculate_average_latency(recent_checks)
        }


