#!/usr/bin/env bats

function setup() {
    source ~/.bashrc || echo "Failed to source bashrc"
    source $BESMAN_DIR/bin/besman-init.sh || echo "Failed to source besman-init.sh"
}

@test "Check if bes command is available" {
    run type bes 
    [ "$status" -eq 0 ]
}

@test "besman version" {
    run bes -V || run bes --version
    echo "Output: $output"
    echo "Status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "BeSman utility version" ]]
}