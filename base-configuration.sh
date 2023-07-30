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
cp configurations/netplan-network-manager.yml "${BOOTSTRAP_DIR}/etc/netplan/01-network-manager-all.yml"

# Configure SSH
# TODO look into using git to set up appropriate branches for configuring /etc
sed -ri -f "configurations/sed-base-ssh" "${BOOTSTRAP_DIR}/etc/ssh/sshd_config"

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
  # TODO add ability to pull down git config from home server
  echo "Cannot pull keys from server (yet). Functionality not implemented"
fi
#curl -sL https://github.com/stew3254.keys -o "${BOOTSTRAP_DIR}/home/stew3254/.ssh/authorized_keys"

# TODO come up with a solution to make this work since you need PTY
# Initialize dotfiles for user
#chroot "${BOOTSTRAP_DIR}" sudo -u stew3254 yadm init
#chroot "${BOOTSTRAP_DIR}" sudo -u stew3254 yadm remote add origin git@git.rtstewart.dev:/srv/git/dotfiles.git
#if [[ -f "${BOOTSTRAP_DIR}/home/stew3254/.ssh/git" ]]; then
#  chroot "${BOOTSTRAP_DIR}" yadm pull origin main
#fi