#!/bin/bash

function __bes_list {

local flag=$1
local env

# For listing playbooks
if [[ ( -n $flag ) && ( $flag == "--playbook" ) ]]; then
    if [[ -d $BESMAN_DIR/playbook  ]]; then
        [[ -z $(ls $BESMAN_DIR/playbook | grep -v "README.md") ]] && __besman_echo_white "No playbook available" && return 1
        ls $BESMAN_DIR/playbook >> $HOME/temp.txt
        __besman_echo_no_colour "Available playbooks"
        __besman_echo_no_colour "-------------------"
        cat $HOME/temp.txt | grep -v "README.md"
        [[ -f $HOME/temp.txt ]] && rm $HOME/temp.txt
    else
    __besman_echo_white "No playbook available"
    fi

else
    __besman_check_repo_exist || return 1
    __besman_update_list
    # __besman_echo_no_colour "Github Org    Repo                             Environment     Version"
    # __besman_echo_no_colour "-----------------------------------------------------------------------------------"


    # For listing environments
    printf "%-14s %-32s %-25s %-8s\n" "Github Org" "Repo" "Environment" "Version"
    __besman_echo_no_colour "-----------------------------------------------------------------------------------"

    
    sed -i '/^$/d' "$BESMAN_DIR/var/list.txt"
    OLD_IFS=$IFS
    IFS="/"
      
    while read -r line; 
    do 


        converted_line=$(echo "$line" | sed 's|,|/|g')
        read -r org repo env version <<< "$converted_line"
        printf "%-14s %-32s %-25s %-8s\n" "$org" "$repo" "$env" "$version"


       
        
    done < "$BESMAN_DIR/var/list.txt"
    IFS=$OLD_IFS

    __besman_echo_no_colour ""

    unset flag arr env list

    if [[ $BESMAN_LOCAL_ENV == "True" ]]; then

        __besman_echo_yellow "Pointing to local dir $BESMAN_ENV_REPOS"
        __besman_echo_no_colour ""
        __besman_echo_white "If you wish to change, run the below command"
        __besman_echo_yellow "$ bes set BESMAN_LOCAL_ENV False"
        __besman_echo_yellow "$ bes set BESMAN_ENV_REPOS <GitHub Org>"
    else      
        __besman_echo_yellow "Pointing to $BESMAN_ENV_REPOS"
        __besman_echo_yellow "If you wish to change the repo run the below command"
        __besman_echo_yellow "$ bes set BESMAN_ENV_REPOS <GitHub Org>"
    fi
fi
}
function __besman_check_repo_exist()
{
    local namespace repo response repo_url
    namespace=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 1)
    repo=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 2)
    repo_url="https://api.github.com/repos/$namespace/$repo"

    response=$(curl --head --silent "$repo_url" | head -n 1 | awk '{print $2}')

    if [ "$response" -ne 200 ]; then
        __besman_echo_red "Repository $repo does not exist under $namespace"
        return 1
    fi

}

function __besman_update_list()
{
    local bes_list
    if [[ ( -n $BESMAN_LOCAL_ENV ) && ( $BESMAN_LOCAL_ENV == "True" )]]; then
        local env_dir_list bes_list
        [[ -z $BESMAN_ENV_REPOS ]] && __besman_echo_red "Please set the local env dir first" && return 1
        [[ ! -d $BESMAN_ENV_REPOS ]] && __besman_echo_red "Could not find dir $BESMAN_ENV_REPOS" && return 1

        env_dir_list=$(< "$BESMAN_ENV_REPOS/list.txt")
        bes_list=$BESMAN_DIR/var/list.txt
        echo "$env_dir_list" > "$bes_list"
    else
            
        local org repo path 
        org=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 1)
        repo=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 2)
        bes_list="$BESMAN_DIR/var/list.txt"
        path="https://raw.githubusercontent.com/$org/$repo/master/list.txt"
        __besman_secure_curl "$path" > "$bes_list"
    fi




}