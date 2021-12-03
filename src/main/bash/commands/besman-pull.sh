#!/bin/bash

function __bes_pull
{   
    local type repo dir remote branch
    type=$1
    if [[ $type == "playbook" ]]; then
        repo=$BESMAN_PLAYBOOK_REPO
        dir=$BESMAN_DIR/playbook
    elif [[ $type == "environment" ]]; then
        repo=besecure-ce-env-repo
        dir=$BESMAN_DIR/envs
    fi
    remote=origin
    branch=main
    if [[ -d $dir ]]; then
        cd $dir
        __besman_echo_white "Playbook folder found. Checking for updates..."
        __besman_git_pull $remote $branch
        cd ~
    else
        mkdir -p $dir 
        __besman_echo_white "Fetching playbooks..." 
        __besman_gh_clone $BESMAN_NAMESPACE $repo $dir
    fi
}