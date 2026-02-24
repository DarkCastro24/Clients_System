FROM php:8.2-apache

# Instalar extensiones necesarias
RUN apt-get update && apt-get install -y \
    libpq-dev \
    git \
    curl \
    && docker-php-ext-install pdo pdo_pgsql \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configurar directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto manteniendo la estructura Clients_System
COPY . Clients_System/

# Instalar dependencias de Composer
RUN cd Clients_System && composer install --no-interaction --optimize-autoloader && cd ..

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80 443

CMD ["apache2-foreground"]
