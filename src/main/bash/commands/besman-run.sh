#!/bin/bash

function __besman_is_local_playbook_enabled() {
    [[ -n "$BESMAN_LOCAL_PLAYBOOK" && "$BESMAN_LOCAL_PLAYBOOK" == "true" ]]
}

function __besman_find_steps_file() {
    local base_name="$1"
    local steps_path

    # Find the first matching steps file with .sh, .md, or .ipynb extension
    for ext in sh md ipynb; do
        steps_path="$BESMAN_LOCAL_PLAYBOOK_DIR/playbooks/$base_name.$ext"
        if [[ -f "$steps_path" ]]; then
            echo "$steps_path"
            return 0
        fi
    done

    return 1
}

function __besman_copy_files_to_playbook_dir() {
    local playbook_file_local="$1"
    local steps_file_local="$2"

    if [[ -z "$BESMAN_PLAYBOOK_DIR" ]]; then
        __besman_echo_red "BESMAN_PLAYBOOK_DIR is not set."
        __besman_echo_yellow "bes set BESMAN_PLAYBOOK_DIR <complete path to local playbook dir>"
        return 1
    fi

    mkdir -p "$BESMAN_PLAYBOOK_DIR"

    cp -f "$playbook_file_local" "$BESMAN_PLAYBOOK_DIR" || {
        __besman_echo_red "Error: Failed to copy playbook to $BESMAN_PLAYBOOK_DIR"
        return 1
    }

    cp -f "$steps_file_local" "$BESMAN_PLAYBOOK_DIR" || {
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
    steps_file_local="$(__besman_find_steps_file "$steps_file_base_name")" || return 1

    if [[ ! -f "$playbook_file_local" ]]; then
        __besman_echo_red "Error: Local playbook file not found: $playbook_file_local"
        return 1
    fi

    if [[ ! -f "$steps_file_local" ]]; then
        __besman_echo_red "Error: Local steps file not found: $steps_file_local"
        return 1
    fi

    __besman_copy_files_to_playbook_dir "$playbook_file_local" "$steps_file_local" || return 1

    echo "$BESMAN_PLAYBOOK_DIR/besman-$name-playbook-$version.sh"
}

function __besman_handle_missing_playbook() {
    local file="$1"
    local name="$2"
    local version="$3"

    if __besman_is_local_playbook_enabled; then
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

    if __besman_is_local_playbook_enabled; then
        playbook_file="$(__bes_handle_local_playbook "$playbook_name" "$playbook_version")" || return 1
    else
        playbook_file="$BESMAN_PLAYBOOK_DIR/besman-$playbook_name-playbook-$playbook_version.sh"
        # __besman_fetch_playbook "$playbook_name" "$playbook_version" || return 1  # Uncomment if needed
    fi

    if [[ ! -f "$playbook_file" ]]; then
        __besman_handle_missing_playbook "$playbook_file" "$playbook_name" "$playbook_version"
        return 1
    fi

    source "$playbook_file" || return 1

    if [[ -n $force_flag && $force_flag == "background" ]]; then
        # # Override __besman_publish to skip publishing in background mode
        # function __besman_publish() {
        #     __besman_echo_yellow "Skipping publish step in background mode."
        #     return 0
        # }
        [[ "$BESMAN_SKIP_PUBLISH_IN_BACKGROUND" == "true" ]] && __besman_echo_warn "Skipping publish step as BESMAN_SKIP_PUBLISH_IN_BACKGROUND is set."
        local base_name="${playbook_name}-${BESMAN_ARTIFACT_NAME}-${BESMAN_ARTIFACT_VERSION}"
        local log_dir="$BESMAN_DIR/log"
        local pid_file="${log_dir}/${base_name}_assessment.pid"
        local log_file="${log_dir}/${base_name}_watcher.log"
        export BESMAN_PLAYBOOK_FILE="$playbook_file"
        
        mkdir -p "$log_dir"

        if [[ -f "$pid_file" ]]; then
            pid=$(<"$pid_file")
            if ps -p "$pid" > /dev/null 2>&1; then
                __besman_echo_warn "Assessment already running in background (PID: $pid)"
                __besman_echo_white "Check the logs under $log_file"
                return 0
            else
                __besman_echo_white "Stale PID file found. Removing."
                rm -f "$pid_file"
            fi
        fi
        set +m
        nohup bash -c '
            source "$BESMAN_DIR/bin/besman-init.sh"
            bes reload
            [[ -z $BESMAN_PLAYBOOK_FILE || ! -f $BESMAN_PLAYBOOK_FILE ]] && __besman_echo_red "Could not find playbook file" && exit 1
            source "$BESMAN_PLAYBOOK_FILE" || exit 1
            # Override publish in background mode
            if [[ "$BESMAN_SKIP_PUBLISH_IN_BACKGROUND" == "true" ]]; then
                __besman_echo_warn "Skipping publish step as BESMAN_SKIP_PUBLISH_IN_BACKGROUND is set."
                function __besman_publish() {
                    return 0
                }
            fi
            __besman_launch
            exit 0
        ' >"$log_file" 2>&1 &
        disown
        set -m
        echo "$!" > "$pid_file"
        __besman_echo_green "Assessment started in background (PID: $!)"
        __besman_echo_white "Check the logs under $log_file"
        __besman_echo_no_colour ""
        __besman_echo_warn "Make sure you have configured your git credentials locally for a seamless completion of assessments."
    else
        __besman_launch
        [[ "$?" -eq 0 ]] && __besman_echo_green "Done."
    fi

    unset playbook_name playbook_version playbook_file
}
