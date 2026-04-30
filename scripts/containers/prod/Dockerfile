# ======================================================================================================================
# App - Dockerfile - PHP-FPM & Nginx & Supervisor                                           https://hub.docker.com/_/php
# ======================================================================================================================
ARG PHP_VERSION="8.4"

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 01 : Pull official base image
# ----------------------------------------------------------------------------------------------------------------------
FROM php:${PHP_VERSION}-fpm-alpine AS builder

WORKDIR /src

COPY ./app .

RUN set -eux; \
    rm -rf tests \
        .git \
        .gitignore \
        .env.test \
        phpunit.xml.dist \
        phpstan.dist.neon \
        node_module

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 01 : Pull official base image
# ----------------------------------------------------------------------------------------------------------------------
FROM php:${PHP_VERSION}-fpm-alpine AS final

LABEL title="Symfony"
LABEL purpose="webapp"
LABEL description="Prod Environment"

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 02 : Set environment variables
# ----------------------------------------------------------------------------------------------------------------------
RUN echo "[ PHP ] Set environment variables"

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    TZ="Asia/Seoul"

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 03 : Set Work directory
# ----------------------------------------------------------------------------------------------------------------------
RUN echo "[ PHP ] Set Work directory "

WORKDIR /var/www/app

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 04 : Install packages
# ----------------------------------------------------------------------------------------------------------------------
RUN echo "[ PHP ] Install packages"

RUN set -eux; \
    # [Runtime-deps]
    apk add --no-cache \
        nginx \
        supervisor \
        libpq \
        libzip \
        libxml2 \
        libpng \
        libjpeg-turbo \
        freetype \
        icu \
        icu-libs \
        curl \
        rabbitmq-c \
        tzdata; \
    \
    # [Build-deps]
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        linux-headers \
        libzip-dev \
        libpq-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        icu-dev \
        curl-dev \
        rabbitmq-c-dev; \
    \
    # PHP Core Extensions
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j$(nproc) \
        gd \
        sockets \
        intl \
        zip \
        pdo \
        pdo_pgsql \
        bcmath; \
    \
    # PECL Extensions (Redis, AMQP)
    pecl install redis amqp; \
    docker-php-ext-enable redis amqp opcache; \
    \
    # Clean up
    apk del .build-deps; \
    rm -rf /tmp/pear /var/cache/apk/*; \
    docker-php-source delete;

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 05 : Update configuration
# ----------------------------------------------------------------------------------------------------------------------
RUN echo "[ PHP ] Update a configuration"

# >>>> PHP
RUN rm -f "$PHP_INI_DIR/conf.d/php.ini"
RUN rm -f "$PHP_INI_DIR/php.ini-development"

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY scripts/containers/prod/app/php/etc/conf.d/docker-php-ext-opcache.ini "$PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini"

# >>>> PHP-FPM
RUN rm -f /usr/local/etc/php-fpm.conf.default
RUN rm -f /usr/local/etc/php-fpm.d/www.conf.default
RUN rm -f /usr/local/etc/php-fpm.d/zz-docker.conf
#COPY scripts/containers/prod/app/php/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# >>>> Nginx
RUN rm -f /etc/nginx/http.d/default.conf
#RUN sed -i 's/user nginx;/user root;/g' /etc/nginx/nginx.conf
#RUN sed -i 's/user nginx;/user www-data;/g' /etc/nginx/nginx.conf
#COPY scripts/containers/prod/server/nginx/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY scripts/containers/prod/server/nginx/etc/nginx/http.d/www.conf /etc/nginx/http.d/www.conf

# >>>> Supervisor
RUN mkdir -p /etc/supervisor.d
#COPY scripts/containers/prod/server/supervisor/etc/supervisord.conf /etc/supervisord.conf
COPY scripts/containers/prod/server/supervisor/etc/supervisor.d/messenger-consume.ini /etc/supervisor.d/messenger-consume.ini

# >>>> Entrypoint
COPY scripts/containers/prod/server/entrypoint.sh /usr/local/bin/entrypoint

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 06 : Copy source files
# ----------------------------------------------------------------------------------------------------------------------
RUN echo "[ PHP ] Copy source files"

# >>>> App - PHP - Symfony Framework
COPY --from=builder --chown=www-data:www-data /src /var/www/app

RUN set -eux; \
    rm -rf /var/www/app/tests; \
    rm -rf /var/www/app/var/cache/dev; \
    rm -f /var/www/app/var/log/dev.log; \
    rm -f /var/www/app/var/log/xdebug.log; \
    rm -f /var/www/app/.editorconfig; \
    rm -f /var/www/app/.gitattributes; \
    rm -f /var/www/app/.php-cs-fixer.dist.php; \
    rm -f /var/www/app/phpunit.xml.dist; \
    rm -f /var/www/app/phpstan.dist.neon; \
    rm -rf /var/www/html; \
    rm -rf /var/www/localhost; \
    chmod -R 777 /var/www/app/var; \
    chown -R www-data:www-data /var/www/app/var;
    #chown -R www-data:www-data /var/www/app;

# >>>> PHP-FPM
#RUN set -eux; \
#    mkdir -p /var/log/php-fpm; \
#    chmod -R 775 /var/log/php-fpm;

# >>>> Nginx
RUN set -eux; \
    mkdir -p /var/log/nginx; \
    chmod -R 775 /var/log/nginx;

# >>>> Entrypoint
RUN set -eux; \
    chmod +x /usr/local/bin/entrypoint;

# ----------------------------------------------------------------------------------------------------------------------
# STEP - 07 : Start the service
# ----------------------------------------------------------------------------------------------------------------------
EXPOSE 8080/tcp

# >>>> Shell-script
ENTRYPOINT ["entrypoint"]
