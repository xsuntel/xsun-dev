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
      # Directory
      # ----------------------------------------------------------------------------------------------------------------

      # >>>> src
      if [ -f ./src/Controller/.gitignore ]; then
        rm -f ./src/Controller/.gitignore
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

    else
      echo "[ ERROR ] There is not a command : app/bin/console"
      exit 1
    fi
  )
fi

# >>>> Node
if [ -d node_modules ]; then
  rm -rf node_modules
fi

if [ -d vendor ]; then
  rm -rf vendor
fi

if [ -d var ]; then
  rm -rf var
fi

# >>>> Project Files
FILES_TO_DELETE=(
  # Composer
  "composer.phar"
  "composer.json"
  "composer.lock"
  # Node
  "package.json"
  "package-lock.json"
  "npm-debug.log"
  "yarn-error.log"
  # Tools
  "phing-latest.phar"
  ".php-cs-fixer.cache"
  ".phpunit.result.cache"
  "./tests/.phpunit.result.cache"
  # Docker
  "./app/Dockerfile"
  "./app/docker-compose.yml"
)

for file in "${FILES_TO_DELETE[@]}"; do
  if [ -f "$file" ]; then
    rm -f "$file"
  fi
done
