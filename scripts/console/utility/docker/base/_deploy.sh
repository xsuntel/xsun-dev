#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Base - Utility - Docker
# ======================================================================================================================

  echo ">>>> Docker - Clear Network"
  echo

  docker network prune -f
  echo

  echo ">>>> Docker - Copy docker-compose.yml"
  echo

  if [ -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" ]; then
    cp -fv "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" "${PROJECT_PATH}"
    echo
  fi

  if [ -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" ]; then
    cp -fv "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" "${PROJECT_PATH}"
    echo
  fi
  echo

  echo ">>>> Docker - Check docker-compose.yml"
  echo

  docker compose -f "docker-compose.yml" --env-file ".env.app" --env-file "docker-compose.env" config
  echo

  echo ">>>> Docker - Build docker images"
  echo
  if [ -f "${PROJECT_PATH}"/.env.app ] && [ -f "${PROJECT_PATH}"/docker-compose.env ] && [ -f "${PROJECT_PATH}"/docker-compose.yml ]; then
    if [ "${ENVIRONMENT_NAME}" == "prod" ]; then
      docker compose -f "docker-compose.yml" --env-file ".env.app" --env-file "docker-compose.env" build --no-cache
    else
      local CURRENT_TIME
      CURRENT_TIME=$(date +%s)
      docker compose -f "docker-compose.yml" --env-file ".env.app" --env-file "docker-compose.env" build --build-arg "DISABLE_CACHE_PHP_DOCKERFILE=${CURRENT_TIME}"
    fi
    echo
  else
    echo "There is not docker-compose.yml"
    echo
  fi

  echo ">>>> Docker - Start docker containers"
  echo

  docker compose -f "docker-compose.yml" --env-file ".env.app" --env-file "docker-compose.env" up --pull always -d
  echo
