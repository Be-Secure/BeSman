#!/bin/bash

function __bes_list {

local flag=$1
local env sorted_list

# For listing playbooks
if [[ ( -n $flag ) && ( ( $flag == "--playbook" ) || ( $flag == "-P" ) ) ]]; then

    __besman_list_playbooks

elif [[ ( -n $flag ) && ( $flag == "--role" ) ]]; then

    __besman_list_roles
elif [[ ( -n $flag ) && ( ( $flag == "--environment" ) || ( $flag == "-env" ) ) ]]; then

    __besman_list_envs

else
    
    __besman_echo_white "---------------------------ENVIRONMENTS-----------------------------------------------"
    __besman_echo_no_colour ""
    __besman_list_envs
    __besman_echo_no_colour ""
    __besman_echo_white "---------------------------PLAYBOOKS--------------------------------------------------"
    __besman_echo_no_colour ""
    __besman_list_playbooks
    __besman_echo_no_colour ""
    __besman_echo_white "---------------------------ROLES------------------------------------------------------"
    __besman_echo_no_colour ""
    __besman_list_roles
    __besman_echo_no_colour ""
fi
}
function __besman_list_envs()
{
    local current_version current_env installed_annotation remote_annotation
    __besman_check_repo_exist || return 1
    __besman_update_list
    # __besman_echo_no_colour "Github Org    Repo                             Environment     Version"
    # __besman_echo_no_colour "-----------------------------------------------------------------------------------"

    [[ -f "$BESMAN_DIR/var/current" ]] &&  current_env=$(cat "$BESMAN_DIR/var/current")
    [[ -f "$BESMAN_DIR/envs/besman-$current_env/current" ]] && current_version=$(cat "$BESMAN_DIR/envs/besman-$current_env/current")

    installed_annotation=$(__besman_echo_red "*")
    remote_annotation=$(__besman_echo_yellow "^")
    
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
        if [[ ("$env" == "$current_env") && ("$version" == "$current_version") ]] 
        then
            printf "%-14s %-32s %-25s %-8s\n" "$org" "$repo" "$env" "$version$installed_annotation"
        else
            printf "%-14s %-32s %-25s %-8s\n" "$org" "$repo" "$env" "$version$remote_annotation"
            
        fi
        
    done < "$BESMAN_DIR/var/list.txt"
    IFS=$OLD_IFS

    __besman_echo_no_colour ""

    __besman_echo_no_colour "==================================================================================="
    __besman_echo_no_colour "$remote_annotation - remote environment"
    __besman_echo_no_colour "$installed_annotation - installed environment"
    __besman_echo_no_colour "==================================================================================="
    __besman_echo_no_colour ""

    unset flag arr env list

    if [[ $BESMAN_LOCAL_ENV == "true" ]]; then

        __besman_echo_yellow "Pointing to local dir $BESMAN_LOCAL_ENV_DIR"
        __besman_echo_no_colour ""
        __besman_echo_white "If you wish to change, run the below command"
        __besman_echo_yellow "$ bes set BESMAN_LOCAL_ENV false"
        __besman_echo_yellow "$ bes set BESMAN_ENV_REPOS <GitHub Org>"
    else      
        __besman_echo_yellow "Pointing to $BESMAN_ENV_REPOS"
        __besman_echo_yellow "If you wish to change the repo run the below command"
        __besman_echo_yellow "$ bes set BESMAN_ENV_REPOS <GitHub Org>"
    fi
}
function __besman_check_repo_exist()
{
    local namespace repo response repo_url
    [[ $BESMAN_LOCAL_ENV == "true" ]] && return 0
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
    if [[ ( -n $BESMAN_LOCAL_ENV ) && ( $BESMAN_LOCAL_ENV == "true" )]]; then
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

        if [[ -z "$BESMAN_GH_TOKEN" ]]; then
        __besman_echo_yellow "Github token missing. Please use the below command to export the token"
        __besman_echo_no_colour ""
        __besman_echo_no_colour "$ bes set BESMAN_GH_TOKEN <copied token>"
        __besman_echo_no_colour ""
        return 1
    fi

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

function __besman_get_playbook_details()
{
    local scripts_file

    scripts_file="$BESMAN_DIR/scripts/besman-get-playbook-details.py"

    [[ ! -f "$scripts_file" ]] && __besman_echo_red "Could not find $scripts_file" && return 1

    python3 "$scripts_file"
}

function __besman_list_playbooks()
{


    local playbook_details_file playbook_details local_annotation remote_annotation

    playbook_details_file="$BESMAN_DIR/tmp/playbook_details.txt"

    __besman_get_playbook_details || return 1

    playbook_details=$(cat "$playbook_details_file")

    [[ ( ! -f "$playbook_details_file" ) || ( -z $playbook_details ) ]] && __besman_echo_red "Could not find playbook details" && return 1

    local_annotation=$(__besman_echo_red "+")
    remote_annotation=$(__besman_echo_yellow "^")
    
    printf "%-25s %-10s %-15s %-8s\n" "Name" "Version" "Type" "Author"
    __besman_echo_no_colour "----------------------------------------------------------------------"

    OLD_IFS=$IFS
    IFS=" "
      
    while read -r line; 
    do 
        # converted_line=$(echo "$line" | sed 's|,|/|g')
        read -r name version type author <<< "$line"
        if [[ -f "$BESMAN_PLAYBOOK_DIR/besman-$name-$version-playbook.sh" ]] 
        then
            
            printf "%-25s %-10s %-15s %-8s\n" "$name" "$version" "$type" "$author$local_annotation"
        else
            printf "%-25s %-10s %-15s %-8s\n" "$name" "$version" "$type" "$author$remote_annotation"

        fi
        
    done <<< "$playbook_details"
    IFS=$OLD_IFS

    __besman_echo_no_colour ""
    __besman_echo_no_colour "======================================================================="
    __besman_echo_no_colour "$remote_annotation - remote playbook"
    __besman_echo_no_colour "$local_annotation - local playbook"
    __besman_echo_no_colour "======================================================================="
    __besman_echo_no_colour ""

    [[ -f $playbook_details_file ]] && rm "$playbook_details_file"

}