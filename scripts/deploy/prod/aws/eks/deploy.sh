#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Prod - AWS (Amzon Web Service) - Elastic Beanstalk
# ======================================================================================================================

find_project_root() {
    local PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    while [[ "${PROJECT_DIR}" != "/" ]]; do
        if [[ -d "${PROJECT_DIR}/.git" ]] || [[ -f "${PROJECT_DIR}/.env.base" ]]; then
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
# Base
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
}

# >>>> Server

setNginx() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Base - Server - Packages"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# ----------------------------------------------------------------------------------------------------------------------
# Build
# ----------------------------------------------------------------------------------------------------------------------

setBuild() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Build"
  echo "---------------------------------------------------------------------------------------------------------------"
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
  #if [ -f "${PROJECT_PATH}"/scripts/console/app/symfony/base/common/_database.sh ]; then
  #  source "${PROJECT_PATH}"/scripts/console/app/symfony/base/common/_database.sh
  #else
  #  echo "Please check a file : ./scripts/console/app/symfony/base/common/_database.sh" && exit
  #fi
  #echo

  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Cron jobs   - (Optional)
  #if [ -f "${PROJECT_PATH}"/scripts/console/app/symfony/base/common/_cron.sh ]; then
  #  source "${PROJECT_PATH}"/scripts/console/app/symfony/base/common/_cron.sh
  #else
  #  echo "Please check a file : ./scripts/console/app/symfony/base/common/_cron.sh" && exit
  #fi
  #echo

  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Messenger   - (Optional)


  # >>>> PHP - Symfony Framework - Deployment - Front-End - AssetMapper - (Optional) OR Webpack Encore
  #if [ -f "${PROJECT_PATH}/scripts/console/app/symfony/base/common/assets/_assetmapper.sh" ]; then
  #  source "${PROJECT_PATH}/scripts/console/app/symfony/base/common/assets/_assetmapper.sh"
  #else
  #  echo "Please check a file : ./scripts/console/app/symfony/base/common/assets/_assetmapper.sh" && exit
  #fi
  #echo

  #if [ -f "${PROJECT_PATH}"/scripts/console/app/symfony/base/common/assets/_webpack.sh ]; then
  #  source "${PROJECT_PATH}"/scripts/console/app/symfony/base/common/assets/_webpack.sh
  #else
  #  echo "Please check a file : ./scripts/console/app/symfony/base/common/assets/_webpack.sh" && exit
  #fi
  #echo
}

# ----------------------------------------------------------------------------------------------------------------------
# CDN ( Content Delivery Networks )
# ----------------------------------------------------------------------------------------------------------------------

setCDN() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - CDN ( Content Delivery Networks ) - Upload files"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  # >>>> AWS - Base - Import a CLI file
  if [ -f "${PROJECT_PATH}"/scripts/deploy/prod/aws/base/_cli.sh ]; then
    source "${PROJECT_PATH}"/scripts/deploy/prod/aws/base/_cli.sh
  else
    echo "Please check a file : ./scripts/deploy/prod/aws/base/_cli.sh" && exit
  fi
  echo

  # >>>> AWS - Base - Import a CDN file
  if [ -f "${PROJECT_PATH}"/scripts/deploy/prod/aws/base/_s3.sh ]; then
    source "${PROJECT_PATH}"/scripts/deploy/prod/aws/base/_s3.sh
  else
    echo "Please check a file : ./scripts/deploy/prod/aws/base/_s3.sh" && exit
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

  # >>>> Docker - Dockerfile
  if [ -f "${PROJECT_PATH}/scripts/containers/prod/Dockerfile" ]; then
    cp -fv "${PROJECT_PATH}/scripts/containers/prod/Dockerfile" "${PROJECT_PATH}"
    echo
  fi

  echo ">>>> Docker - Build"
  echo

  DOCKERFILE_TAG_NAME=$(date +%Y.%m.%d)

  docker build --network=host -t ${DOCKERFILE_IMAGE_NAME}:${DOCKERFILE_TAG_NAME} ./ --no-cache
  echo
}

# ----------------------------------------------------------------------------------------------------------------------
# Providers ( Cloud Service Provider )
# ----------------------------------------------------------------------------------------------------------------------

setProvider() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Providers ( Cloud Service Provider )"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo


# ----------------------------------------------------------------------------------------------------------------------
# AWS - Build
# ----------------------------------------------------------------------------------------------------------------------

echo ">>>> AWS - Build"
echo

#gcloud builds submit --tag {europe-west4-docker.pkg.dev}/{PROJECT_ID}/{webapp_repo}/{image_name}:{tag}
echo

# ----------------------------------------------------------------------------------------------------------------------
# AWS - Registry
# ----------------------------------------------------------------------------------------------------------------------

echo ">>>> AWS - Registry"
echo

#docker build . --tag {europe-west4-docker.pkg.dev}/{PROJECT_ID}/{webapp_repo}/{image_name}:{tag}
#docker push {europe-west4-docker.pkg.dev}/{PROJECT_ID}/{webapp_repo}/{image_name}:{tag}
echo

}

# ----------------------------------------------------------------------------------------------------------------------
# Utility
# ----------------------------------------------------------------------------------------------------------------------

setUtility() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Utility"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# ----------------------------------------------------------------------------------------------------------------------
# Tools
# ----------------------------------------------------------------------------------------------------------------------

setTools() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Tools"
  echo "---------------------------------------------------------------------------------------------------------------"
}

# ----------------------------------------------------------------------------------------------------------------------
# VM ( Instance )
# ----------------------------------------------------------------------------------------------------------------------

setVM() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - VM ( Instance )"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  # >>>> Docker - Process
  echo ">>>> Docker - Process"
  echo
  docker ps -a
  echo

  # >>>> Docker - Images
  echo ">>>> Docker - images"
  echo

  docker images
  #docker images --filter "label=purpose=webapp"
  echo
}

# ======================================================================================================================
# START
# ======================================================================================================================

# >>>> Start
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
# Base
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
#setNginx

# ----------------------------------------------------------------------------------------------------------------------
# Build
# ----------------------------------------------------------------------------------------------------------------------
setBuild

# ----------------------------------------------------------------------------------------------------------------------
# CDN ( Content Delivery Networks )
# ----------------------------------------------------------------------------------------------------------------------
setCDN

# ----------------------------------------------------------------------------------------------------------------------
# Docker - Containers
# ----------------------------------------------------------------------------------------------------------------------
#setDocker

# ----------------------------------------------------------------------------------------------------------------------
# Providers ( Cloud Service Provider )
# ----------------------------------------------------------------------------------------------------------------------
setProvider

# ----------------------------------------------------------------------------------------------------------------------
# Utility
# ----------------------------------------------------------------------------------------------------------------------
#setUtility

# ----------------------------------------------------------------------------------------------------------------------
# Tools
# ----------------------------------------------------------------------------------------------------------------------
#setTools

# ----------------------------------------------------------------------------------------------------------------------
# VM ( Instance )
# ----------------------------------------------------------------------------------------------------------------------
setVM

# ======================================================================================================================
# END
# ======================================================================================================================

# >>>> End
setEnd
