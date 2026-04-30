#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Deploy
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

if [ "${PLATFORM_TYPE}" != "Linux" ]; then
  echo
  echo "Please check Operating System"
  setExit
fi

setEnvironment() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ENV ] ${PLATFORM_TYPE} - ${PLATFORM_PROCESSOR}"
  echo "---------------------------------------------------------------------------------------------------------------"
  # >>>> Select one of some environments
  PS3="Menu: "
  select num in "dev" "exit"; do
    case "$REPLY" in
    1)
      # >>>> Dev Environment
      ENVIRONMENT_NAME="dev"
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

  if [ "${PLATFORM_TYPE}" == "Linux" ]; then

    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      echo ">>>> Linux - Security - users"
      echo

      # >>>> User - Permission
      if [ ! -f "/etc/sudoers.d/${USER}" ]; then
        sudo touch "/etc/sudoers.d/${USER}"
        sudo echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee -a "/etc/sudoers.d/${USER}" > /dev/null
      fi

      echo ">>>> Linux - kernel : $(uname -r)"
      echo

      sudo systemctl daemon-reload
      echo

      CURRENT_VER=$(uname -r | cut -d'-' -f1,2)
      DEL_PACKAGES=$(dpkg --get-selections | grep -E 'linux-(image|headers|modules|objects)-[0-9]' | \
                     grep -v "${CURRENT_VER}" | \
                     grep '\binstall$' | \
                     awk '{print $1}' || true)

      if [ -n "${DEL_PACKAGES}" ]; then
        echo ">>>> Found old kernel packages to remove:"
        echo "${DEL_PACKAGES}"
        echo

        sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y "${DEL_PACKAGES}"

        sudo apt-get autoremove -y
        sudo update-grub

        echo ">>>> Old kernels have been cleaned up."
      else
        echo ">>>> No old kernels found to remove."
      fi

    fi
  fi

  # >>>> Linux - Base

  if [ -f "${PROJECT_PATH}/scripts/console/_platform.sh" ]; then
    source "${PROJECT_PATH}/scripts/console/_platform.sh"
  else
    echo "Please check a file : ./scripts/console/_platform.sh" && exit
  fi

  # >>>> Linux - Network

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/network/_hosts.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/network/_hosts.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/network/_hosts.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/network/_ufw.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/network/_ufw.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/network/_ufw.sh" && exit
  fi
  echo

  # >>>> Linux - Packages

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_base.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_base.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/packages/_base.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_network.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_network.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/packages/_network.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_remote-desktop.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_remote-desktop.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/packages/_remote-desktop.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_ubuntu_pro.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/packages/_ubuntu_pro.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/packages/_ubuntu_pro.sh" && exit
  fi
  echo

  # >>>> Linux - Security

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/security/_directories.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/security/_directories.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/security/_directories.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/security/_files.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/security/_files.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/security/_files.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/security/_users.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/security/_users.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/security/_users.sh" && exit
  fi
  echo

  # >>>> Linux - Utility

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_booting.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_booting.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/utility/_booting.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_crontab.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_crontab.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/utility/_crontab.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_ntpd.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_ntpd.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/utility/_ntpd.sh" && exit
  fi
  echo

  if [ -f "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_power.sh" ]; then
    source "${PROJECT_PATH}/scripts/deploy/dev/linux/ubuntu/utility/_power.sh"
  else
    echo "Please check a file : ./scripts/deploy/dev/linux/ubuntu/utility/_power.sh" && exit
  fi
  echo

  sudo apt-get autoremove -y && sudo apt-get autoclean -y
  echo
}

# >>>> Project

setProject() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Project"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "- PROJECT NAME : ${PROJECT_NAME}"
  echo

  # >>>> Git
  if [ -f "${PROJECT_PATH}/scripts/console/utility/git/base/_config.sh" ]; then
    source "${PROJECT_PATH}/scripts/console/utility/git/base/_config.sh"
  else
    echo "Please check a file : ./scripts/console/utility/git/base/_config.sh" && exit
  fi

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
  echo

  # >>>> PHP
  if [ -f "${PROJECT_PATH}"/scripts/console/app/php/base/_install.sh ]; then
    source "${PROJECT_PATH}"/scripts/console/app/php/base/_install.sh
  else
    echo "Please check a file : ./scripts/console/app/php/base/_install.sh" && exit
  fi
  echo

  # >>>> PHP - Symfony Framework - Command Line Interface
  if [ -f "${PROJECT_PATH}"/scripts/console/app/symfony/base/_command.sh ]; then
    source "${PROJECT_PATH}"/scripts/console/app/symfony/base/_command.sh
  else
    echo "Please check a file : ./scripts/console/app/symfony/base/_command.sh" && exit
  fi
  echo

  # >>>> PHP - Symfony Framework - Components
  if [ -f "${PROJECT_PATH}"/scripts/console/app/symfony/base/_components.sh ]; then
    source "${PROJECT_PATH}"/scripts/console/app/symfony/base/_components.sh
  else
    echo "Please check a file : ./scripts/console/app/symfony/base/_components.sh" && exit
  fi
  echo
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
# Build Scripts
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


  # >>>> PHP - Symfony Framework - Deployment - Back-End  - Cron jobs   - (Optional)


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
# Docker - Containers
# ----------------------------------------------------------------------------------------------------------------------

setDocker() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Docker - Containers"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo

  # >>>> Docker
  if [ -f "${PROJECT_PATH}"/scripts/console/utility/docker/base/_install.sh ]; then
    source "${PROJECT_PATH}"/scripts/console/utility/docker/base/_install.sh
  else
    echo "Please check a file : ./scripts/console/utility/docker/base/_install.sh" && exit
  fi
  echo

  # >>>> Docker - Containers
  if [ -f "${PROJECT_PATH}"/scripts/console/utility/docker/base/_deploy.sh ]; then
    source "${PROJECT_PATH}"/scripts/console/utility/docker/base/_deploy.sh
  else
    echo "Please check a file : ./scripts/console/utility/docker/base/_deploy.sh" && exit
  fi
  echo

  # >>>> Docker - System
  echo ">>>> Docker - System"
  echo

  docker system prune -a -f --filter "label=purpose=webapp"
  echo

  docker system df
  echo


  # >>>> Docker - Images
  echo ">>>> Docker - images"
  echo

  docker image ls
  echo

  # >>>> Docker - Container
  echo ">>>> Docker - Container"
  echo

  docker container ls
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

  # >>>> PHP - Symfony Framework - Server
  if [ -f "${PROJECT_PATH}"/scripts/console/app/symfony/base/_local_server.sh ]; then
    source "${PROJECT_PATH}"/scripts/console/app/symfony/base/_local_server.sh
  else
    echo "Please check a file : ./scripts/console/app/symfony/base/_local_server.sh" && exit
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

  if [ "${PLATFORM_TYPE}" == "Linux" ]; then
    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      echo ">>>> ${PLATFORM_TYPE} - Host"
      echo

      hostnamectl
      echo

      echo ">>>> ${PLATFORM_TYPE} - Process"
      echo

      # >>>> Firewall
      local UFW_STATUS
      UFW_STATUS=$(systemctl is-active ufw)
      if [ "${UFW_STATUS}" == "inactive" ]; then
        sudo systemctl start ufw
        sudo systemctl status ufw --no-pager
        echo
      fi
      echo "Firewall   : ${UFW_STATUS}"
      echo

      # >>>> Cron
      local CRON_STATUS
      CRON_STATUS=$(systemctl is-active cron)
      if [ "${CRON_STATUS}" == "inactive" ]; then
        sudo systemctl start cron
        sudo systemctl status cron --no-pager
        echo
      fi
      echo "Cron       : ${CRON_STATUS}"
      echo

      # >>>> Rsyslog
      local RSYSLOG_STATUS
      RSYSLOG_STATUS=$(systemctl is-active rsyslog)
      if [ "${RSYSLOG_STATUS}" == "inactive" ]; then
        sudo systemctl start rsyslog
        sudo systemctl status rsyslog --no-pager
        echo
      fi
      echo "Rsyslog    : ${RSYSLOG_STATUS}"
      echo

      echo ">>>> ${PLATFORM_TYPE} - Network"
      echo

      netstat -i
      echo

      # >>>> Hardware
      nmcli general status
      echo

      ip route show
      echo

      netstat -r
      echo

      ip addr show | grep inet
      echo

      resolvectl status
      echo

      sudo ss -tulpn
      echo

      # >>>> User
      echo ">>>> ${PLATFORM_TYPE} - Users"
      echo

      if [ -f "/etc/sudoers.d/${USER}" ]; then
        sudo rm -fv "/etc/sudoers.d/${USER}"
      fi

    fi

  fi
  echo

  echo ">>>> Tools - IDE : AI"

  # >>>> Tools - AI - Claude
  if [ -f "${PROJECT_PATH}/tools/ai/anthropic/claude/_scheduler.sh" ]; then
    source "${PROJECT_PATH}/tools/ai/anthropic/claude/_scheduler.sh"
  else
    echo "Please check a file : ./tools/ai/anthropic/claude/_scheduler.sh" && exit
  fi
  echo

  # >>>> Tools - AI - Google
  if [ -f "${PROJECT_PATH}/tools/ai/google/gemini/_scheduler.sh" ]; then
    source "${PROJECT_PATH}/tools/ai/google/gemini/_scheduler.sh"
  else
    echo "Please check a file : ./tools/ai/google/gemini/_scheduler.sh" && exit
  fi
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
setPhp

# >>>> Cache
#setRedis

# >>>> Database
#setPostgreSQL

# >>>> Message
#setRabbitMQ

# >>>> Server
#setNginx

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
setTools

# ======================================================================================================================
# END
# ======================================================================================================================

setEnd
