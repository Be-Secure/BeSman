#!/bin/bash

function __bes_run() {
    local playbook_name playbook_version

    playbook_name="$1"
    playbook_version="$2"

    __besman_fetch_playbook "$playbook_name" "$playbook_version" || return 1

    source "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-playbook.sh"

    __besman_launch

    unset playbook_name playbook_version

}

function __besman_fetch_playbook() {
    local playbook_name playbook_version lifecycle_file lifecyle_file_url 

    playbook_name="$1"
    playbook_version="$2"

    lifecycle_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-playbook.sh"
    lifecyle_file_url="https://raw.githubusercontent.com/$BESMAN_NAMESPACE/$BESMAN_PLAYBOOK_REPO/main/playbooks/besman-$playbook_name-$playbook_version-playbook.sh"

    if [[ -f $lifecycle_file ]]; then
        __besman_echo_yellow "Playbook $playbook_name $playbook_version exist."

        read -rp "Do you wish to overwrite(y/n):" overwrite
        if [[ "$overwrite" == "y" ]]; then
            rm "$lifecycle_file"
            __besman_check_url_valid "$lifecyle_file_url" || return 1

            touch "$lifecycle_file"

            __besman_secure_curl "$lifecyle_file_url" >>"$lifecycle_file"
        fi

    else
        __besman_check_url_valid "$lifecyle_file_url" || return 1

        touch "$lifecycle_file"

        __besman_secure_curl "$lifecyle_file_url" >>"$lifecycle_file"

    fi


    unset playbook_name playbook_version lifecycle_file lifecyle_file_url 

}
