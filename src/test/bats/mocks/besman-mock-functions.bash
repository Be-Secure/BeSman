#!/usr/bin/env bash

# Mock functions for dependencies
__besman_echo_white() {
  echo "$@"
}

__besman_echo_yellow() {
  echo "$@"
}

__besman_echo_no_colour() {
  echo "$@"
}

__besman_echo_error() {
  echo "ERROR: $*" >&2
}

__besman_echo_red() {
  echo "ERROR: $*" >&2
}

__besman_construct_repo_url() {
  echo "https://github.com/$1"
}

__besman_check_url_valid() {
  return 0
}

__besman_check_for_access_token() {
  return 0
}

# Mock Python script execution
python3() {
  if [[ "$1" == *"besman-get-env-list.py"* ]]; then
    # Create a mock environment list
    echo "test-env test-author 1.0.0" > "${BESMAN_DIR}/tmp/environment_details.txt"
    return 0
  elif [[ "$1" == *"besman-get-playbook-details.py"* ]]; then
    # Create a mock playbook list
    echo "test-playbook test-intent 1.0.0 ansible test-author test description" > "${BESMAN_DIR}/tmp/playbook_details.txt"
    return 0
  fi
  return 0
}

