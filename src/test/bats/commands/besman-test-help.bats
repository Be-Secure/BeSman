#!/usr/bin/env bats
load '../mocks/besman-mock-functions'

function setup() {
    # source ~/.bashrc || echo "Failed to source bashrc"
    # source $BESMAN_DIR/bin/besman-init.sh || echo "Failed to source besman-init.sh"
    source "${BATS_TEST_DIRNAME}/../../../main/bash/commands/besman-help.sh"
}

# @test "Check if bes command is available" {
#     run type bes 
#     [ "$status" -eq 0 ]
# }

@test "besman help" {
    run __bes_help
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "bes - The cli for BeSman" ]]
}

@test "besman help install" {
    run __bes_help_install
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ " $ bes install -env <environment> -V <version>" ]]
}

@test "besman help uninstall" {
    run __bes_help_uninstall
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ " $ bes uninstall -env <environment name>" ]]
}

@test "besman help update" {
    run __bes_help_update
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes update -env <environment name>" ]]
}

@test "besman help list" {
    run __bes_help_list
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes list" ]]
}

@test "besman help validate" {
    run __bes_help_validate
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes validate -env <environment name>" ]]
}

@test "besman help reset" {
    run __bes_help_reset
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes reset -env <environment name>" ]]
}

@test "besman help version" {
    run __bes_help_version
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes -V" ]]
    [[ "$output" =~ "$ bes --version" ]]
}

@test "besman help set" {
    run __bes_help_set
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes set <variable> <value>" ]]
    [[ "$output" =~ "BESMAN CONFIG VARIABLES" ]]
}

@test "besman help pull" {
    run __bes_help_pull
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes pull --playbook <playbook name> -V <playbook version>" ]]
}

@test "besman help run" {
    run __bes_help_\run
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes run --playbook <playbook name> -V <playbook version>" ]]
}