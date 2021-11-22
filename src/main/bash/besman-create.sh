#!/bin/bash

function __bes_create
{
   
    # bes create --playbook cve vuln name ext  
    type=$1
    if [[ $type == "--playbook" || $type == "-P" ]]; then
        echo "authenticating.."
        __besman_check_github_id || return 1
        __besman_gh_auth || return 1    
        echo "forking"
        __besman_gh_fork $BESMAN_NAMESPACE $BESMAN_PLAYBOOK_REPO 
        [[ "$?" != "0" ]] && return 1
        echo "cloning"
        
        __besman_gh_clone $BESMAN_USER_NAMESPACE $BESMAN_PLAYBOOK_REPO $HOME/$BESMAN_PLAYBOOK_REPO
        [[ "$?" != "0" ]] && return 1
        cve=$2
        vuln=$3
        env=$4
        ext=$5
        [[ -z $ext ]] && ext="md"
        target_path=$HOME/$BESMAN_PLAYBOOK_REPO
        __besman_create_playbook "$cve" "$vuln" "$env" "$ext" "$target_path"
        unset cve vuln env ext target_path
    else
        create_env
    fi
}

function __besman_create_playbook
{
    args=("${@}")
    for (( i=0;i<${#};i++ ))
    do
        if [[ -z ${args[$i]}  ]]; then
            args[$i]="untitled"

        fi
    done
    cve=${args[0]}
    vuln=${args[1]}
    env=${args[2]}
    ext=${args[3]}
    # [[ -z $ext ]] && ext="md"
    touch $target_path/besman-$cve-$vuln-$env-playbook.$ext
    if [[ "$?" == "0" ]]; then
    __besman_echo_green "Playbook created successfully"
    else
    __besman_echo_red "Could not create playbook"
    fi
    __besman_open_file $target_path
    unset args cve vuln env ext
}   

# function create_env
# {
#     # TODO
# }

