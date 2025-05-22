#!/usr/bin/env bats

function setup() {
    source ~/.bashrc || echo "Failed to source bashrc"
    source $BESMAN_DIR/bin/besman-init.sh || echo "Failed to source besman-init.sh"
}

@test "Check if bes command is available" {
    run type bes 
    [ "$status" -eq 0 ]
}

@test "besman help" {
    run bes help
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "bes - The cli for BeSman" ]]
}

@test "besman help install" {
    run bes help install
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ " $ bes install -env <environment> -V <version>" ]]
}

@test "besman help uninstall" {
    run bes help uninstall
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ " $ bes uninstall -env <environment name>" ]]
}

@test "besman help update" {
    run bes help update
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes update -env <environment name>" ]]
}

@test "besman help list" {
    run bes help list
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes list" ]]
}

@test "besman help validate" {
    run bes help validate
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes validate -env <environment name>" ]]
}

@test "besman help reset" {
    run bes help reset
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes reset -env <environment name>" ]]
}

@test "besman help version" {
    run bes help version
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes -V" ]]
    [[ "$output" =~ "$ bes --version" ]]
}

@test "besman help set" {
    run bes help set
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes set <variable> <value>" ]]
    [[ "$output" =~ "BESMAN CONFIG VARIABLES" ]]
}

@test "besman help pull" {
    run bes help pull
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes pull --playbook <playbook name> -V <playbook version>" ]]
}

@test "besman help run" {
    run bes help \run
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "$ bes run --playbook <playbook name> -V <playbook version>" ]]
}