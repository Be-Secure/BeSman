#!/usr/bin/env bats

function setup() {
    export BESMAN_DIR="${BATS_TMPDIR}/.besman"
    export BESMAN_VERSION="0.5.0"
    mkdir -p "${BESMAN_DIR}/var"
    echo "$BESMAN_VERSION" > "${BESMAN_DIR}/var/version.txt"
    source "${BATS_TEST_DIRNAME}/../../../main/bash/commands/besman-version.sh"
}

function teardown() {
    rm -rf "${BESMAN_DIR}"
    unset BESMAN_VERSION BESMAN_DIR
}

@test "besman version" {
    # run bes -V || run bes --version
    run __bes_version
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "BeSman utility version" ]]
    [[ "$output" =~ "0.5.0" ]]
}