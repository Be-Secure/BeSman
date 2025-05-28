#!/usr/bin/env bats

load '../mocks/besman-mock-functions'

function setup() {
    export BESMAN_DIR="${BATS_TMPDIR}/.besman"
    
    mkdir -p "${BESMAN_DIR}/etc"

    touch "${BESMAN_DIR}/etc/user-config.cfg"
    
    echo "BESMAN_ENV_REPO=test-org/test-repo" > "${BESMAN_DIR}/etc/user-config.cfg"

    source "${BATS_TEST_DIRNAME}/../../../main/bash/commands/besman-set.sh"

}

function teardown() {
    rm -rf "${BESMAN_DIR}"
    unset BESMAN_DIR
}

@test "Set should update the user config variable" {
    run __bes_set "BESMAN_ENV_REPO" "new-org/new-repo"
    echo "Output: $output"
    echo "Status: $status"

    # Verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"Variable 'BESMAN_ENV_REPO' value updated to 'new-org/new-repo'"* ]]
    grep -q "BESMAN_ENV_REPO=new-org/new-repo" "${BESMAN_DIR}/etc/user-config.cfg"
}

@test "set command fails with missing arguments" {
    run __bes_set
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 1 ]
}

@test "set command fails with invalid variable name" {
    run __bes_set "INVALID_VAR" "somevalue" 
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 1 ]
}
