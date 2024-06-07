#!/bin/bash

function __bes_reload()
{
    local environment_name

    [[ ! -f "$BESMAN_DIR/var/current" ]] && __besman_echo_red "No environment found. Please install an environment first." && return 1
    environment_name=$(cat "$BESMAN_DIR/var/current")
    version=$(cat "${BESMAN_DIR}/envs/besman-${environment_name}/current")

    
    [[ ! -d "$BESMAN_DIR/envs/besman-$environment_name" ]] && __besman_echo_red "No environment found. Please install an environment first." && return 1

    __besman_source_env_params "$environment_name" "$version" || return 1

    __besman_echo_green "Done."
    

}