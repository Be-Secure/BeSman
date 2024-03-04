#!/bin/bash

function __bes_run()
{
    local playbook_name playbook_version

    playbook_name="$1"
    playbook_version="$2"

    __besman_fetch_playbook "$playbook_name" "$playbook_version" || return 1
    
    source "$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-playbook.sh"
    
    __besman_launch

    unset playbook_name playbook_version

}

function __besman_fetch_playbook()
{
    local playbook_name playbook_version lifecycle_file steps_file lifecyle_file_url steps_file_url

    playbook_name="$1"
    playbook_version="$2"

    lifecycle_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-playbook.sh"
    lifecyle_file_url="https://raw.githubusercontent.com/$BESMAN_NAMESPACE/$BESMAN_PLAYBOOK_REPO/main/playbooks/besman-$playbook_name-$playbook_version-playbook.sh"
    
    # steps_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-$playbook_version-steps.sh"
    # steps_file_url="https://raw.githubusercontent.com/$BESMAN_NAMESPACE/$BESMAN_PLAYBOOK_REPO/main/playbooks/besman-$playbook_name-$playbook_version-steps.sh"

    __besman_check_url_valid "$lifecyle_file_url" || return 1
    # __besman_check_url_valid "$steps_file_url" || return 1
    
    touch "$lifecycle_file" 

    __besman_secure_curl "$lifecyle_file_url" >> "$lifecycle_file"

    unset playbook_name playbook_version lifecycle_file steps_file lifecyle_file_url steps_file_url

    
}