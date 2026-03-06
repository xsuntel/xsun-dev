#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Tools - AI - Antigravity - Scheduler
# ======================================================================================================================

ENVIRONMENT_NAME="dev"

PROJECT_PATH=$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "(dirname "$0")")")")")")
cd "${PROJECT_PATH}" || exit

AGENT_MANAGER_NAME="agent_scheduler"
AGENT_MISSION_NAME="Daily_Check"
AGENT_LOG_FILE_NAME="/home/$USER/${AGENT_MANAGER_NAME}.log"

# >>>> Abstract

if [ -f "${PROJECT_PATH}/scripts/base/_abstract.sh" ]; then
  source "${PROJECT_PATH}/scripts/base/_abstract.sh"
else
  echo "Please check a file : ./scripts/base/_abstract.sh" && exit
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
  echo "- ENVIRONMENT_NAME : ${ENVIRONMENT_NAME}"
  echo
}

# >>>> Platform

setPlatform() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - Platform"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "- PLATFORM OS : ${PLATFORM_TYPE}"
  echo
}

# >>>> Project

setProject() {
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "[ ${ENVIRONMENT_NAME} ] ${PLATFORM_TYPE} - AI - Agent"
  echo "---------------------------------------------------------------------------------------------------------------"
  echo "- PROJECT NAME : ${PROJECT_NAME}"
  echo

  # >>>> Directory
  if [ -d app ]; then
    (
      cd app || return
      # >>>> PHP - Symfony Command
      if [ -f bin/console ]; then

        # >>>> Environment
        if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

          # >>>> AI - Antigravity
          if [ -f ${AGENT_LOG_FILE_NAME} ]; then
            cat /dev/null > ${AGENT_LOG_FILE_NAME}
          else
            touch ${AGENT_LOG_FILE_NAME}
          fi

          # >>>> AI - Antigravity
          echo "[$(date)] >>>>  START" >> ${AGENT_LOG_FILE_NAME}
          /usr/bin/antigravity run ${AGENT_MANAGER_NAME} --mission "${AGENT_MISSION_NAME}" >> ${AGENT_LOG_FILE_NAME} 2>&1
          echo "[$(date)] <<<<  END" >> ${AGENT_LOG_FILE_NAME}

          echo "--------------------------------------" >> ${AGENT_LOG_FILE_NAME}

        fi
      fi
    )
  else
    echo "[ ERROR ] There is not a folder : app"
    setExit
  fi
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

# ======================================================================================================================
# END
# ======================================================================================================================

# >>>> End
setEnd
