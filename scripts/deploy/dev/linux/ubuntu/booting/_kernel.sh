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

      sudo systemctl daemon-reload

    fi
fi
