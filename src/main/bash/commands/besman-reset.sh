#!/bin/bash

function __bes_reset
{
    local environment version

    environment=$1
    # version=$2

    __besman_reset_$environment 
   
    if [[ "$?" -eq 0 ]]; then
        __besman_echo_green "Reset Successful"
    else
        __besman_echo_red "Reset failed"
    fi

    unset environment version

    
}