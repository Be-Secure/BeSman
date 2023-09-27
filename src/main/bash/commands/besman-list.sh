#!/bin/bash

function __bes_list {

local flag=$1
local env sorted_list

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

elif [[ ( -n $flag ) && ( $flag == "--roles" ) ]]; then
    if [[ -z "$BESMAN_GH_TOKEN" ]]; then
        __besman_echo_yellow "Github token missing. Please use the below command to export the token"
        __besman_echo_no_colour ""
        __besman_echo_no_colour "$ bes set BESMAN_GH_TOKEN <copied token>"
        __besman_echo_no_colour ""
        return 1
    fi
    __besman_list_roles

else
    __besman_check_repo_exist || return 1
    __besman_update_list
    # __besman_echo_no_colour "Github Org    Repo                             Environment     Version"
    # __besman_echo_no_colour "-----------------------------------------------------------------------------------"


    # For listing environments
    printf "%-14s %-32s %-25s %-8s\n" "Github Org" "Repo" "Environment" "Version"
    __besman_echo_no_colour "-----------------------------------------------------------------------------------"

    
    sed -i '/^$/d' "$BESMAN_DIR/var/list.txt"
    sorted_list=$(sort "$BESMAN_DIR/var/list.txt")
    echo "$sorted_list" > "$BESMAN_DIR/var/list.txt"
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

        __besman_echo_yellow "Pointing to local dir $BESMAN_LOCAL_ENV_DIR"
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
    [[ $BESMAN_LOCAL_ENV == "True" ]] && return 0
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
        [[ -z $BESMAN_LOCAL_ENV_DIR ]] && __besman_echo_red "Please set the local env dir first" && return 1
        [[ ! -d $BESMAN_LOCAL_ENV_DIR ]] && __besman_echo_red "Could not find dir $BESMAN_LOCAL_ENV_DIR" && return 1

        env_dir_list=$(< "$BESMAN_LOCAL_ENV_DIR/list.txt")
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

# Function to extract repository names from a JSON response
function __besman_extract_repo_names()
{
  echo "$1" | grep -oP '"full_name": "\K[^"]+'
}


function __besman_list_roles()
{
    local api_url repo_names all_repo_names page_num ansible_roles

    api_url="https://api.github.com/orgs/$BESMAN_NAMESPACE/repos?per_page=100&page=1"

    # Get the first page of repository names
    repo_names=$(curl -s -H "Authorization: token $BESMAN_GH_TOKEN" "$api_url")

    # Extract repository names from the first page
    all_repo_names=$(__besman_extract_repo_names "$repo_names")
    page_num=1
    # Check if there are more pages and continue fetching if needed
    while [ "$(echo "$repo_names" | grep -c '"full_name"')" -eq 100 ]; do
        page_num=$((page_num + 1))
        api_url="https://api.github.com/orgs/$BESMAN_NAMESPACE/repos?per_page=100&page=$page_num"
        repo_names=$(curl -s -H "Authorization: token $BESMAN_GH_TOKEN" "$api_url")
        all_repo_names="$all_repo_names
        $(__besman_extract_repo_names "$repo_names")"
    done

    ansible_roles=$(echo "$all_repo_names" | grep "ansible-role-*")
    
    printf "%-14s %10s \n" "Github Org" "Repo"
    __besman_echo_no_colour "-----------------------------------"
    for i in $ansible_roles
    do
        converted_i=$(echo "$i" | sed "s|/| |g")
        read -r org repo <<< "$converted_i"
        printf "%-14s %-32s \n" "$org" "$repo"
    done
    

}