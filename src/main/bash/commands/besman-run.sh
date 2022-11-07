#!/bin/bash

function __bes_run
{
    local playbook result inputs
    playbook=$2
    inputs=$( echo $@ | cut -d " " -f 3-)
    __besman_get_playbook_extension "$playbook"
    if [[ "$?" -eq 0 ]]; then
        __besman_echo_white "Running playbook as shell script"
        source $BESMAN_PLAYBOOK_DIR/$playbook.sh "${inputs[@]}"
        result=$?
        __besman_output_result "$result"
    elif [[ "$?" -eq 1 ]]; then
        __besman_echo_white "Opening playbook as md file"
        code $BESMAN_PLAYBOOK_DIR/$playbook.md
        result=$?
        __besman_output_result "$result"
    elif [[ "$?" -eq 2 ]]; then
        __besman_echo_white "Running playbook as yml file"
        ansible-playbook --ask-become-pass $BESMAN_PLAYBOOK_DIR/$playbook.yml
        result=$?
        __besman_output_result "$result"
    elif [[ "$?" -eq 3 ]]; then
        __besman_echo_red "Besman only supports playbooks with md/sh/yml extensions"
        return 1
    fi


}

function __besman_output_result
{
    local result=$1

    if [[ $result -eq 0 ]]; then
        __besman_echo_green "Done."
    elif [[ $result -eq 1 ]]; then
        __besman_echo_red "Something went wrong"
    fi


}

function __besman_get_playbook_extension
{
    local playbook ext
    playbook=$1

    ext=$(ls $BESMAN_PLAYBOOK_DIR | grep "$playbook" | cut -d "." -f 2)
    if [[ $ext == "sh" ]]; then
        return 0
    elif [[ $ext == "md" ]]; then
        return 1
    elif [[ $ext == "yml" ]]; then
        return 2
    else    
        return 3
    fi
}

