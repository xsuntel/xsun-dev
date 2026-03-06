# Dev Environment

## Platform

* MacOS
  * App : PHP
  * Cache : Redis (Docker Container)
  * Database : PostgreSQL (Docker Container)
  * Message : RabbitMQ (Docker Container)
  * Server : Symfony Local Server
  * Tools : Docker Desktop : [Download](https://www.docker.com/products/docker-desktop/)

## Project

### App - Symfony Framework

* Update default variables in Dev Environment

```bash
vi .env.dev

# ======================================================================================================================
# Symfony Framework - Dev Environment                                    https://symfony.com/doc/current/deployment.html
# ======================================================================================================================

# >>>> Cache
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# >>>> Database
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432                                                    # POSTGRES_NETWORK_PORT ---> POSTGRES_PORT   5432
POSTGRES_DB={Your default Database}
POSTGRES_USER={Your Name}
POSTGRES_PASSWORD={Your Password}

# >>>> Message
RABBITMQ_VERSION=3
RABBITMQ_HOST=127.0.0.1
RABBITMQ_PORT=5672

# >>>> Server
NGINX_HOST=127.0.0.1
NGINX_PORT=8000
```

* Update a part of configurations for twig in dev

```bash
vi {project_directory}/app/config/packages/dev/twig.yaml

when@dev:
  twig:
    debug: true
    cache: ./app/var/cache/dev
    auto_reload: true
    strict_variables: true
    #autoescape: html
    #optimizations: -1
```

### Database - PostgreSQL : [Docker Desktop - Download](https://www.docker.com/products/docker-desktop/)

* Configure the database

```bash
vi .env.dev.local

# ======================================================================================================================
# Symfony Framework - Dev Environment - Local                            https://symfony.com/doc/current/deployment.html
# ======================================================================================================================

# >>>> Database - PostgreSQL - Docker
POSTGRES_PORT=15432
```

* Update docker-compose's variables in Dev Environment

```bash
vi docker/containers/docker-compose.env.dev

# ----------------------------------------------------------------------------------------------------------------------
# Build
# ----------------------------------------------------------------------------------------------------------------------

# >>>> Database
POSTGRES_NETWORK_BACKEND_IP_ADDRESS=172.21.0.31
POSTGRES_NETWORK_PORT=15432
POSTGRES_HOST=${POSTGRES_NETWORK_BACKEND_IP_ADDRESS}
POSTGRES_PORT=5432
POSTGRES_DB=app
POSTGRES_USER=symfony
POSTGRES_PASSWORD=!ChangeMe!

# ----------------------------------------------------------------------------------------------------------------------
# Tools
# ----------------------------------------------------------------------------------------------------------------------
# >>>> Database - pgAdmin                                                        https://hub.docker.com/r/dpage/pgadmin4
PGADMIN_NETWORK_FRONTEND_IP_ADDRESS=172.11.0.61
PGADMIN_NETWORK_BACKEND_IP_ADDRESS=172.21.0.61
PGADMIN_NETWORK_PORT=15433
PGADMIN_HOST=${PGADMIN_NETWORK_BACKEND_IP_ADDRESS}
PGADMIN_DEFAULT_EMAIL=pgadmin@example.com
#PGADMIN_DEFAULT_EMAIL=${GIT_CONFIG_LOCAL_USER_EMAIL}
PGADMIN_DEFAULT_PASSWORD=!ChangeMe!
PGADMIN_MAIL=${PGADMIN_DEFAULT_EMAIL}
PGADMIN_PW=${PGADMIN_DEFAULT_PASSWORD}

# >>>> Mailer                                                            https://hub.docker.com/r/schickling/mailcatcher
MAILER_NETWORK_BACKEND_IP_ADDRESS=172.21.0.71
MAILER_NETWORK_HTTP_PORT=1180
MAILER_NETWORK_SMTP_PORT=1125
```

### Message - RabbitMQ

* Install a package

```bash
brew search rabbitmq-c
brew install rabbitmq-c

ls -ltr /opt/homebrew/Cellar/rabbitmq-c/{version}
```

* Update a configuration

```bash
Set the path to librabbitmq install prefix [autodetect] : /opt/homebrew/Cellar/rabbitmq-c/{version}
```

* Check local website

```text
http://localhost:15672

    - ID : guest
    - PW : guest
```

### Server - Localhost

* Symfony Local Server in Dev Environment

```bash
vi ./scripts/deploy/dev/.symfony.local.yaml

# ----------------------------------------------------------------------------------------------------------------------
# Local Web Server                                                                            PATH : "${PROJECT_PATH}"/app
# ----------------------------------------------------------------------------------------------------------------------
http:
  document_root: public/
  passthru: index.php
  port: 8000
  preferred_port: 8001
  #p12: ./config/authentication/p12_cert
  allow_http: true
  no_tls: true
  daemon: true
  use_gzip: true
  no_workers: true
```

## Deployment

* Deploy this project

```bash
./scripts/deploy/dev/macos/device/deploy.sh
```

### App

* Clear cache

```bash
./scripts/deploy/cache.sh
```

### Database

* Migrate databases

```bash
./scripts/deploy/migrate.sh
```

### Server

* Check status

```bash
./scripts/deploy/status.sh
```

## Reference

* [MacOS](https://www.apple.com/kr/macos)
