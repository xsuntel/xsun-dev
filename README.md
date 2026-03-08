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
  * Utility : Git, Docker
  * Tools : PhpStorm, VSCode

* Prod
  * AWS (Amazon Web Services)
  * GCP (Google Cloud Platform)
  * NCloud (Naver Cloud Platform)

## Platform

* Linux
* MacOS
* Windows

## Project

```text
.
├── api/
├── app/
│   ├── Symfony Framework
├── diagram/
│   ├── console/
│   ├── containers/
│   └── deploy/
├── scripts/
│   ├── console/
│   ├── containers/
│   └── deploy/
├── tools/
│   ├── ai/
│   ├── ide/
│   └── tutorial.sh
├── .env.base
├── .env.dev
├── .env.prod
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
  ```

  ```bash
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

* Download this project

  ```bash
  git clone https://github.com/xsuntel/php-symfony.git symfony
  ```

  ```bash
  cd symfony && find ./scripts/ -type f -name "*.sh" -exec chmod 775 {} \;
  ```

* Update default variables : [TimeZone](https://www.php.net/manual/en/timezones.php) / [Symfony Releases](https://symfony.com/releases)

  ```text
  vi env.app

  # >>>> Platform
  PLATFORM_TIMEZONE="{Your TimeZone}"

  # >>>> Project
  PROJECT_DOMAIN="{Your Web domain}"

  # >>>> PHP
  SYMFONY_VERSION="{Stable Release}"
  ```

* Create a new webapp : [Installing & Setting up the Symfony Framework](https://symfony.com/doc/current/setup.html)

  ```bash
  ./tools/tutorial.sh
  ```

#### Deployment

* Platform
  * Linux - [Document](https://github.com/xsuntel/php-symfony/blob/main/scripts/deploy/dev/linux/ubuntu/_ABSTRACT.md)
  * Macos - [Document](https://github.com/xsuntel/php-symfony/blob/main/scripts/deploy/dev/macos/device/_ABSTRACT.md)
  * Windows - [Document](https://github.com/xsuntel/php-symfony/blob/main/scripts/deploy/dev/windows/device/_ABSTRACT.md)

* Devices - [Laptop](https://github.com/xsuntel/php-symfony/wiki)

#### Tools

* AI
  * [Antigravity](https://antigravity.google/) - [Document](https://github.com/xsuntel/php-symfony/blob/main/tools/ai/google/antigravity/_ABSTRACT.md)
  * [Claude](https://claude.com/) - [Document](https://github.com/xsuntel/php-symfony/blob/main/tools/ai/claude/code/_ABSTRACT.md)
  * [Cursor](https://claude.ai) - [Document](https://github.com/xsuntel/php-symfony/blob/main/tools/ai/cursor/cli/_ABSTRACT.md)
  * [Copilot](https://copilot.microsoft.com/) - [Document](https://github.com/xsuntel/php-symfony/blob/main/tools/ai/microsoft/copilot/_ABSTRACT.md)
* IDE
  * [PhpStorm](https://www.jetbrains.com/phpstorm)    - [Document](https://github.com/xsuntel/php-symfony/blob/main/tools/ide/phpstorm/_ABSTRACT.md)
  * [Visual Studio Code](https://code.visualstudio.com/)      - [Document](https://github.com/xsuntel/php-symfony/blob/main/tools/ide/vscode/_ABSTRACT.md)

### Prod Environment

#### Public Cloud

* [AWS (Amazon Web Services)](https://aws.amazon.com) - ECS
* [GCP (Google Cloud Platform)](https://cloud.google.com/) - Cloud Run
* [NCloud (Naver Cloud Platform)](https://www.ncloud.com) - VM

## Reference

* [PHP](https://www.php.net)
  * [Symfony Framework](https://symfony.com)
    * [SymfonyCasts](https://symfonycasts.com)

## License

This is available under the MIT License.
