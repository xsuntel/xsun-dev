# Scripts - Docker Containers

## Platform

* Linux
* MacOS
* Windows

## Project

### Docker - Containerss

* Cache : Redis
* Database : PostgreSQL
* Message : RabbitMQ
* Utility : pgAdmin

```bash
vi ./docker-composer.env

# ======================================================================================================================
# Symfony Framework - Dev Environment                                    https://symfony.com/doc/current/deployment.html
# ======================================================================================================================

# ----------------------------------------------------------------------------------------------------------------------
# Architecture
# ----------------------------------------------------------------------------------------------------------------------

# >>>> Cache
REDIS_LOCALHOST_PORT=6379                                             # REDIS_NETWORK_PORT    ---> REDIS_PORT      6379

# >>>> Database
POSTGRES_LOCALHOST_PORT=5432                                          # POSTGRES_NETWORK_PORT ---> POSTGRES_PORT   5432
POSTGRES_DB={Your default Database}
POSTGRES_USER={Your Name}
POSTGRES_PASSWORD={Your Password}

# >>>> Message
RABBITMQ_LOCALHOST_PORT=5672                                          # RABBITMQ_NETWORK_PORT ---> POSTGRES_PORT   5672
RABBITMQ_WEBSITE_PORT=15672

# ----------------------------------------------------------------------------------------------------------------------
# Utility
# ----------------------------------------------------------------------------------------------------------------------

# >>>> pgAdmin
PGADMIN_WEBSITE_PORT=5050                                             # PGADMIN_NETWORK_PORT  ---> POSTGRES_PORT   5433
PGADMIN_MAIL={Your Email}
PGADMIN_PW={Your Password}

## Deployment

* Docker

```bash
docker login -u <username>

vi ~/.docker/config.json
```

```bash
sudo vi /etc/docker/daemon.json

{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "userland-proxy": false
}

sudo systemctl restart docker
```

```bash
docker-compose down

docker network prune -f

docker-compose up -d

```

```bash
sudo lsof -i | grep docker-pr
```

```bash
sudo fuser -k 6379/tcp
sudo fuser -k 5432/tcp
sudo fuser -k 5672/tcp
```

## Reference

### Tools

* [Release notes](https://docs.docker.com/desktop/release-notes/)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
