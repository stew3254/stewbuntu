#!/usr/bin/env bash

# Get initial variables and ensure root
source "env.sh"

# Get shared functions
source "lib.sh"

# Write out new sources.list
if grep -vq '^http' <<<"${BOOTSTRAP_MIRROR_URI}"; then
  BOOTSTRAP_MIRROR_URI="http://archive.ubuntu.com/ubuntu"
fi
envsubst < configurations/sources.list > "${BOOTSTRAP_DIR}/etc/apt/sources.list"

# Update the package files and install base updates
chroot "${BOOTSTRAP_DIR}" apt-get update -y
chroot "${BOOTSTRAP_DIR}" apt-get upgrade -y
chroot "${BOOTSTRAP_DIR}" apt-get install -y $(pkgs base)

# Remove vim, emacs and nano
sudo apt-get -y purge --auto-remove vim emacs nano

# Tell netplan to user network manager
#cp configurations/netplan-network-manager.yml "${BOOTSTRAP_DIR}/etc/netplan/01-network-manager-all.yml"

# Add default user to the system
chroot "${BOOTSTRAP_DIR}" useradd -d /home/stew3254 -G sudo -s /bin/bash stew3254
mkdir -p "${BOOTSTRAP_DIR}/home/stew3254"
chroot "${BOOTSTRAP_DIR}" chown stew3254:stew3254 /home/stew3254
chroot "${BOOTSTRAP_DIR}" chmod 750 /home/stew3254

# Set up ssh and git config
mkdir -p "${BOOTSTRAP_DIR}/home/stew3254/.ssh"
cp configurations/ssh-git-config "${BOOTSTRAP_DIR}/home/stew3254/.ssh/config"
if [[ -f "${GIT_PRIV_KEY}" ]]; then
  cp "${GIT_PRIV_KEY}" "${BOOTSTRAP_DIR}/home/stew3254/.ssh/git"
  cp "${GIT_PRIV_KEY}.pub" "${BOOTSTRAP_DIR}/home/stew3254/.ssh/git.pub"
else
  # TODO add ability to pull down git config from website
  echo "Cannot pull keys from server (yet). Functionality not implemented"
fi
#curl -sL https://github.com/stew3254.keys -o "${BOOTSTRAP_DIR}/home/stew3254/.ssh/authorized_keys"

# Initialize dotfiles for user
chroot "${BOOTSTRAP_DIR}" su - stew3254 -c 'yadm init'
chroot "${BOOTSTRAP_DIR}" su - stew3254 -c 'yadm remote add origin git@git.rtstewart.dev:/srv/git/dotfiles.git'
if [[ -f "${BOOTSTRAP_DIR}/home/stew3254/.ssh/git" ]]; then
  chroot "${BOOTSTRAP_DIR}" su - stew3254 -c 'yadm pull origin main'
fi

# Set up git in /etc
chroot "${BOOTSTRAP_DIR}" git init
chroot "${BOOTSTRAP_DIR}" git remote add origin ssh://git.rtstewart.dev:/srv/git/etc.git
if [[ -n "${MACHINE_LABEL}" ]]; then
  chroot "${BOOTSTRAP_DIR}" git pull origin "${MACHINE_LABEL}"
else
  chroot "${BOOTSTRAP_DIR}" git pull origin main
fi
