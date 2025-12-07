FROM node:18-alpine

WORKDIR /app

# Instalar dependencias
COPY package*.json ./
RUN npm install

# Copiar código
COPY . .

# Exponer puerto
EXPOSE 3000

# Comando para desarrollo (hot-reload)
CMD ["npm", "start"]
