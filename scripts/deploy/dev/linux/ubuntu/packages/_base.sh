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

      echo ">>>> Linux - Process - services"
      echo

      if [ -f /etc/xdg/autostart/org.gnome.SettingsDaemon.Smartcard.desktop ]; then
        systemctl --user mask org.gnome.SettingsDaemon.Smartcard.service
      fi

      if [ -f /etc/xdg/autostart/org.gnome.SettingsDaemon.Wacom.desktop ]; then
        systemctl --user mask org.gnome.SettingsDaemon.Wacom.service
      fi
      echo

      # >>>> Packages
      echo ">>>> Linux - Packages - Shell scripts"
      echo

      local addPackageList="shfmt shellcheck"
      for pkgItem in ${addPackageList}; do
        local APT_PKG_INFO
        APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
        if [ "${APT_PKG_INFO}" != "${pkgItem}" ]; then
          sudo apt install -y "${pkgItem}"
          echo
        fi
      done
      echo

      # >>>> Packages - Remove default applications
      local delPackageList="gnome-mahjongg gnome-sudoku aisleriot speech-dispatcher"
      for pkgItem in ${delPackageList}; do
        local APT_PKG_INFO
        APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
        if [ "${APT_PKG_INFO}" == "${pkgItem}" ]; then
          sudo apt remove -y "${pkgItem}"
          echo
        fi
      done

      # >>>> Packages - Disable gnome-shell extensions            https://manpages.ubuntu.com/manpages/focal/en/man1/gsettings.1.html
      local delPackageList="evolution evolution-common evolution-plugins evolution-data-server"
      for pkgItem in ${delPackageList}; do
        local APT_PKG_INFO
        APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
        if [ "${APT_PKG_INFO}" == "${pkgItem}" ]; then
          sudo apt purge -y "${pkgItem}"
          echo
        fi
      done

      if [ -d ~/.local/share/gnome-shell/extensions ]; then
        for ext in $(/usr/bin/ls ~/.local/share/gnome-shell/extensions); do
          gnome-shell-extension-tool -d $ext;
        done
      fi
      gsettings set org.gnome.shell disable-user-extensions true
      echo

      service --status-all | grep '\[ + \]'
      echo

    fi
fi
