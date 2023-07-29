#!/usr/bin/env bash

# Get initial variables and ensure root
source "env.sh"

# Get shared functions
source "lib.sh"

# Write out new sources.list
if grep -vq '^http' <<<"${BOOTSTRAP_MIRROR_URI}"; then
  BOOTSTRAP_MIRROR_URI="http://archive.ubuntu.com/ubuntu/"
fi
envsubst < configurations/sources.list > "${BOOTSTRAP_DIR}/etc/apt/sources.list"