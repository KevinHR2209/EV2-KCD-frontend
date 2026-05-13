# Frontend Despacho — Innovatech Chile

Frontend desarrollado con **React + Vite + Tailwind CSS** para el sistema de gestión de despachos y ventas de Innovatech Chile.

---

## 🏗️ Tecnologías

- React 18
- Vite
- Tailwind CSS
- Nginx (servidor de producción)

---

## 🐳 Dockerfile (Multi-stage)

Se usa **multi-stage build** para obtener una imagen final pequeña y segura:

| Etapa | Imagen base | Propósito |
|---|---|---|
| `build` | `node:20-alpine` | Instalar dependencias y compilar |
| `run` | `nginx:stable-alpine` | Servir archivos estáticos |

- Imagen final: ~25MB (vs ~400MB sin multi-stage).
- Corre con **usuario no root** por seguridad.

---

## ⚙️ Variables de Entorno

| Variable | Descripción |
|---|---|
| `VITE_API_DESPACHO` | URL del backend Despachos (ej: `http://IP_EC2:8080`) |
| `VITE_API_VENTAS` | URL del backend Ventas (ej: `http://IP_EC2:8081`) |

Copia `.env.example` a `.env` para desarrollo local:

```bash
cp .env.example .env
```

---

## 🚀 Levantar Localmente

```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Build de producción
npm run build

# Con Docker
docker build \
  --build-arg VITE_API_DESPACHO=http://localhost:8080 \
  --build-arg VITE_API_VENTAS=http://localhost:8081 \
  -t frontend-despacho .
docker run -p 80:80 frontend-despacho
```

---

## 🔄 Pipeline CI/CD

El pipeline se activa con **push a la rama `deploy`**:

```
push a rama deploy
       │
       ▼
  1. docker build (con VITE_API vars)
       │
       ▼
  2. docker push → Amazon ECR
       │
       ▼
  3. SSH a EC2 Frontend
       │
       ▼
  4. docker pull + docker run -p 80:80
```

### GitHub Secrets requeridos

| Secret | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `AWS_REGION` | Región AWS |
| `ECR_REGISTRY` | URL del registro ECR |
| `ECR_REPO_FRONTEND` | Nombre del repo ECR para Frontend |
| `EC2_HOST_FRONTEND` | IP pública de la EC2 Frontend |
| `EC2_USER` | Usuario SSH (ej: `ec2-user`) |
| `EC2_SSH_KEY` | Clave privada SSH |
| `VITE_API_DESPACHO` | URL del backend Despachos en EC2 |
| `VITE_API_VENTAS` | URL del backend Ventas en EC2 |

---

## 🛡️ Seguridad

- Corre con usuario **no root** dentro del contenedor.
- Variables de entorno manejadas como **GitHub Secrets**.
- Solo este servicio es accesible desde Internet (puerto 80).
