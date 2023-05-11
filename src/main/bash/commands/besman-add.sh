#!/bin/bash

function __bes_add()
{
    if [[ -z "$BESMAN_ENV_REPO" ]]; #BESMAN_ENV_REPO contains the path to besecure-ce-env-repo dir
    then
        __besman_echo_white "Please provide complete path to besecure-ce-env-repo dir"
        while true #Loops until the value is given and a dir of the value is present
        do
            read -p "Enter path:" -r env_dir
            if [[ (-n "$env_dir") && (-d "$env_dir") ]]; 
            then
                export BESMAN_ENV_REPO="$env_dir"
                break 
            fi            
        done
    fi
    local environment ossp version
    environment=$1
    version="0.0.1"
    #Check if a file of the given name is present under the .besman/envs/
    [[ ! -f "$BESMAN_DIR/envs/besman-$environment.sh" ]] && __besman_echo_red "Could not find environment" && return 1
    ossp=$(echo "$environment" | cut -d "-" -f 1) # To get the name of the project from the env name. fastjson-RT-env >> fastjson
    path="$BESMAN_ENV_REPO/$ossp/$version/"
    mkdir -p "$BESMAN_ENV_REPO/$ossp/$version/"
    mv "$BESMAN_DIR/envs/besman-$environment.sh" "$path"
    __besman_add_to_list "$environment" "$version"
    export LOCAL_ENV="False"
    __besman_remove_env_from_local_list "$environment" "$version"
}

function __besman_add_to_list()
{
    local environment version
    environment=$1
    version=$2
    sed -i '/^$/d' "$BESMAN_ENV_REPO/list.txt" # Removing empty lines
    text="$BESMAN_NAMESPACE/$BESMAN_ENV_REPO/$environment,$version"
    echo "$text" >> "$BESMAN_ENV_REPO/list.txt"
}

function __besman_remove_env_from_local_list()
{
    local environment version
    environment=$1
    version=$2
    sed -i "s|'Local/Local/$environment,$version'||g" "$BESMAN_DIR/var/list.txt" #Using | as delimeter  
    sed -i '/^$/d' "$BESMAN_DIR/var/list.txt" # Removing empty lines

}