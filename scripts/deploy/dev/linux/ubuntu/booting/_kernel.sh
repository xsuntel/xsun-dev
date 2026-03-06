#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Booting - kernel
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then

    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      # ----------------------------------------------------------------------------------------------------------------
      # kernel
      # ----------------------------------------------------------------------------------------------------------------

      echo ">>>> Linux - kernel : $(uname -r)"
      echo

      sudo systemctl daemon-reload
      echo

      CURRENT_KERNEL=$(uname -r)
      DEL_KERNEL_VERSION=$(dpkg --get-selections | grep 'linux-image-[0-9]' | awk '{print $1}' | grep -v "${CURRENT_KERNEL}" | grep -v "linux-image-generic" || true)

      if [ -n "${DEL_KERNEL_VERSION}" ]; then
        dpkg --list | grep linux-image || true
        echo

        echo "${DEL_KERNEL_VERSION}"
        echo

        sudo apt-get purge -y "${DEL_KERNEL_VERSION}"
        sudo apt-get autoremove -y
      fi

    fi
fi
