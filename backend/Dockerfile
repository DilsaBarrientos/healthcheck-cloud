FROM python:3.9-slim

WORKDIR /app

# Instalar dependencias
RUN apt-get update && apt-get install -y gcc curl && rm -rf /var/lib/apt/lists/*

# Instalar Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY . .

# Exponer puerto
EXPOSE 5000

# Comando para desarrollo (hot-reload)
CMD ["python", "app.py"]
