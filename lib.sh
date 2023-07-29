#!/usr/bin/env bash

function clean-exit() {
  if [[ -z "${1}" ]]; then
    code=0
    else
    code=${1}
  fi
  # Remove temp env
  tmp_env=".tmp_env"
  [[ -f "${tmp_env}" ]] && rm "${tmp_env}"
  exit "${code}"
}

function pkgs () {
  if [[ -z "${1}" ]]; then
    echo "Must supply an argument to pkgs function"
    clean-exit 253
  fi

  # If not base, get other files too
  if [[ "${1}" != "base" ]]; then
    cat "packages/base" "packages/${1}" | tr '\n' ',' | sed 's/,$//'
  else
    # Get base files to install only
    tr '\n' ',' < "packages/${1}"
  fi

}