# CLAUDE.md

This file configures Claude's behavior and expertise context for this project, Claude reads this file automatically when
working in this repository.

## Directory Structure & Path Context

The project infrastructure acts as a wrapper, and the related shell-script files in the `./scripts` directory.

```text
symfony-scripts/                             ← Repository root
└── scripts/                                 ← shell-script
    ├── base/                                ← Environment-independent install and configuration scripts
    │   ├── app/                             ← PHP 8.5 config files + Symfony app CLI scripts
    │   │   ├── php/                         ← PHP FPM/CLI config files (php.ini, pool.d)
    │   │   └── symfony/                     ← Symfony operation scripts (cache, database, message, assets)
    │   ├── cache/redis/                     ← Redis install and dev/prod configuration (redis.conf)
    │   ├── database/postgresql/             ← PostgreSQL installation
    │   ├── message/rabbitmq/                ← RabbitMQ installation
    │   ├── server/
    │   │   ├── nginx/                       ← Nginx installation and configuration (symfony.conf)
    │   │   └── supervisor/                  ← Supervisor installation + Messenger worker configuration
    │   ├── utility/
    │   │   ├── docker/                      ← Docker installation and deployment scripts
    │   │   └── git/                         ← Git configuration and local server scripts
    │   ├── _abstract.sh                     ← Shared functions and variable definitions
    │   ├── _environment.sh                  ← Environment variable setup
    │   ├── _platform.sh                     ← OS and platform detection
    │   └── _project.sh                      ← Project path configuration
    ├── containers/                          ← Docker container configuration
    │   ├── dev/                             ← Development docker-compose (Redis, PostgreSQL, RabbitMQ)
    │   └── prod/                            ← Production Dockerfile, entrypoint, Nginx/Apache, Supervisor
    ├── deploy/                              ← OS-specific environment deployment scripts
    │    ├── dev/
    │    │   ├── linux/ubuntu/               ← Ubuntu development server (packages, network, security, utilities)
    │    │   ├── macos/mac/                  ← macOS development environment
    │    │   └── windows/x86-64/             ← Windows development environment
    │    └── prod/
    │         └── office/server/             ← Production office server deployment
    └── CLAUDE.md
```

## Category Purpose

| Category | Purpose |
|---------|---------|
| `base/` | Environment-independent component install and config scripts — referenced by both `containers/` and `deploy/` |
| `containers/dev/` | Local development Docker environment — run infrastructure services via `docker-compose up` |
| `containers/prod/` | Production container image build and deployment scripts |
| `deploy/dev/` | OS-specific development machine initial setup — packages, network, and security configuration |
| `deploy/prod/` | Production server deployment scripts — executed via `deploy.sh` |

## Shared Function Pattern

`base/_abstract.sh` defines shared variables and helper functions used by all other scripts. `_environment.sh` sets
environment variables and `_platform.sh` detects the OS/arch. Source these at the top of any new script:

```bash
source "$(dirname "$0")/../../base/_abstract.sh"
```

## Usage

```bash
# Start development infrastructure (PostgreSQL, Redis, RabbitMQ) — run from project root
docker-compose -f scripts/containers/dev/docker-compose.yml up -d

# Initial Ubuntu dev server setup (run once on a new machine)
bash scripts/deploy/dev/linux/ubuntu/deploy.sh

# Production server deploy
bash scripts/deploy/prod/office/server/deploy.sh
```

## Key Scripts

| Script | Role |
|--------|------|
| `base/app/symfony/cache.sh` | Symfony cache clear and warm-up |
| `base/app/symfony/database.sh` | Doctrine migration execution |
| `base/app/symfony/message.sh` | Messenger worker management |
| `base/app/symfony/assets.sh` | AssetMapper asset compilation |
| `containers/dev/docker-compose.yml` | Development environment infrastructure service definitions |
| `containers/prod/deploy.sh` | Production container build and deployment |
| `deploy/dev/linux/ubuntu/deploy.sh` | Ubuntu development server initial setup |
| `deploy/prod/office/server/deploy.sh` | Production server deployment execution |
