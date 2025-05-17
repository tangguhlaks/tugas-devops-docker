# syntax=docker/dockerfile:1



# Tahap 1: Install dependencies menggunakan composer image

FROM composer:lts AS deps



WORKDIR /app



RUN --mount=type=bind,source=composer.json,target=composer.json \

    --mount=type=bind,source=composer.lock,target=composer.lock \

    --mount=type=cache,target=/tmp/cache \

    composer install --no-dev --no-interaction



# Tahap 2: Build final image dengan PHP + Apache

FROM php:8.2-apache AS final



# Install ekstensi PHP

RUN docker-php-ext-install pdo pdo_mysql



# Gunakan konfigurasi php.ini produksi

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"



# Salin dependensi dari stage sebelumnya

COPY --from=deps /app/vendor/ /var/www/html/vendor/



# Salin source code ke dalam container

COPY ./src /var/www/html/



# Jalankan dengan user www-data (user default Apache)

USER www-data


