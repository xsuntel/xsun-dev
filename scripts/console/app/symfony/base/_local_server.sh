#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Base - App - Symfony Framework - Local Web Server  https://symfony.com/doc/current/setup/symfony_server.html
# ======================================================================================================================

# >>>> Directory
if [ -d app ]; then
  (
    cd app || return
    # >>>> PHP - Symfony Command
    if [ -f bin/console ]; then

      # >>>> Environment
      if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

        # >>>> Platform
        echo ">>>> PHP - Symfony - Local Web Server"
        echo

        # >>>> App - PHP - Symfony CLI - PHP
        symfony local:php:list
        echo

        # ------------------------------------------------------------------------------------------------------------
        # Platform - Linux
        # ------------------------------------------------------------------------------------------------------------
        if [ "${PLATFORM_TYPE}" == "Linux" ]; then
          local LOCAL_LISTEN_PORT
          LOCAL_LISTEN_PORT=$(netstat -an | grep -i LISTEN | grep -v tcp6 | grep ".8000" | awk '{print $6}')
          if [ "${LOCAL_LISTEN_PORT}" == "LISTEN" ]; then
            symfony local:server:stop
            echo
          fi

          # >>>> PHP - Symfony - Local Web Server - Enabling TLS
          if [ ! -f ~/.symfony-cli/certs/default.p12 ]; then
            symfony server:ca:install
          fi

        # ------------------------------------------------------------------------------------------------------------
        # Platform - MacOS
        # ------------------------------------------------------------------------------------------------------------
        elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
          local LOCAL_LISTEN_PORT
          LOCAL_LISTEN_PORT=$(netstat -an | grep -i LISTEN | grep -v tcp6 | grep ".8000" | awk '{print $6}')
          if [ "${LOCAL_LISTEN_PORT}" == "LISTEN" ]; then
            symfony local:server:stop
            echo
          fi

          # >>>> PHP - Symfony - Local Web Server - Enabling TLS
          if [ ! -f ~/.symfony-cli/certs/default.p12 ]; then
            symfony server:ca:install
          fi

        # ------------------------------------------------------------------------------------------------------------
        # Platform - Windows
        # ------------------------------------------------------------------------------------------------------------
        elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
          local LOCAL_LISTEN_PORT
          LOCAL_LISTEN_PORT=$(netstat -an | grep -i LISTEN | grep -v tcp6 | grep "8000" | awk '{print $6}')
          if [ "${LOCAL_LISTEN_PORT}" == "LISTEN" ]; then
            symfony local:server:stop
            echo
          fi

          # >>>> PHP - Symfony - Local Web Server - Enabling TLS
          symfony server:ca:install

        else
          echo "Please check Operating System"
          setExit
        fi

        # >>>> PHP - Symfony - Local Web Server
        if [ -f ../scripts/deploy/dev/.symfony.local.yaml ]; then
          cp -fv ../scripts/deploy/dev/.symfony.local.yaml .symfony.local.yaml
          echo
        fi

        if [ -f .symfony.local.yaml ]; then
          symfony server:ls
          echo

          symfony local:server:stop
          symfony local:server:start
          echo

          symfony server:status

        else
          echo "[ ERROR ] There is not a file : .symfony.local.yaml"
          setExit
        fi

      else

        if [ -f .symfony.local.yaml ]; then
          rm -f .symfony.local.yaml
        fi

      fi
      echo

    else
      echo "[ ERROR ] There is not a command : app/bin/console"
      setExit
    fi
  )
fi
echo



