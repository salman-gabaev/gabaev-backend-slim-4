FROM php:8.1-fpm

RUN pecl install xdebug-3.1.5 \
    && docker-php-ext-enable xdebug

VOLUME ["/app"]
WORKDIR /app