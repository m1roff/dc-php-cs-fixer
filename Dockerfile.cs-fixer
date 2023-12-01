ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-alpine

ARG PHP_CS_FIXER_VERSION

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
ENV COMPOSER_HOME="/usr/local/composer"

RUN composer global require friendsofphp/php-cs-fixer:$PHP_CS_FIXER_VERSION
ENV PATH="${PATH}:${COMPOSER_HOME}/vendor/bin"
