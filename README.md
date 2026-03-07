# Clients System

Este repositorio contiene el código fuente de un sistema web desarrollado como parte de una pasantía profesional. El sistema fue construido utilizando tecnologías del lado del servidor y del cliente como **PHP** y **JavaScript** con el framework **Boostrap 5**, y estructurado en una arquitectura modular para facilitar su mantenimiento y escalabilidad.

## Requisitos previos

- Docker Desktop
- El archivo `.env` configurado en la raíz del proyecto

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

### 3. Acceder a la aplicación desde Docker

- Vista de cliente desde Docker: http://localhost/views/public/index.php
- Vista de administrador desde Docker: http://localhost/views/dashboard/index.php

## Tecnologías utilizadas

- **PHP** Lógica del lado del servidor
- **JavaScript (Vanilla.JS)** Funcionalidad dinámica en el cliente
- **HTML** Estructura de las vistas
- **CSS** Estilos personalizados

## Versiones utilizadas en el desarrollo

- **PHP**: 8.2 (`php:8.2-apache`)
- **Apache**: 2.x (incluido en la imagen `php:8.2-apache`)
- **PostgreSQL**: 15 (`postgres:15-alpine`)

## Rutas para acceder al sistema

- Entorno Docker:
	- Vista del cliente: http://localhost/views/public/index.php
	- Vista del administrador: http://localhost/views/dashboard/index.php
- Entorno local con XAMPP (Sin docker):
	- Vista del cliente: http://localhost/Clients_System/views/public/index.php
	- Vista del administrador: http://localhost/Clients_System/views/dashboard/index.php

## Estructura del proyecto

```
├── app/
├── docker/
├── libraries/
├── resources/
├── vendor/
├── views/
├── docker-compose.yml
├── Dockerfile
└── .htaccess
```

Descripción de carpetas y archivos clave:

- `app/api/`: Endpoints y lógica de respuesta para funcionalidades del sistema.
- `app/controllers/`: Controladores para orquestar peticiones, validaciones y flujo de negocio.
- `app/helpers/`: Utilidades compartidas (base de datos, autenticación, correo, entorno, validaciones).
- `app/models/`: Acceso a datos y consultas SQL por módulo funcional.
- `app/reports/`: Generación de reportes para módulos del dashboard.
- `views/public/`: Vistas para usuarios públicos/clientes.
- `views/dashboard/`: Vistas para administración y operaciones internas.
- `resources/css`, `resources/js`, `resources/img`: Recursos estáticos de interfaz.
- `docker/`: Configuración de infraestructura (por ejemplo Apache vhost).
- `libraries/`: Librerías incluidas manualmente (FPDF, PHPMailer).
- `vendor/`: Dependencias instaladas con Composer.
- `database.sql`: Script de inicialización para la base de datos en Docker.
- `docker-compose.yml`: Orquestación de servicios `php` y `postgres`.
- `Dockerfile`: Imagen de aplicación PHP + Apache.

## Autor

**Diego Eduardo Castro Quintanilla**  
`00117322@uca.edu.sv`



