"""
Configuración de Gunicorn para producción
"""

import multiprocessing
import os

# Configuración del servidor
bind = f"0.0.0.0:{os.getenv('PORT', 5000)}"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Logging
accesslog = "/var/log/healthcheck-api/access.log"
errorlog = "/var/log/healthcheck-api/error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Proceso
daemon = False
pidfile = "/var/run/healthcheck-api.pid"
user = None
group = None
tmp_upload_dir = None

# SSL (si es necesario)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"


