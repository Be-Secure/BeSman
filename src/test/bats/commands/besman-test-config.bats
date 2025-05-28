#!/usr/bin/env bats

load '../mocks/besman-mock-functions'

function setup() {
    export BESMAN_DIR="${BATS_TMPDIR}/.besman"
    export BESMAN_ENV_REPO="Be-Secure/besecure-ce-env-repo"
    export BESMAN_ENV_REPO_BRANCH="master"
    export HOME="${BATS_TMPDIR}/home"

    mkdir -p "${BESMAN_DIR}/etc"
    mkdir -p "${HOME}"
    
    echo "# User config" > "${BESMAN_DIR}/etc/user-config.cfg"
    echo "# BeSman config" > "${BESMAN_DIR}/etc/config"
    source "${BATS_TEST_DIRNAME}/../../../main/bash/commands/besman-config.sh"
}

function teardown() {
    rm -rf "${BESMAN_DIR}" "${HOME}"
    unset BESMAN_DIR BESMAN_ENV_REPO BESMAN_ENV_REPO_BRANCH HOME
}

@test "Config should download and open env config files" {
    code() { 
    echo "Opening files: $*"
    export -f code
    }
    run __bes_config "fastjson-RT-env" "0.0.1"
    echo  "Output: $output"
    echo "Status: $status"
    [[ "$status" -eq 0 ]]
    [[ -f "$HOME/besman-fastjson-RT-env-config.yaml" ]]
    [[ $output =~ "$BESMAN_ENV_REPO" ]]
    [[ $output =~ "$BESMAN_ENV_REPO_BRANCH" ]]
    [[ $output =~ "Trying to open config file in vscode.." ]]
     [[ "$output" == *"besman-fastjson-RT-env-config.yaml"* ]]
}

@test "Config command without parameters opens BeSman config files" {
    # Mock code command to simulate VS Code availability
    code() { echo "Opening files: $*"; }
    export -f code
    
    run __bes_config
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"User did not pass environment parameters"* ]]
    [[ "$output" == *"Trying to open BeSman config files in vscode"* ]]
    [[ "$output" == *"Opening files:"* ]]
    [[ "$output" == *"user-config.cfg"* ]]
    [[ "$output" == *"/etc/config"* ]]
}

@test "Config command prompts user when config file already exists and user chooses to replace" {
    # Create existing config file
    echo "# Existing config" > "${HOME}/besman-fastjson-RT-env-config.yaml"
    # Mock code command
    code() { echo "Opening files: $*"; }
    export -f code

    
    # Mock user input - choose to replace
    run __bes_config "fastjson-RT-env" "1.0.0" <<EOF
    y
EOF
    # write output to console
    echo "Output: $output"
    echo "Status: $status"
    
    [[ $status -eq 0 ]]
    [[ -f "$HOME/besman-fastjson-RT-env-config.yaml" ]]
    [[ "$output" == *"File besman-fastjson-RT-env-config.yaml already exists under"* ]]
    [[ "$output" =~ "Replacing..." ]]
    [[ "$output" =~ "Downloading config file" ]]
}


@test "Config command prompts user when config file already exists and user not chooses to replace" {
    # Create existing config file
    echo "# Existing config" > "${HOME}/besman-fastjson-RT-env-config.yaml"
    # Mock code command
    code() { echo "Opening files: $*"; }
    export -f code

    
    # Mock user input - choose to replace
    run __bes_config "fastjson-RT-env" "1.0.0" <<EOF
    n
EOF
    # write output to console
    echo "Output: $output"
    echo "Status: $status"
    
    [[ $status -eq 1 ]]
    [[ -f "$HOME/besman-fastjson-RT-env-config.yaml" ]]
    [[ "$output" == *"File besman-fastjson-RT-env-config.yaml already exists under"* ]]
    [[ "$output" == *"You chose not to replace."* ]]
    [[ "$output" =~ "Exiting.." ]]
}