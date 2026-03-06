# Scripts - Docker

## Platform - Linux / MacOS / Windows

## Project

### Docker - Containerss

* App : PHP + Nginx + Supervisor

```bash
vi .env.prod.local

# ======================================================================================================================
# Symfony Framework - Prod Environment                                   https://symfony.com/doc/current/deployment.html
# ======================================================================================================================

# >>>> Cache - Redis
REDIS_HOST=127.0.0.1                                                                    # <<<< Docker - Container's Name
REDIS_PORT=6379

# >>>> Database - PostgreSQL
POSTGRES_HOST=127.0.0.1                                                                 # <<<< Docker - Container's Name
POSTGRES_PORT=5432

# >>>> Message - RabbitMQ
RABBITMQ_HOST=127.0.0.1                                                                 # <<<< Docker - Container's Name
RABBITMQ_PORT=5672

# >>>> Server - Nginx
NGINX_SCHEME=http
NGINX_HOST=127.0.0.1
NGINX_PORT=8000
```

### Deployment

* Test this project

```bash
./scripts/containers/prod/test.sh
```

## Reference

### Tools

* [Release notes](https://docs.docker.com/desktop/release-notes/)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
