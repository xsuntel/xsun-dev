#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Tools - AI - Google - Gemini
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Linux
  # --------------------------------------------------------------------------------------------------------------------
  # >>>> Environment
  if [ "${ENVIRONMENT_NAME}" == "dev" ]; then
    # >>>> Install
    echo ">>>> Tools - AI - Google - Gemini"
    echo

    # >>>> Directory
    if [ -d "${HOME}/.gemini" ]; then

      # >>>> GEMINI.md
      if [ -f "${PROJECT_PATH}/scripts/tools/ai/google/gemini/GEMINI.md" ]; then
        cp -fv "${PROJECT_PATH}/scripts/tools/ai/google/gemini/GEMINI.md" "${HOME}/.gemini/GEMINI.md"
        echo
      fi

      # >>>> .gemini/agents
      if [ ! -d "${HOME}/.gemini/agents" ]; then
        mkdir -p "${HOME}/.gemini/agents"
      fi
      cp -fv "${PROJECT_PATH}/scripts/tools/ai/google/gemini/agents/*" "${HOME}/.gemini/agents/"
      echo


      # >>>> .gemini/skills
      if [ ! -d "${HOME}/.gemini/skills" ]; then
        mkdir -p "${HOME}/.gemini/skills"
      fi
      cp -fv "${PROJECT_PATH}/scripts/tools/ai/google/gemini/skills/*" "${HOME}/.gemini/skills/"
      echo

    fi
  fi
  echo


elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - MacOS
  # --------------------------------------------------------------------------------------------------------------------
  # >>>> Environment
  if [ "${ENVIRONMENT_NAME}" == "dev" ]; then
    # >>>> Install
    echo ">>>> Tools - AI - Google - Gemini"
    echo
  fi
  echo


elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Windows
  # --------------------------------------------------------------------------------------------------------------------
  # >>>> Environment
  if [ "${ENVIRONMENT_NAME}" == "dev" ]; then
    # >>>> Install
    echo ">>>> Tools - AI - Google - Gemini"
    echo
  fi
  echo


else
  echo "Please check Operating System"
  setExit
fi
