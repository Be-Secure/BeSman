#!/bin/bash

function __bes_validate
{
    local environment=$1

    __besman_echo_white "Validating $environment"

    __besman_validate_$environment 
    if [[ "$?" -eq 0 ]]; then
        __besman_echo_green "Successfully validated"
    else
        __besman_echo_red "Validation failed"
    fi


}