#!/bin/bash

function __bes_run() {
    local playbook_name playbook_version playbook_file playbook_file_local

    playbook_name="$1"
    playbook_version="$2"

    if [[ -n "$BESMAN_LOCAL_PLAYBOOK" && "$BESMAN_LOCAL_PLAYBOOK" == "true" ]]; then
        # Use local playbook
        if [[ -n "$BESMAN_LOCAL_PLAYBOOK_DIR" ]]; then
            playbook_file_local="$BESMAN_LOCAL_PLAYBOOK_DIR/playbooks/besman-$playbook_name-playbook-$playbook_version.sh"

            if [[ ! -f "$playbook_file_local" ]]; then
                __besman_echo_red "Error: Local playbook file not found: $playbook_file_local"
                return 1
            fi

            # Copy the playbook file
            if [[ -n "$BESMAN_PLAYBOOK_DIR" ]]; then
                cp -f "$playbook_file_local" "$BESMAN_PLAYBOOK_DIR" || { # -f for force overwrite
                    __besman_echo_red "Error: Failed to copy playbook to $BESMAN_PLAYBOOK_DIR"
                    return 1
                }
                playbook_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh" # Correct path after copy
            else
                __besman_echo_red "BESMAN_PLAYBOOK_DIR is not set."
                __besman_echo_yellow "bes set BESMAN_PLAYBOOK_DIR <complete path to local playbook dir>"
                return 1
            fi
        else
            __besman_echo_red "BESMAN_LOCAL_PLAYBOOK_DIR is not set."
            __besman_echo_yellow "bes set BESMAN_LOCAL_PLAYBOOK_DIR <complete path to local playbook dir>"
            return 1
        fi # This 'fi' was missing
    else   # Fetch from GitHub only if BESMAN_LOCAL_PLAYBOOK is NOT true
        playbook_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh"
        # __besman_fetch_playbook "$playbook_name" "$playbook_version" || return 1  # Uncomment if needed
    fi

    # ... (rest of the script remains the same)
    if [[ ! -f "$playbook_file" ]]; then # Check if the final playbook file exists
        if [[ -n "$BESMAN_LOCAL_PLAYBOOK" && "$BESMAN_LOCAL_PLAYBOOK" == "true" ]]; then
            __besman_echo_red "Error: Playbook file not found: $playbook_file"
        else
            __besman_echo_no_colour ""
            __besman_echo_white "Please run the below command first to fetch the playbook"
            __besman_echo_yellow "bes pull --playbook $playbook_name -V $playbook_version"
            __besman_echo_no_colour ""
        fi
        return 1
    fi

    source "$playbook_file" || return 1

    __besman_launch

    if [[ "$?" -eq "0" ]]; then
        __besman_echo_green "Done."
    fi

    unset playbook_name playbook_version playbook_file playbook_file_local

}
