#!/bin/bash

function __bes_create
{
   
    # bes create --playbook cve vuln name ext  
    local type=$1 #stores the type of the input - playbook/environment
    local return_val 
    
    # Checks whether the $type is playbook or not
    if [[ $type == "--playbook" || $type == "-P" ]]; then
    
        # checks whether the user github id has been populated or not under $BESMAN_USER_NAMESPACE 
        __besman_check_github_id || return 1
        # checks whether the user has already logged in or not to gh tool
        __besman_gh_auth_status $BESMAN_USER_NAMESPACE
        return_val=$?
        # if return_val == 0 then the user is already logged in
        if [[ $return_val == "0" ]]; then
    
            __besman_echo_white "Already logged in as $BESMAN_USER_NAMESPACE"

        # if return_val !=0 then user is not logged in
        else

            __besman_echo_white "authenticating.."
            __besman_gh_auth || return 1 
        
        fi
        
        __besman_echo_white "forking"
        __besman_gh_fork $BESMAN_NAMESPACE $BESMAN_PLAYBOOK_REPO 
        
        [[ "$?" != "0" ]] && return 1        
        
        if [[ ! -d $HOME/$BESMAN_PLAYBOOK_REPO ]]; then
            __besman_echo_white "cloning"  
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

        

        unset vuln env ext target_path return_val purpose
    else
    # TODO
        create_env
    
    fi
}

function __besman_create_playbook
{
    local args=("${@}")
    # checks whether any parameters are empty and if empty assign it as untitled.
    for (( i=0;i<${#};i++ ))
    do
        if [[ -z ${args[$i]}  ]]; then
            args[$i]="untitled"

        fi
    
    done
    
    local purpose=${args[0]} # CVE/assessment etc..
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
    
    # opens the created playbook in a jupyter notebook/vscode
    __besman_open_file $target_path
    
    unset args vuln env ext purpose
}   

# function create_env
# {
#     # TODO
# }

