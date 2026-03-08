#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Packages
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then
    # ------------------------------------------------------------------------------------------------------------------
    # Platform - Linux - Ubuntu
    # ------------------------------------------------------------------------------------------------------------------
    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      # >>>> Packages - Ubuntu Pro
      local delPackageList="ubuntu-advantage-tools ubuntu-advantage-pro unattended-upgrades"
      for pkgItem in ${delPackageList}; do
        local APT_PKG_INFO
        APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
        if [ "${APT_PKG_INFO}" == "${pkgItem}" ]; then
          sudo apt purge -y "${pkgItem}"
          echo
        fi
      done

      # >>>> Packages Files
      echo ">>>> Linux - Cache Files"
      echo

      if [ -d /tmp ]; then
        sudo rm -rf /tmp/*
      fi

      if [ -d "/home/${LOGNAME}/.cache" ]; then
        sudo rm -rf "/home/${LOGNAME}/.cache/*"
      fi

      sudo apt-get autoremove -y && sudo apt-get autoclean -y
      echo

    fi
fi
