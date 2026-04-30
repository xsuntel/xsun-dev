#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Base - Project
# ======================================================================================================================

# >>>> Environment
if [ -z "${ENVIRONMENT_NAME}" ]; then
  echo "Error: ENVIRONMENT_NAME variable is not set."
  exit 1
fi

# >>>> Platform
if [ "${ENVIRONMENT_NAME}" == "dev" ]; then
  if [ "${PLATFORM_TYPE}" == "Linux" ]; then
    echo
  elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
    echo
  elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
    echo
  else
    echo "Please check Operating System"
    setExit
  fi
fi

# >>>> Projects
if [ -f "${PROJECT_PATH}"/.env.app ]; then
  source "${PROJECT_PATH}"/.env.app
else
  echo "Please check .env file : ${PROJECT_PATH}/.env.app" && exit
fi

# ----------------------------------------------------------------------------------------------------------------------
# Directory - App
# ----------------------------------------------------------------------------------------------------------------------

if [ -d app ]; then
  (
    cd app || return

    # >>>> PHP - Symfony Command                                         https://symfony.com/doc/current/deployment.html
    if [ -f bin/console ]; then

      # ----------------------------------------------------------------------------------------------------------------
      # Directory
      # ----------------------------------------------------------------------------------------------------------------

      # >>>> assets
      if [ -f assets/controllers/hello_controller.js ]; then
        rm -f assets/controllers/hello_controller.js
        echo
      fi

      # >>>> migrations
      if [ ! -d migrations ]; then
        mkdir migrations
      fi

      # >>>> node_modules
      if [ ! -d node_modules ]; then
        mkdir node_modules
      fi

      # >>>> public
      if [ -d public ]; then
        if [ -f public/0.meta.json ]; then
          rm -f public/[0-9]
          rm -f public/[0-9].meta
          rm -f public/[0-9].meta.json
        fi
      fi

      # >>>> src
      if [ -f ./src/Controller/.gitignore ]; then
        rm -f ./src/Controller/.gitignore
      fi

      # >>>> templates
      if [ -f templates/base.html.twig ]; then
        rm -f templates/base.html.twig
        echo
      fi

      # >>>> translations
      if [ -f ./translations/.gitignore ]; then
        rm -f ./translations/.gitignore
      fi

      # ----------------------------------------------------------------------------------------------------------------
      # Files
      # ----------------------------------------------------------------------------------------------------------------

      # >>>> .gitignore
      if [ -f ./.gitignore ]; then
        rm -f ./.gitignore
      fi

      # >>>> .env.${ENVIRONMENT_NAME}
      rm -f .env.*
      rm -f .env.*.local

      # >>>> .env.test
      if [ -f .env.test ]; then
        rm -f .env.test
      fi

      # >>>> php-cs-fixer
      if [ -f .php-cs-fixer.cache ]; then
        rm -f .php-cs-fixer.cache
      fi

      # >>>> phpunit
      if [ -f .phpunit.result.cache ]; then
        rm -f .phpunit.result.cache
      fi

      # >>>> App - PHP - Symfony local server
      if [ -f .symfony.local.yaml ]; then
        rm -f .symfony.local.yaml
      fi

    fi
  )
else
  echo
  echo "[ ERROR ] There is not a folder : app"
  echo
  setExit
fi

# >>>> Node
if [ -d node_modules ]; then
  rm -rf node_modules
fi

# >>>> composer
if [ -f composer.phar ]; then
  rm -f composer.phar
fi

if [ -f composer.json ]; then
  rm -f composer.json
fi

if [ -f composer.lock ]; then
  rm -f composer.lock
fi

# >>>> package
if [ -f package.json ]; then
  rm -f package.json
fi

if [ -f package-lock.json ]; then
  rm -f package-lock.json
fi

# >>>> webpack-encore
if [ -f npm-debug.log ]; then
  rm -f npm-debug.log
fi

if [ -f yarn-error.log ]; then
  rm -f yarn-error.log
fi

# >>>> phing-latest.phar
if [ -f phing-latest.phar ]; then
  rm -f phing-latest.phar
fi

# >>>> php-cs-fixer
if [ -f .php-cs-fixer.cache ]; then
  rm -f .php-cs-fixer.cache
fi

# >>>> phpunit
if [ -f .phpunit.result.cache ]; then
  rm -f .phpunit.result.cache
fi

if [ -f ./tests/.phpunit.result.cache ]; then
  rm -f ./tests/.phpunit.result.cache
fi

# >>>> Docker
FILES_TO_DELETE=(
  "./app/Dockerfile"
  "./app/docker-compose.yml"
)

for file in "${FILES_TO_DELETE[@]}"; do
  if [ -f "$file" ]; then
    echo ">>>> Deleting: $file"
    rm -v "$file"
  fi
done

# >>>> Python
if [ -d .vendor ]; then
  rm -rf .vendor
fi

if [ -d var ]; then
  rm -rf var
fi

# ----------------------------------------------------------------------------------------------------------------------
# Directory - Scripts
# ----------------------------------------------------------------------------------------------------------------------

# >>>> Deploy - Dev - Linux
if [ -f sudo ]; then
  rm -f sudo
fi

# >>>> Deploy - Dev - MacOS


# >>>> Deploy - Dev - Windows
find ./ -name ".DS_Store" -type f -exec rm -f {} \;
find ./ -name ".DS_Store" -type d -exec rm -rf {} \;
echo
