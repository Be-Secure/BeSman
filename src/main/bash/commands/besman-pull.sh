#!/bin/bash

function __bes_pull
{   
    local type repo dir remote branch return_val
    type=$1
    if [[ $type == "playbook" ]]; then
        repo=$BESMAN_PLAYBOOK_REPO
        dir=$BESMAN_DIR/playbook
    elif [[ $type == "environment" ]]; then
        # repo=besecure-ce-env-repo
        dir=$BESMAN_DIR/envs
    fi
    remote=origin
    branch=main
    if [[ -d $dir ]]; then
        cd $dir
        __besman_echo_white "Checking for updates..."
        __besman_git_pull $remote $branch
        return_val=$?
        # echo "return value:"$return_val

        if [[ $return_val == "1" ]]; then
            __besman_echo_red "Could not pull playbooks"
        elif [[ $return_val == "2" ]]; then
            __besman_echo_white "Playbooks already upto date"
        elif [[ $return_val == "0" ]]; then
            __besman_echo_green "Playbooks updated/added successsfully."
        fi
        cd $HOME
    else
        mkdir -p $dir 
        __besman_echo_white "Fetching playbooks..." 
        __besman_gh_quiet_clone $BESMAN_USER_NAMESPACE $repo $dir
        __besman_echo_green "Playbooks added successfully"
    fi
    unset type repo dir remote branch return_val
}