#!/bin/bash

set -euo pipefail

# ======================================================================================================================
# Claude Code - Hook
# ======================================================================================================================

find_project_root() {
  PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  while [[ "${PROJECT_DIR}" != "/" ]]; do
    if [[ -d "${PROJECT_DIR}/.git" ]] || [[ -f "${PROJECT_DIR}/.env.app" ]]; then
      echo "${PROJECT_DIR}"
      return 0
    fi
    PROJECT_DIR="$(dirname "${PROJECT_DIR}")"
  done
  return 1
}

PROJECT_PATH=$(find_project_root)
cd "${PROJECT_PATH}" || exit

# ======================================================================================================================
# Project
# ======================================================================================================================

if [ -d app ]; then
  (
    cd app || return
    if [ -f bin/console ]; then

      # ----------------------------------------------------------------------------------------------------------------
      # App - Symfony Framework - Deployment - Other Things              https://symfony.com/doc/current/deployment.html
      # ----------------------------------------------------------------------------------------------------------------
      if [ -f ./vendor/bin/php-cs-fixer ]; then
        echo ">>>> PHP - Symfony Framework - Bundles - PHP-CS-Fixer"
        echo

        ./vendor/bin/php-cs-fixer fix ./src
        echo
      fi

      # ----------------------------------------------------------------------------------------------------------------
      # A) Check Requirements
      # ----------------------------------------------------------------------------------------------------------------
      echo ">>>> PHP - Symfony Framework - Deployment - A) Check Requirements"
      echo

      echo "Dev Environment"
      echo

      # ----------------------------------------------------------------------------------------------------------------
      # B) Configure your Environment Variables
      # ----------------------------------------------------------------------------------------------------------------
      echo ">>>> PHP - Symfony Framework - Deployment - B) Configure your Environment Variables"
      echo

      echo "Dev Environment"
      echo

      # ----------------------------------------------------------------------------------------------------------------
      # C) Install/Update your Vendors
      # ----------------------------------------------------------------------------------------------------------------
      echo ">>>> PHP - Symfony Framework - Deployment - C) Install/Update your Vendors"
      echo

      APP_ENV=dev APP_DEBUG=1 composer install --ignore-platform-req=ext-redis --ignore-platform-req=ext-amqp --ignore-platform-req=ext-pdo_pgsql
      echo

      # ----------------------------------------------------------------------------------------------------------------
      # D) Clear your Symfony Cache
      # ----------------------------------------------------------------------------------------------------------------
      echo ">>>> PHP - Symfony Framework - Deployment - D) Clear your Symfony Cache"
      echo

      APP_ENV=dev APP_DEBUG=1 php bin/console cache:clear
      echo

      # ----------------------------------------------------------------------------------------------------------------
      # H) Other Things - Webpack Encore or AssetMapper
      # ----------------------------------------------------------------------------------------------------------------
      echo ">>>> PHP - Symfony Framework - Deployment - H) Other Things - Webpack Encore or AssetMapper"
      echo

      symfony console asset-map:compile
      echo

    else
      echo "[ ERROR ] There is not a command : app/bin/console"
      setExit
    fi
  )
fi
