#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Docker - Containers - Prod - Debug
# ======================================================================================================================

find_project_root() {
    local PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
PROJECT_NAME=$(basename "$(realpath "${PROJECT_PATH}")")
cd "${PROJECT_PATH}" || exit

# ----------------------------------------------------------------------------------------------------------------------
# Abstract
# ----------------------------------------------------------------------------------------------------------------------

if [ -f "${PROJECT_PATH}/scripts/console/_abstract.sh" ]; then
  source "${PROJECT_PATH}/scripts/console/_abstract.sh"
else
  echo "Please check a file : ./scripts/console/_abstract.sh" && exit
fi

# >>>> Environment

setEnvironment() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ENV ] ${PLATFORM_TYPE} - ${PLATFORM_PROCESSOR}"
  echo "---------------------------------------------------------------------------------------------------------------"
  # >>>> Select one of some environments
  PS3="Menu: "
  select num in "prod" "exit"; do
    case "$REPLY" in
    1)
      # >>>> Prod Environment
      ENVIRONMENT_NAME="prod"
      break
      ;;
    2)
      echo "exit()"
      setEnd
      ;;
    *)
      echo "[ ERROR ] Unknown Command"
      setEnd
      ;;
    esac
  done
  echo
}

# >>>> Platform

setPlatform() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Platform"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "- PLATFORM OS : ${PLATFORM_TYPE}"
  echo

  # >>>> Base
  if [ -f "${PROJECT_PATH}/scripts/console/_platform.sh" ]; then
    source "${PROJECT_PATH}/scripts/console/_platform.sh"
  else
    echo "Please check a file : ./scripts/console/_platform.sh" && exit
  fi
}

# >>>> Project

setProject() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Project"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "- PROJECT NAME : ${PROJECT_NAME}"
  echo

  # >>>> Directory
  if [ -f "${PROJECT_PATH}/scripts/console/_project.sh" ]; then
    source "${PROJECT_PATH}/scripts/console/_project.sh"
  else
    echo "Please check a file : ./scripts/console/_project.sh" && exit
  fi
}

# ----------------------------------------------------------------------------------------------------------------------
# Architecture
# ----------------------------------------------------------------------------------------------------------------------

# >>>> App

setPhp() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Base - App - Packages"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# >>>> Cache

setRedis() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Base - Cache - Packages"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# >>>> Database

setPostgreSQL() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Base - Database - Packages"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# >>>> Message

setRabbitMQ() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Base - Message - Packages"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo
}

# >>>> Server

setNginx() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Base - Server - Packages"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Linux
  # --------------------------------------------------------------------------------------------------------------------
  local LOCAL_LISTEN_PORT
  if [ "${PLATFORM_TYPE}" == "Linux" ]; then
    LOCAL_LISTEN_PORT=$(netstat -an | grep -i LISTEN | grep -v tcp6 | grep ".8080" | awk '{print $6}')
    if [ "${LOCAL_LISTEN_PORT}" == "LISTEN" ]; then
      sudo fuser -k 8080/tcp
    fi

  # --------------------------------------------------------------------------------------------------------------------
  # Platform - MacOS
  # --------------------------------------------------------------------------------------------------------------------
  elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
    LOCAL_LISTEN_PORT=$(netstat -an | grep -i LISTEN | grep -v tcp6 | grep ".8080" | awk '{print $6}')
    if [ "${LOCAL_LISTEN_PORT}" == "LISTEN" ]; then
      kill -9 $(lsof -ti:8080)
    fi

  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Windows
  # --------------------------------------------------------------------------------------------------------------------
  elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
    LOCAL_LISTEN_PORT=$(netstat -an | grep -i LISTEN | grep -v tcp6 | grep "8080" | awk '{print $6}')
    if [ "${LOCAL_LISTEN_PORT}" == "LISTEN" ]; then
      sudo fuser -k 8080/tcp
    fi

  else
    echo "Please check Operating System"
    setExit
  fi
  echo
}

# ----------------------------------------------------------------------------------------------------------------------
# Build Scripts
# ----------------------------------------------------------------------------------------------------------------------

setBuild() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Build"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  # >>>> PHP - Symfony Framework - .env.prod.local
  if [ -f "./scripts/containers/prod/.env.prod.local" ]; then
    cp -fv "./scripts/containers/prod/.env.prod.local" ./app/.env.prod.local
  fi
  echo

  # >>>> PHP - Symfony Framework - Deployment
  if [ -f "${PROJECT_PATH}/scripts/console/app/symfony/base/_deployment.sh" ]; then
    source "${PROJECT_PATH}/scripts/console/app/symfony/base/_deployment.sh"
  else
    echo "Please check a file : ./scripts/console/app/symfony/base/_deployment.sh" && exit
  fi
  echo

  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Permissions - (Optional)


  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Database    - (Optional)


  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Cron jobs   - (Optional)


  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Messenger   - (Optional)


  # >>>> PHP - Symfony Framework - Deployment - Front-End - AssetMapper - (Optional)
  if [ -f "${PROJECT_PATH}/scripts/console/app/symfony/base/common/assets/_assetmapper.sh" ]; then
    source "${PROJECT_PATH}/scripts/console/app/symfony/base/common/assets/_assetmapper.sh"
  else
    echo "Please check a file : ./scripts/console/app/symfony/base/common/assets/_assetmapper.sh" && exit
  fi
  echo
}

# ----------------------------------------------------------------------------------------------------------------------
# Docker - Containers
# ----------------------------------------------------------------------------------------------------------------------

setDocker() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Docker - Containers"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  echo ">>>> Docker - Dockerfile"
  echo

  if [ -f "${PROJECT_PATH}/scripts/containers/prod/Dockerfile" ]; then
    cp -fv "${PROJECT_PATH}/scripts/containers/prod/Dockerfile" "${PROJECT_PATH}"
    echo
  fi

  echo ">>>> Docker - System"
  echo

  docker system prune -a -f --filter "label=purpose=webapp"
  echo

  echo ">>>> Docker - Build"
  echo

  IMAGE_NAME=${DOCKERFILE_IMAGE_NAME:-"dev-php"}
  TAG_NAME=$(date +%Y.%m.%d)

  docker build --network=host -t "${IMAGE_NAME}:${TAG_NAME}" ./ --no-cache
  echo

  echo ">>>> Docker - Run"
  echo

  CONTAINER_ID=$(docker run -d \
    --cpus="2.0" \
    --memory="4g" \
    --net dev_back-end \
    -p "127.0.0.1:${DOCKERFILE_LOCALHOST_PORT}:8080" \
    --name "${IMAGE_NAME}-prod" \
    "${IMAGE_NAME}:${TAG_NAME}")

  echo ">>>> Docker - Started Container ID: ${CONTAINER_ID}"
  echo

  echo ">>>> Docker - Process"
  echo
  docker ps --filter "id=${CONTAINER_ID}"
  echo

  echo ">>>> Docker - Container"
  echo

  docker container ls
  echo

  echo ">>>> Docker - Image"
  echo

  docker image ls
  echo

  docker image inspect "${IMAGE_NAME}:${TAG_NAME}"
  echo

  docker inspect "${CONTAINER_ID}" --format='{{.HostConfig.ExtraHosts}}'
  echo


  echo ">>>> Docker - Port"
  echo

  docker port "${CONTAINER_ID}"
  echo

  echo ">>>> Docker - Exec"
  echo

  docker exec -it "${CONTAINER_ID}" ps aux
  echo

  docker exec -it "${CONTAINER_ID}" cat /etc/hosts | grep host.docker.internal
  echo

  docker exec -it "${CONTAINER_ID}" getent hosts host.docker.internal
  echo

  docker exec -it "${CONTAINER_ID}" netstat -tulpn | grep 8080
  echo

  echo ">>>> Docker - Exec - App"
  echo

  docker exec -it "${CONTAINER_ID}" php /var/www/app/bin/console debug:dotenv
  echo

  echo ">>>> Docker - Exec - PHP-FPM"
  echo

  docker exec -it "${CONTAINER_ID}" php-fpm -t
  echo

  echo ">>>> Docker - Exec - Nginx"
  echo

  docker exec -it "${CONTAINER_ID}" nginx -t
  echo

  echo ">>>> Docker - Logs"
  echo

  docker logs "${CONTAINER_ID}"
  echo
}

# ----------------------------------------------------------------------------------------------------------------------
# Providers ( Cloud Service Provider )
# ----------------------------------------------------------------------------------------------------------------------

setProvider() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Providers ( Cloud Service Provider )"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# ----------------------------------------------------------------------------------------------------------------------
# Utility
# ----------------------------------------------------------------------------------------------------------------------

setUtility() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Utility"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Linux
  # --------------------------------------------------------------------------------------------------------------------
  if [ "${PLATFORM_TYPE}" == "Linux" ]; then
    echo ">>>> Process"
    echo

    ps -ef | grep -i docker
    echo

    echo ">>>> Network"
    echo

    netstat -nlp | grep 8080
    echo

    echo ">>>> Port"
    echo

    curl -v http://localhost:8080
    echo

  # --------------------------------------------------------------------------------------------------------------------
  # Platform - MacOS
  # --------------------------------------------------------------------------------------------------------------------
  elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
    echo

  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Windows
  # --------------------------------------------------------------------------------------------------------------------
  elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
    echo

  else
    echo "Please check Operating System"
    setExit
  fi
  echo
}

# ----------------------------------------------------------------------------------------------------------------------
# Tools - VM ( Instance )
# ----------------------------------------------------------------------------------------------------------------------

setTools() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Tools - VM ( Instance )"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  echo ">>>> ${PLATFORM_TYPE}"
  echo
}

# ======================================================================================================================
# START
# ======================================================================================================================

setStart

# ----------------------------------------------------------------------------------------------------------------------
# Abstract
# ----------------------------------------------------------------------------------------------------------------------

# >>>> Environment
setEnvironment

# >>>> Platform
setPlatform

# >>>> Project
setProject

# ----------------------------------------------------------------------------------------------------------------------
# Architecture
# ----------------------------------------------------------------------------------------------------------------------

# >>>> App
#setPhp

# >>>> Cache
#setRedis

# >>>> Database
#setPostgreSQL

# >>>> Message
#setRabbitMQ

# >>>> Server
setNginx

# ----------------------------------------------------------------------------------------------------------------------
# Build Scripts
# ----------------------------------------------------------------------------------------------------------------------
setBuild

# ----------------------------------------------------------------------------------------------------------------------
# Docker - Containers
# ----------------------------------------------------------------------------------------------------------------------
setDocker

# ----------------------------------------------------------------------------------------------------------------------
# Providers ( Cloud Service Provider )
# ----------------------------------------------------------------------------------------------------------------------
#setProvider

# ----------------------------------------------------------------------------------------------------------------------
# Utility
# ----------------------------------------------------------------------------------------------------------------------
setUtility

# ----------------------------------------------------------------------------------------------------------------------
# Tools - VM ( Instance )
# ----------------------------------------------------------------------------------------------------------------------
#setTools

# ======================================================================================================================
# END
# ======================================================================================================================

setEnd

