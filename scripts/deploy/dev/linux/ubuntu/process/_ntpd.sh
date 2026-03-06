#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Booting - systemd - service
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then

    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      echo ">>>> Linux - TimeZone"
      echo

      local TIMDATECTL_STATUS
      TIMDATECTL_STATUS=$(systemctl is-active systemd-timesyncd)
      if [ "${TIMDATECTL_STATUS}" == "inactive" ]; then
        sudo timedatectl set-ntp no
        sudo timedatectl set-ntp yes
        sudo systemctl enable systemd-timesyncd
        sudo systemctl restart systemd-timesyncd
        sudo systemctl status systemd-timesyncd --no-pager
        echo
      fi

      if [ -f "/usr/share/zoneinfo/${PLATFORM_TIMEZONE}" ]; then
        sudo ln -snf "/usr/share/zoneinfo/${PLATFORM_TIMEZONE}" /etc/localtime
      fi

      #if [ -f "/etc/systemd/timesyncd.conf" ]; then
      #  sudo sed -i 's/^#NTP=/NTP=0.kr.pool.ntp.org 1.kr.pool.ntp.org/' /etc/systemd/timesyncd.conf
      #  sudo sed -i 's/^#FallbackNTP=/FallbackNTP=ntp.ubuntu.com/' /etc/systemd/timesyncd.conf
      #fi

      timedatectl
      echo

    fi
fi
