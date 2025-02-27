# https://github.com/maciejslawik/docker-php-fpm-xdebug/blob/master/Dockerfile
# Use a imagem base do PHP com Apache
FROM php:8.2-apache

# OpCache settings
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1"
ENV XDEBUG_MODE="debug,coverage"

ARG XDEBUG_VERSION=3.2.2

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Instale as dependências necessárias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libpq-dev \
    libicu-dev \
    libxslt-dev \
    libmagickwand-dev \
    imagemagick \
    libmemcached-dev \
    libmemcached11 \
    libmemcachedutil2 \
    libmemcached-tools \
    wget


# Install xdebug
RUN if [ ! -f /usr/local/lib/php/extensions/no-debug-non-zts-20200930/xdebug.so ]; then \
    pecl install xdebug-${XDEBUG_VERSION}; \
    docker-php-ext-enable xdebug; \
    fi

# Instale algumas ferramentas de linha de comando
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        vim \
        nano

RUN apt upgrade -y

# Instale as extensões PHP
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd opcache zip \
    && docker-php-ext-enable mysqli pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd xdebug

# Get latest Composer
COPY --from=composer:2.5.8 /usr/bin/composer /usr/bin/composer

# Add custom ini files
COPY config/10-shorttag.ini \
        config/20-memory-limit.ini \
        config/30-opcache.ini \
        config/40-xdebug.ini \      
        $PHP_INI_DIR/conf.d/

# Criação do arquivo de configuração para o Apache
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Create folder
RUN mkdir -p /data

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Defina o diretório de trabalho para o diretório padrão do Apache
WORKDIR /var/www/html

# Mantenha o Apache em execução no primeiro plano
CMD ["apache2-foreground"]
