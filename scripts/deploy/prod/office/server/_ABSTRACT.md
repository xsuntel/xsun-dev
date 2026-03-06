# Scripts - Office - Local Server

## Environment - Prod

## Platform

### Linux - Ubuntu Desktop

* App : PHP
* Cache : Redis
* Database : PostgreSQL
* Message : RabbitMQ
* Server : Nginx

## Project

### App - Symfony Framework

* Update default variables in Dev Environment

```bash
vi .env.dev

# ======================================================================================================================
# Symfony Framework - Prod Environment                                   https://symfony.com/doc/current/deployment.html
# ======================================================================================================================

# >>>> Cache
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# >>>> Database
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_DB=company
POSTGRES_USER=symfony
POSTGRES_PASSWORD=!ChangeMe!

# >>>> Message
RABBITMQ_VERSION=3
RABBITMQ_HOST=127.0.0.1
RABBITMQ_PORT=15672

# >>>> Server
NGINX_HOST=127.0.0.1
NGINX_PORT=8082
```

### Database - PostgreSQL

* Configure the database

```bash
[root@localhost] sudo -i -u postgres
[sudo] password for user: {password}

postgres@localhost:~$ psql
psql (xx.y)
Type "help" for help.

postgres=# create user symfony password '!ChangeMe!' superuser;
CREATE ROLE
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 symfony   | Superuser                                                  | {}

postgres=# \q

```

* Change the user's password

```bash
sudo -i -u postgres
[sudo] password for user: {password}

postgres@localhost:~$ psql
psql (xx.y)
Type "help" for help.

postgres=# alter user {user_name} with password {user_password};

postgres=# \q

```

### Message - RabbitMQ

* Check local website

```text
http://localhost:15672

    - ID : guest
    - PW : guest
```

## Deployment

* Deploy this project

```bash
./scripts/cloud/office/server/ubuntu/deploy.sh
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

* [Ubuntu Desktop](https://ubuntu.com/desktop)
