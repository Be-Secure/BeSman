#!/bin/bash

function __bes_is_local_playbook_enabled() {
    [[ -n "$BESMAN_LOCAL_PLAYBOOK" && "$BESMAN_LOCAL_PLAYBOOK" == "true" ]]
}

function __bes_find_steps_file() {
    local base_name="$1"
    local steps_path

    steps_path="$(find "$BESMAN_LOCAL_PLAYBOOK_DIR/playbooks" -maxdepth 1 -type f -regex ".*/$base_name\.\(sh\|md\|ipynb\)" | head -n 1)"
    if [[ -z "$steps_path" ]]; then
        return 1
    fi
    basename "$steps_path"
}

function __bes_copy_files_to_playbook_dir() {
    local playbook_file_local="$1"
    local steps_file_local="$2"

    if [[ -z "$BESMAN_PLAYBOOK_DIR" ]]; then
        __besman_echo_red "BESMAN_PLAYBOOK_DIR is not set."
        __besman_echo_yellow "bes set BESMAN_PLAYBOOK_DIR <complete path to local playbook dir>"
        return 1
    fi

    cp -f "$playbook_file_local" "$BESMAN_PLAYBOOK_DIR" || {
        __besman_echo_red "Error: Failed to copy playbook to $BESMAN_PLAYBOOK_DIR"
        return 1
    }

    cp -f "$BESMAN_LOCAL_PLAYBOOK_DIR/playbooks/$steps_file_local" "$BESMAN_PLAYBOOK_DIR" || {
        __besman_echo_red "Error: Failed to copy steps file to $BESMAN_PLAYBOOK_DIR"
        return 1
    }
}

function __bes_handle_local_playbook() {
    local name="$1"
    local version="$2"
    local playbook_file_local steps_file_local steps_file_base_name

    if [[ -z "$BESMAN_LOCAL_PLAYBOOK_DIR" ]]; then
        __besman_echo_red "BESMAN_LOCAL_PLAYBOOK_DIR is not set."
        __besman_echo_yellow "bes set BESMAN_LOCAL_PLAYBOOK_DIR <complete path to local playbook dir>"
        return 1
    fi

    playbook_file_local="$BESMAN_LOCAL_PLAYBOOK_DIR/playbooks/besman-$name-playbook-$version.sh"
    steps_file_base_name="besman-$name-steps-$version"
    steps_file_local="$(__bes_find_steps_file "$steps_file_base_name")" || return 1

    if [[ ! -f "$playbook_file_local" ]]; then
        __besman_echo_red "Error: Local playbook file not found: $playbook_file_local"
        return 1
    fi

    if [[ ! -f "$steps_file_local" ]]; then
        __besman_echo_red "Error: Local steps file not found: $steps_file_local"
        return 1
    fi

    __bes_copy_files_to_playbook_dir "$playbook_file_local" "$steps_file_local" || return 1

    echo "$BESMAN_PLAYBOOK_DIR/besman-$name-playbook-$version.sh"
}

function __bes_handle_missing_playbook() {
    local file="$1"
    local name="$2"
    local version="$3"

    if __bes_is_local_playbook_enabled; then
        __besman_echo_red "Error: Playbook file not found: $file"
    else
        __besman_echo_no_colour ""
        __besman_echo_white "Please run the below command first to fetch the playbook"
        __besman_echo_yellow "bes pull --playbook $name -V $version"
        __besman_echo_no_colour ""
    fi
}

function __bes_run() {
    local playbook_name="$1"
    local playbook_version="$2"
    local force_flag="$3"
    local playbook_file

    if __bes_is_local_playbook_enabled; then
        playbook_file="$(__bes_handle_local_playbook "$playbook_name" "$playbook_version")" || return 1
    else
        playbook_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh"
        # __besman_fetch_playbook "$playbook_name" "$playbook_version" || return 1  # Uncomment if needed
    fi

    if [[ ! -f "$playbook_file" ]]; then
        __bes_handle_missing_playbook "$playbook_file" "$playbook_name" "$playbook_version"
        return 1
    fi

    source "$playbook_file" || return 1

    __besman_launch "$force_flag"
    [[ "$?" -eq 0 ]] && __besman_echo_green "Done."
    unset playbook_name playbook_version playbook_file
}