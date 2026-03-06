#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Base - Platform
# ======================================================================================================================

# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Linux - Ubuntu
  # --------------------------------------------------------------------------------------------------------------------
  # >>>> Release
  echo ">>>> Linux - Release"
  echo

  if [ -f /etc/lsb-release ]; then

    local UBUNTU_MAJOR_RELEASE
    UBUNTU_MAJOR_RELEASE=$(cat /etc/lsb-release | grep -i 'DISTRIB_RELEASE' | cut -d "=" -f2 | cut -c 1-2)

    local UBUNTU_UPDATE_MANAGER_PROMPT
    UBUNTU_UPDATE_MANAGER_PROMPT=$(cat /etc/update-manager/release-upgrades | grep -v '#' | grep -i 'Prompt' | cut -d "=" -f2)

    cat /etc/lsb-release
    echo
  fi

  # >>>> Packages
  echo ">>>> Linux - Packages"
  echo

  local addPackageList="curl git wget unzip net-tools"
  for pkgItem in ${addPackageList}; do
    local APT_PKG_INFO
    APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
    if [ "${APT_PKG_INFO}" != "${pkgItem}" ]; then
      sudo apt install -y "${pkgItem}"
      echo
    fi
  done


elif [ "${PLATFORM_TYPE}" == "Darwin" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - MacOS
  # --------------------------------------------------------------------------------------------------------------------
  # >>>> Release
  echo ">>>> MacOS - Release"
  sw_vers
  echo

  # >>>> Rosetta - M1/M2 Chips                                                  https://support.apple.com/en-us/HT211861
  if [ "${PLATFORM_PROCESSOR}" == "arm64" ]; then
    local ROSETTA_STATUS
    ROSETTA_STATUS=$(/usr/bin/pgrep oahd > /dev/null 2>&1)
    if [ ! "${ROSETTA_STATUS}" ]; then
      echo "Rosetta has been already installed"
      echo
    else
      echo ">>>> MacOS - Rosetta"
      softwareupdate --install-rosetta --agree-to-license
      echo

      if [[ $? -eq 0 ]]; then
        echo "This has been successfully installed."
      else
        echo "This installation failed!"
        setExit
      fi
    fi
  fi
  echo

  # >>>> Packages                                                                                        https://brew.sh
  echo ">>>> MacOS - Packages"
  if [ -f /opt/homebrew/bin/brew ]; then
    ls -ltr /opt/homebrew/bin/brew
    echo
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/$USER/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo
  fi


elif [ "${PLATFORM_TYPE}" == "Windows" ]; then
  # --------------------------------------------------------------------------------------------------------------------
  # Platform - Windows
  # --------------------------------------------------------------------------------------------------------------------
  # >>>> Release
  echo ">>>> Windows - Release"
  ver
  echo

  # >>>> Package
  echo ">>>> Windows - Packages"
  echo


else
  echo "Please check Operating System"
  setExit
fi
