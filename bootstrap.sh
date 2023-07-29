#!/usr/bin/env bash

# Get initial variables and ensure root
source "$(dirname "${0}")/env.sh"

# Get shared functions
source "$(dirname "${0}")/lib.sh"

# Ensure debootstrap is installed
if [[ "$(dpkg -l | awk '/debootstrap/{print $2}')" != "debootstrap" ]]; then
  echo "Installing debootstrap"
  sudo apt-get update -y &>/dev/null && sudo apt-get install -y debootstrap &>/dev/null
  code=$?
  if [[ "${code}" -ne 0 ]]; then
    echo "Failed to install debootstrap"
    clean-exit 254
  fi
fi

# Check if directory is clean
if [[ -d "${BOOTSTRAP_DIR}" ]] && [[ -n "$(ls "${BOOTSTRAP_DIR}")" ]]; then
  echo -n "Bootstrap directory already exists. Would you like to clean it? (y/N): "
  read -r in
  if [[ "${in:0:1}" == "y" ]]; then
    rm -rf "${BOOTSTRAP_DIR}"
  else
    echo Exiting.
    clean-exit
  fi
fi

# Bootstrap directory
debootstrap "${BOOTSTRAP_RELEASE}" "bootstrap/" "${BOOTSTRAP_MIRROR_URI}"

# Start base configuration
"$(dirname "${0}")/base-configuration.sh"

# End the script
clean-exit