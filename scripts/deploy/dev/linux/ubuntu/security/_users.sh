#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Security - users
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then

    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      echo ">>>> Linux - Security - users"
      echo

      # >>>> User - Group
      TARGET_GROUP="www-data"
      CURRENT_USER=$USER

      if id -nG "$CURRENT_USER" | grep -qw "$TARGET_GROUP"; then
        echo "Group : [$TARGET_GROUP] "
      else
        sudo usermod -aG "$TARGET_GROUP" "$CURRENT_USER"
        if [ $? -eq 0 ]; then
          echo "Run  : 'newgrp $TARGET_GROUP'"
        else
          echo "Error: Please check permission"
          exit 1
        fi
      fi
      echo


      # >>>> User - List
      local delUserList="list sync games news uucp uuidd irc speech-dispatcher ftp tcpdump snmp snmpd fwupd-refresh tss mail proxy"
      for userItem in ${delUserList}; do
        local USER_LIST
        USER_LIST=$(cat /etc/passwd | awk -F: '{print $1}' | grep -i "${userItem}")
        if [ "${USER_LIST}" == "${userItem}" ]; then
          sudo userdel "${userItem}"
        fi
      done

      # >>>> User - Permission
      if [ ! -f "/etc/sudoers.d/${USER}" ]; then
        sudo touch "/etc/sudoers.d/${USER}"
        sudo echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee -a "/etc/sudoers.d/${USER}" > /dev/null
      fi

    else

      # >>>> User
      echo ">>>> Linux - Users"
      echo

      if [ -f "/etc/sudoers.d/${USER}" ]; then
        sudo rm -f "/etc/sudoers.d/${USER}"
      fi

    fi
fi
