#!/bin/bash

function __bes_create
{
   
    # bes create --playbook cve vuln name ext  
    local type=$1
    if [[ $type == "--playbook" || $type == "-P" ]]; then
        __besman_check_github_id || return 1
        echo "authenticating.."
        __besman_gh_auth || return 1    
        echo "forking"
        __besman_gh_fork $BESMAN_NAMESPACE $BESMAN_PLAYBOOK_REPO 
        [[ "$?" != "0" ]] && return 1        
        if [[ ! -d $HOME/$BESMAN_PLAYBOOK_REPO ]]; then
            echo "cloning"  
            __besman_gh_clone $BESMAN_USER_NAMESPACE $BESMAN_PLAYBOOK_REPO $HOME/$BESMAN_PLAYBOOK_REPO
            [[ "$?" != "0" ]] && return 1
        fi
        local flag=$2
        local purpose=$3
        local vuln=$4
        local env=$5
        local ext=$6
        [[ -z $ext ]] && ext="md"
        __besman_create_playbook "$purpose" "$vuln" "$env" "$ext" 

        

        unset vuln env ext target_path purpose
    else
        create_env
    fi
}

function __besman_create_playbook
{
    local args=("${@}")
    for (( i=0;i<${#};i++ ))
    do
        if [[ -z ${args[$i]}  ]]; then
            args[$i]="untitled"

        fi
    done
    local purpose=${args[0]}
    local vuln=${args[1]}
    local env=${args[2]}
    local ext=${args[3]}
    # [[ -z $ext ]] && ext="md"
    local target_path=$HOME/$BESMAN_PLAYBOOK_REPO
    touch $target_path/besman-$purpose-$vuln-$env-playbook.$ext
    if [[ "$?" == "0" ]]; then
    __besman_echo_green "Playbook created successfully"
    else
    __besman_echo_red "Could not create playbook"
    fi
    __besman_open_file $target_path
    unset args vuln env ext purpose
}   

# function create_env
# {
#     # TODO
# }

