#!/usr/bin/env bash

# Load bats libraries if needed
# load 'libs/bats-support/load'
# load 'libs/bats-assert/load'

# Helper functions for tests
setup_environment_file() {
  local env_name=$1
  local author=$2
  local version=$3
  
  echo "$env_name $author $version" > "${BESMAN_DIR}/var/list.txt"
}

setup_current_environment() {
  local env_name=$1
  local version=$2
  
  echo "$env_name" > "${BESMAN_DIR}/var/current"
  mkdir -p "${BESMAN_DIR}/envs/besman-$env_name"
  echo "$version" > "${BESMAN_DIR}/envs/besman-$env_name/current"
}
