#!/usr/bin/env bash

# Get initial variables and ensure root
source "env.sh"

# Get shared functions
source "lib.sh"

# Ensure debootstrap and fakechroot is installed
install=0
pkgs=(debootstrap fakechroot fakeroot)
for pkg in ${pkgs[@]}; do
  if ! (dpkg -l | grep -q "^ii  ${pkg} "); then
    install=1
    break
  fi
done

if [[ ${install} -eq 1 ]]; then
  echo "Installing: ${pkgs[@]}"
  sudo apt-get update -y && sudo apt-get install -y ${pkgs[@]}
  code=$?
  if [[ "${code}" -ne 0 ]]; then
    echo "Failed to install packages"
    clean-exit 254
  fi
fi

# Check if directory is clean
if [[ -d "${BOOTSTRAP_DIR}" ]] && [[ -n "$(ls "${BOOTSTRAP_DIR}")" ]]; then
  echo -n "Bootstrap directory already exists. Would you like to clean it? (y/N): "
  read -r in
  if [[ "${in:0:1}" == "y" ]]; then
    # Remove the bootstrap dir contents
    find "${BOOTSTRAP_DIR}" -maxdepth 1 | tail -n+2 | xargs sudo rm -rf
  else
    echo Exiting.
    clean-exit
  fi
fi

# Bootstrap directory
fakechroot fakeroot debootstrap \
  --keep-debootstrap-dir \
  "${BOOTSTRAP_RELEASE}" \
  "bootstrap/" \
  "${BOOTSTRAP_MIRROR_URI}"
  # Adding the jammy-updates suite breaks the base system unpacking
  # Unclear why when looking into debootstrap
  # Will do manual upgrade of packages later
  #--include="$(pkgs base)" \
  #--components=main,restricted,universe,multiverse \
  #--extra-suites=jammy-updates \

# Start base configuration
./base-configuration.sh

# End the script
clean-exit