#!/bin/bash

function __bes_pull
{   
    __besman_check_github_id $BESMAN_USER_NAMESPACE || return 1
    local type repo dir remote branch return_val namespace
    playbook_name=$2
    playbook_version=$3
    dir=$BESMAN_DIR/playbooks
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
    unset dir playbook_name playbook_version
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


