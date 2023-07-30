#!/usr/bin/env bash

# Ensure script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "Please run as root"
  exit 255
fi

# Get environment variables
if [[ -f ".tmp_env" ]]; then
  source ".tmp_env"
else
  # Please specify these variables externally. Otherwise the defaults will be used
  [[ -z "${BOOTSTRAP_RELEASE}" ]] && BOOTSTRAP_RELEASE=jammy
  [[ -z "${BOOTSTRAP_DIR}" ]] && BOOTSTRAP_DIR="bootstrap/"
  [[ "${BOOTSTRAP_DIR: -1}" == "/" ]] && BOOTSTRAP_DIR="${BOOTSTRAP_DIR%?}"
  [[ -z "${BOOTSTRAP_MIRROR_URI}" ]] && BOOTSTRAP_MIRROR_URI="http://archive.ubuntu.com/ubuntu/"
  [[ "${BOOTSTRAP_MIRROR_URI: -1}" == "/" ]] && BOOTSTRAP_MIRROR_URI="${BOOTSTRAP_MIRROR_URI%?}"
  [[ -z "${GIT_PRIV_KEY}" ]] && GIT_PRIV_KEY="$HOME/.ssh/git"
  [[ -z "${REMOTE_USER}" ]] && [[ ! -f "${GIT_PRIV_KEY}" ]] && echo "Must set username, or add valid git key" && exit 1
  [[ -z "${REMOTE_PASS}" ]] && [[ ! -f "${GIT_PRIV_KEY}" ]] && echo "Must set password, or add valid git key" && exit 1
fi

env | grep "^(BOOTSTRAP|GIT|REMOTE)_" > ".tmp_env"
