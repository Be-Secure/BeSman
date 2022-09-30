#!/bin/bash

function __bes_pull
{   __besman_check_for_gh || return 1
    __besman_check_github_id $BESMAN_USER_NAMESPACE || return 1
    __besman_gh_auth $BESMAN_USER_NAMESPACE
    local type repo dir remote branch return_val namespace
    type=$1
    namespace=$2
    if [[ $type == "playbook" ]]; then
        [[ -z $namespace ]] && namespace=$BESMAN_NAMESPACE
        repo=$BESMAN_PLAYBOOK_REPO
        dir=$BESMAN_DIR/playbook
    elif [[ $type == "environment" ]]; then
        repo=besecure-ce-env-repo
        dir=$BESMAN_DIR/envs
    fi
    if [[ $namespace == $BESMAN_NAMESPACE ]]; then
        remote=upstream
    else
        remote=origin
    fi
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
        __besman_gh_quiet_clone $namespace $repo $dir
        [[ "$?" -eq 1 ]] && __besman_echo_red "Something went wrong" && rm -rf $dir &&return 1
        __besman_echo_green "Playbooks added successfully"
    fi
    unset type repo dir remote branch return_val namespace
}