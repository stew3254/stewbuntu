#!/usr/bin/env bash

function clean-exit() {
  if [[ -z "${1}" ]]; then
    code=0
    else
    code=${1}
  fi
  # Remove temp env
  tmp_env="$(dirname "${0}")/.tmp_env"
  [[ -f "${tmp_env}" ]] && rm "${tmp_env}"
  exit "${code}"
}