# README

## Abstract

This project includes some shell-scripts for Full-Stack developer to develop a web application using Symfony Framework

## Environment

* Dev
  * App : PHP - Symfony Framework
  * Cache : Redis, Memcached
  * Database : PostgreSQL, MySQL
  * Message : RabbitMQ, Redis
  * Server : Nginx, Apache

## Platform

* Linux
* MacOS
* Windows

## Project

```text
.
├── api/
├── app/
│                   <-- PHP - Symfony Framework -- >
├── diagram/
│   ├── base/
│   ├── console/
│   ├── containers/
│   └── deploy/
├── scripts/
│   ├── base/
│   ├── console/
│   ├── containers/
│   └── deploy/
├── tools/
│   ├── ai/
│   ├── ide/
│   └── tutorial.sh
├── .env.base
├── .env.dev
├── .env.dev.local
├── .env.prod
├── .env.prod.local
├── .gitattributes
├── .gitignore
├── .shellcheckrc
├── LICENSE
└── README.md
```

### Dev Environment

#### Requirement

* Update your name and email for Git

  ```bash
  git config --global user.name "{Your Name}"
  git config --global user.email "{Your Email}"
  ```

  ```bash
  git config --global init.defaultBranch main
  git config --global credential.helper store

  git config --global --list
  ```

#### Work Directory

* Create a folder (example)

  ```bash
  mkdir -p ~/Documents/Tools
  mkdir -p ~/Documents/Tools/GitHub

  cd ~/Documents/Tools/GitHub
  ```

* Download the application

  ```bash
  git clone https://github.com/xsuntel/xsun-dev.git symfony
  ```

  ```bash
  cd symfony && find ./scripts/ -type f -name "*.sh" -exec chmod 775 {} \;
  ```

* Update default variables
  * [TimeZone](https://www.php.net/manual/en/timezones.php)
  * [Symfony Releases](https://symfony.com/releases)

  ```text
  vi env.app

  # >>>> Platform
  PLATFORM_TIMEZONE="{Your TimeZone}"

  # >>>> Project
  PROJECT_DOMAIN="{Your Web domain}"

  # >>>> PHP
  SYMFONY_VERSION="{Stable Release}"
  ```

#### New Project

* Create a new project

  ```bash
  ./tools/tutorial/symfony.sh
  ```

  * Reference : [Installing & Setting up the Symfony Framework](https://symfony.com/doc/current/setup.html)

#### Tools

* AI
  * Antigravity - [Document](https://github.com/xsuntel/xsun-dev/blob/main/tools/ai/antigravity/_ABSTRACT.md)
  * Claude
  * Cursor
* IDE
  * PhpStorm    - [Document](https://github.com/xsuntel/xsun-dev/blob/main/tools/ide/phpstorm/_ABSTRACT.md)
  * VSCode      - [Document](https://github.com/xsuntel/xsun-dev/blob/main/tools/ide/vscode/_ABSTRACT.md)

#### Deployment in Dev

* Platform
  * Linux - [Document](https://github.com/xsuntel/xsun-dev/blob/main/scripts/deploy/dev/linux/ubuntu/_ABSTRACT.md)
  * Macos - [Document](https://github.com/xsuntel/xsun-dev/blob/main/scripts/deploy/dev/macos/device/_ABSTRACT.md)
  * Windows - [Document](https://github.com/xsuntel/xsun-dev/blob/main/scripts/deploy/dev/windows/device/_ABSTRACT.md)

* Devices - [Laptop](https://github.com/xsuntel/xsun-dev/wiki)

### Prod Environment

#### Deployment in Prod

* Public Cloud
  * AWS (Amazon Web Services)
  * GCP (Google Cloud Platform)
  * NCloud (Naver Cloud Platform)

## Tutorial

* [Symfony Framework](https://symfony.com)
* [SymfonyCasts](https://symfonycasts.com)

## Reference

* Website - [XSUN.AI](https://xsun.ai)

## License

This is available under the MIT License.
