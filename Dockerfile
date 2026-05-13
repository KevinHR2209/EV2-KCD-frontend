# =============================================
# ETAPA 1: Build con Node
# =============================================
FROM node:20-alpine AS build
WORKDIR /app

# Copiar dependencias primero para aprovechar cache
COPY package*.json ./
RUN npm ci --only=production=false

# Copiar codigo fuente
COPY . .

# Build args para variables de entorno de Vite
ARG VITE_API_DESPACHO
ARG VITE_API_VENTAS
ENV VITE_API_DESPACHO=$VITE_API_DESPACHO
ENV VITE_API_VENTAS=$VITE_API_VENTAS

RUN npm run build

# =============================================
# ETAPA 2: Servir con Nginx (usuario no root)
# =============================================
FROM nginx:stable-alpine

# Crear usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar los archivos estaticos compilados
COPY --from=build /app/dist /usr/share/nginx/html

# Permisos correctos
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
