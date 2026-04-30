# README

This project includes some shell-scripts for Full-Stack developer to develop a web application using Symfony Framework

## Environment

* Dev
  * App : PHP - Symfony Framework
  * Cache : Redis
  * Database : PostgreSQL
  * Message : RabbitMQ, Redis
  * Server : Nginx, Apache
  * Utility : Git, Docker
  * Tools : PhpStorm, VSCode

* Prod
  * AWS (Amazon Web Services)
  * GCP (Google Cloud Platform)
  * NCloud (Naver Cloud Platform)

## Platform

* Linux - Ubuntu
* MacOS
* Windows - WSL2

## Project

```text
.
├── app/
│   └── PHP - Symfony Framework
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
│   └── ide/
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
  mkdir -p ~/Documents
  mkdir -p ~/Documents/Tools
  mkdir -p ~/Documents/Tools/GitHub

  cd ~/Documents/Tools/GitHub
  ```

* Download this project

  ```bash
  git clone https://github.com/xsuntel/xsun-dev.git symfony
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
  SYMFONY_VERSION="{Symfony Releases}"
  ```

* Create a new webapp : [Installing & Setting up the Symfony Framework](https://symfony.com/doc/current/setup.html)

  ```bash
  ./tools/ide/tutorial.sh
  ```

#### Deployment

* Linux - [Document](https://github.com/xsuntel/xsun-dev/blob/main/deploy/dev/linux/ubuntu/_ABSTRACT.md)
* Macos - [Document](https://github.com/xsuntel/xsun-dev/blob/main/deploy/dev/macos/device/_ABSTRACT.md)
* Windows - [Document](https://github.com/xsuntel/xsun-dev/blob/main/deploy/dev/windows/device/_ABSTRACT.md)

### Prod Environment

#### Public Cloud

* [AWS (Amazon Web Services)](https://aws.amazon.com) - ECS
* [GCP (Google Cloud Platform)](https://cloud.google.com) - Cloud Run
* [NCloud (Naver Cloud Platform)](https://www.ncloud.com) - VM

## Tools

* AI
  * Anthropic - [Claude Code](https://claude.com)
  * Google - [Gemini Code Assist](https://codeassist.google/)
  * GitHub - [Copilot](https://copilot.microsoft.com)
* IDE
  * [PhpStorm](https://www.jetbrains.com/phpstorm)    - [Document](https://github.com/xsuntel/xsun-dev/blob/main/tools/ide/phpstorm/_ABSTRACT.md)
  * [Visual Studio Code](https://code.visualstudio.com)      - [Document](https://github.com/xsuntel/xsun-dev/blob/main/tools/ide/vscode/_ABSTRACT.md)

## Reference

* [PHP](https://www.php.net)
  * [Symfony Framework](https://symfony.com)
    * [SymfonyCasts](https://symfonycasts.com)

* [Laptop](https://github.com/xsuntel/xsun-dev/wiki)

## License

This is available under the MIT License.
