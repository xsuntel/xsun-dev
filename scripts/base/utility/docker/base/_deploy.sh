#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Base - Utility - Docker
# ======================================================================================================================

if [ -f "${PROJECT_PATH}/.env.app" ] && [ -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" ] && [ -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" ]; then

  echo ">>>> Docker - Clear Network"
  echo

  docker network prune -f
  echo

  echo ">>>> Docker - Check docker-compose.yml"
  echo

  docker compose --profile core -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" --project-directory "${PROJECT_PATH}" --env-file "${PROJECT_PATH}/.env.app" --env-file "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" config
  echo

  echo ">>>> Docker - Build docker images"
  echo

  if [ "${ENVIRONMENT_NAME}" == "prod" ]; then
    docker compose --profile core -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" --project-directory "${PROJECT_PATH}" --env-file "${PROJECT_PATH}/.env.app" --env-file "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" build --no-cache
  else
    local CURRENT_TIME
    CURRENT_TIME=$(date +%s)
    docker compose --profile core -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" --project-directory "${PROJECT_PATH}" --env-file "${PROJECT_PATH}/.env.app" --env-file "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" build --build-arg "DISABLE_CACHE_PHP_DOCKERFILE=${CURRENT_TIME}"
  fi
  echo

  echo ">>>> Docker - Start docker containers"
  echo

  docker compose --profile core -f "${PROJECT_PATH}/scripts/containers/dev/docker-compose.yml" --project-directory "${PROJECT_PATH}" --env-file "${PROJECT_PATH}/.env.app" --env-file "${PROJECT_PATH}/scripts/containers/dev/docker-compose.env" up --pull always -d --remove-orphans
  echo

  echo ">>>> Docker - System"
  echo

  docker system prune -a -f --filter "label=purpose=webapp"
  echo

else
  echo "There is not docker-compose.yml"
  echo
fi
