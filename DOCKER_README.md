# Docker Setup - Clients System

## Requisitos previos

- [Docker Desktop]
- El archivo `.env` configurado en la raíz del proyecto

## Estructura Docker

Este proyecto incluye:

- **php**: Servicio PHP 8.2 con Apache 2
- **postgres**: Base de datos PostgreSQL 15 (Alpine)

## Primeros pasos

### 1. Construir las imágenes

```bash
docker-compose build
```

### 2. Iniciar los servicios

```bash
docker-compose up -d
```

Los servicios estarán disponibles en:
- **PHP/Apache**: http://localhost
- **PostgreSQL**: localhost:5432

### 3. Acceder a la aplicación

- Vista de cliente: http://localhost/Clients_System/views/public/index.php
- Vista de administrador: http://localhost/Clients_System/views/dashboard/index.php

## Comandos útiles

### Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Solo PHP
docker-compose logs -f php

# Solo PostgreSQL
docker-compose logs -f postgres
```

### Acceder al contenedor PHP

```bash
docker-compose exec php bash
```

### Acceder a PostgreSQL

```bash
docker-compose exec postgres psql -U postgres -d Clients_System
```

### Detener servicios

```bash
docker-compose down
```

### Detener y eliminar volúmenes

```bash
docker-compose down -v
```

## Configuración de variables de entorno

El archivo `.env` en la raíz del proyecto contiene las variables necesarias:

```env
DB_HOST=postgres          # Debe coincidir con el nombre del servicio
DB_PORT=5432
DB_NAME=Clients_System
DB_USER=postgres
DB_PASSWORD=2002
DB_DRIVER=pgsql

MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=tu_email@gmail.com
MAIL_PASSWORD=tu_contraseña_app
MAIL_FROM_ADDRESS=tu_email@gmail.com
MAIL_FROM_NAME=Sistema de recuperacion
```

## Características

- Base de datos PostgreSQL 15 con Alpine 
- PHP 8.2 con extensiones PDO y PostgreSQL
- Apache 2 con reescrituras de URL habilitadas
- Volumen compartido para desarrollo en tiempo real
- Health checks para validar disponibilidad de servicios
- Red interna Docker para comunicación entre servicios
- Base de datos inicializada automáticamente con database.sql

## Solución de problemas

### La base de datos no se inicializa

Elimina el volumen y reinicia:

```bash
docker-compose down -v
docker-compose up -d
```

### No puedo conectarme a la base de datos

Verifica que:
1. PostgreSQL esté en estado "healthy": `docker-compose ps`
2. Las variables en `.env` sean correctas
3. El archivo `database.sql` exista en la raíz del proyecto

### Puertos en uso

Si los puertos 80 o 5432 están en uso, modifica el `docker-compose.yml`:

```yaml
php:
  ports:
    - "8080:80"      
    
postgres:
  ports:
    - "5433:5432"    
```

## Desarrollo

Los cambios en los archivos del proyecto se reflejan automáticamente en el contenedor PHP gracias al volumen compartido.

Para cambios en el Dockerfile, es necesario reconstruir:

```bash
docker-compose up -d --build
```

