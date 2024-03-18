#!/bin/bash

function __bes_pull
{   
    __besman_check_for_gh || return 1
    __besman_check_github_id $BESMAN_USER_NAMESPACE || return 1
    __besman_gh_auth $BESMAN_USER_NAMESPACE
    local type repo dir remote branch return_val namespace
    type=$1
    playbook_name=$2
    playbook_version=$3
    if [[ $type == "playbook" ]]; then
        dir=$BESMAN_DIR/playbooks
    fi
    __besman_echo_white "Fetching playbooks..." 
    if [[ -d $dir ]]; then
        cd $dir
        __besman_fetch_playbook $playbook_name $playbook_version
        cd $HOME
    else
        mkdir -p $dir 
        __besman_fetch_playbook $playbook_name $playbook_version
        cd $HOME
    fi
    unset type dir return_val playbook_name playbook_version
}

function __besman_fetch_playbook() {
    local lifecycle_file lifecyle_file_url
    playbook_name="$1"
    playbook_version="$2"
    lifecycle_file="$BESMAN_DIR/playbooks/besman-$playbook_name-$playbook_version-playbook.sh"
    lifecyle_file_url="https://raw.githubusercontent.com/$BESMAN_NAMESPACE/$BESMAN_PLAYBOOK_REPO/main/playbooks/besman-$playbook_name-$playbook_version-playbook.sh"

    if [[ -f $lifecycle_file ]]; then
        __besman_echo_yellow "Playbook $playbook_name $playbook_version exist."
        read -rp "Do you wish to overwrite(y/n):" overwrite
        if [[ "$overwrite" == "y" ]]; then
            rm "$lifecycle_file"
            __besman_check_url_valid "$lifecyle_file_url" || return 1
            touch "$lifecycle_file"
            __besman_secure_curl "$lifecyle_file_url" >>"$lifecycle_file"
            __besman_echo_green "Playbook $playbook_name $playbook_version updated successsfully."
        fi
    else
        __besman_check_url_valid "$lifecyle_file_url" || return 1
        touch "$lifecycle_file"
        __besman_secure_curl "$lifecyle_file_url" >>"$lifecycle_file"
        __besman_echo_green "Playbook $playbook_name $playbook_version added successsfully."
    fi
    unset lifecycle_file lifecyle_file_url playbook_name playbook_version
}

function __besman_check_url_valid() {
    local url=$1
    local response_code

    if command -v curl &> /dev/null; then
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    elif command -v wget &> /dev/null; then
        response_code=$(wget --spider -S "$url" 2>&1 | grep "HTTP/" | awk '{print $2}')
    else
        __besman_echo_red "Neither curl nor wget found."
        return 1
    fi

    if [[ $response_code -eq 200 ]]; then
        return 0
    else
        __besman_echo_red "playbook_name or playbook_version or BESMAN_NAMESPACE not valid."
        return 1
    fi
    unset response_code
}

