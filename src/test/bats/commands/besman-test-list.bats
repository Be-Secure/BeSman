#!/usr/bin/env bats

load '../helper/besman-list-helper'
load '../mocks/besman-mock-functions'

setup() {
    # Create temporary directories for testing
    export BESMAN_DIR="${BATS_TMPDIR}/.besman"
    export BESMAN_PLAYBOOK_DIR="${BESMAN_DIR}/playbooks"
    export BESMAN_SCRIPTS_DIR="${BESMAN_DIR}/scripts"
    export BESMAN_ENV_REPO="test-org/test-repo"
    export BESMAN_ENV_REPO_BRANCH="main"
    export BESMAN_LOCAL_ENV="false"
    export BESMAN_NAMESPACE="test-namespace"

    # Create necessary directories
    mkdir -p "${BESMAN_DIR}/var"
    mkdir -p "${BESMAN_DIR}/tmp"
    mkdir -p "${BESMAN_DIR}/envs"
    mkdir -p "${BESMAN_PLAYBOOK_DIR}"
    mkdir -p "${BESMAN_SCRIPTS_DIR}"

    touch "$BESMAN_SCRIPTS_DIR/besman-get-env-list.py"
    touch "$BESMAN_SCRIPTS_DIR/besman-get-playbook-details.py"

    # Source the script to be tested
    source "${BATS_TEST_DIRNAME}/../../../main/bash/commands/besman-list.sh"
}

teardown() {
    # Clean up temporary directories
    rm -rf "${BESMAN_DIR}"
    unset BESMAN_DIR BESMAN_PLAYBOOK_DIR BESMAN_ENV_REPO BESMAN_ENV_REPO_BRANCH BESMAN_LOCAL_ENV BESMAN_NAMESPACE
}

@test "List should display environments when --environment flag is used" {
    # Setup
    setup_environment_file "test-env" "test-author" "1.0.0"
    setup_current_environment "test-env" "1.0.0"
    # Run the command
    run __bes_list "--environment"

    echo "STATUS: $status"
    echo "OUTPUT: $output"

    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Environment"*"Author"*"Version"* ]]
    [[ "$output" == *"test-env"*"test-author"*"1.0.0"* ]]
}

@test "List should display environments when -env flag is used" {
    # Setup
    setup_environment_file "test-env" "test-author" "1.0.0"
    setup_current_environment "test-env" "1.0.0"

    # Run the command
    run __bes_list "-env"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Environment"*"Author"*"Version"* ]]
    [[ "$output" == *"test-env"*"test-author"*"1.0.0"* ]]
}

@test "List environments should mark current environment with an asterisk" {
    # Setup
    setup_environment_file "test-env" "test-author" "1.0.0"
    setup_current_environment "test-env" "1.0.0"

    # Create current environment
    echo "test-env" >"${BESMAN_DIR}/var/current"
    mkdir -p "${BESMAN_DIR}/envs/besman-test-env"
    echo "1.0.0" >"${BESMAN_DIR}/envs/besman-test-env/current"

    # Run the command
    run __bes_list "--environment"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"test-env"*"test-author"*"1.0.0*"* ]]
}

@test "List should display playbooks when --playbook flag is used" {
    # Setup
    echo "test-env" >"${BESMAN_DIR}/var/current"
    mkdir -p "${BESMAN_DIR}/envs/besman-test-env"
    echo "1.0.0" >"${BESMAN_DIR}/envs/besman-test-env/current"

    # Run the command
    run __bes_list "--playbook"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Compatible playbooks for"*"test-env"* ]]
    [[ "$output" == *"PLAYBOOK NAME"*"INTENT"*"VERSION"*"TYPE"*"AUTHOR"*"DESCRIPTION"* ]]
    [[ "$output" == *"test-playbook"*"test-intent"*"1.0.0"*"ansible"*"test-author"*"test description"* ]]
}

@test "List should display playbooks when -P flag is used" {
    # Setup
    echo "test-env" >"${BESMAN_DIR}/var/current"
    mkdir -p "${BESMAN_DIR}/envs/besman-test-env"
    echo "1.0.0" >"${BESMAN_DIR}/envs/besman-test-env/current"

    # Run the command
    run __bes_list "-P"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Compatible playbooks for"*"test-env"* ]]
}

@test "List playbooks should fail when no environment is installed" {
    # Setup - no current environment

    # Run the command
    run __bes_list "--playbook"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Missing environment"* ]]
}

@test "List playbooks should mark local playbooks with a plus sign" {
    # Setup
    echo "test-env" >"${BESMAN_DIR}/var/current"
    mkdir -p "${BESMAN_DIR}/envs/besman-test-env"
    echo "1.0.0" >"${BESMAN_DIR}/envs/besman-test-env/current"

    # Create a local playbook
    touch "${BESMAN_PLAYBOOK_DIR}/besman-test-playbook-1.0.0-playbook.sh"

    # Run the command
    run __bes_list "--playbook"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"test-playbook"*"test-author+"* ]]
}

@test "List should display roles when --role flag is used" {
    # Setup
    export BESMAN_GH_TOKEN="test-token"

    # Mock curl to return a list of repositories
    curl() {
        echo '{"full_name": "test-namespace/ansible-role-test"}'
    }

    # Run the command
    run __bes_list "--role"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Github Org"*"Repo"* ]]
    [[ "$output" == *"test-namespace"*"ansible-role-test"* ]]
}

@test "List roles should fail when no GitHub token is provided" {
    # Setup
    unset BESMAN_GH_TOKEN

    # Run the command
    run __bes_list "--role"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 1 ]
    [[ "$output" == *"Github token missing"* ]]
}

@test "List without flags should display environments, playbooks, and roles" {
    # Setup
    setup_environment_file "test-env" "test-author" "1.0.0"
    setup_current_environment "test-env" "1.0.0"

    echo "test-env" >"${BESMAN_DIR}/var/current"
    mkdir -p "${BESMAN_DIR}/envs/besman-test-env"
    echo "1.0.0" >"${BESMAN_DIR}/envs/besman-test-env/current"

    export BESMAN_GH_TOKEN="test-token"

    # Mock curl to return a list of repositories
    curl() {
        echo '{"full_name": "test-namespace/ansible-role-test"}'
    }

    # Run the command
    run __bes_list
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"ENVIRONMENTS"* ]]
    [[ "$output" == *"PLAYBOOKS"* ]]
    [[ "$output" == *"ROLES"* ]]
}

@test "List environments should handle local environment mode" {
    # Setup
    export BESMAN_LOCAL_ENV="true"
    export BESMAN_LOCAL_ENV_DIR="${BATS_TMPDIR}/local_env"
    mkdir -p "${BESMAN_LOCAL_ENV_DIR}"

    # Run the command
    run __bes_list "--environment"

    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Listing from local dir"* ]]
}

@test "List environments should fail when local env dir is not set" {
    # Setup
    export BESMAN_LOCAL_ENV="true"
    unset BESMAN_LOCAL_ENV_DIR

    # Run the command
    run __besman_update_list

    # Verify
    [ "$status" -eq 1 ]
    [[ "$output" == *"Could not find your local environment dir"* ]]
}
