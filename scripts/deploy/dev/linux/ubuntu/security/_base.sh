#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Process - services
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then

    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      echo ">>>> Linux - Process - services"
      echo

      if [ -f /etc/xdg/autostart/org.gnome.SettingsDaemon.Smartcard.desktop ]; then
        systemctl --user mask org.gnome.SettingsDaemon.Smartcard.service
      fi

      if [ -f /etc/xdg/autostart/org.gnome.SettingsDaemon.Wacom.desktop ]; then
        systemctl --user mask org.gnome.SettingsDaemon.Wacom.service
      fi
      echo

    fi
fi
