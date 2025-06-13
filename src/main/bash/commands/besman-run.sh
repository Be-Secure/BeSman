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
    local flag=$?

    if [[ "$force_flag" == "-f" && $flag -eq 0 ]]; then
        local base_name="${ASSESSMENT_TOOL_NAME}-falcon-${ASSESSMENT_TOOL_TYPE// /_}"
        local log_dir="$BESMAN_DIR/log"

        local pid_file="${log_dir}/${base_name}_assessment.pid"
        local log_file="${log_dir}/${base_name}_watcher.log"

        export BESMAN_PLAYBOOK_FILE="$playbook_file"
        export BESMAN_DIR="$BESMAN_DIR"
        # 🔄 Start a background watcher process
        nohup bash -c '
            source "$BESMAN_DIR/bin/besman-init.sh"
            bes reload
            source "$BESMAN_PLAYBOOK_FILE" || exit 1

            pid_file="'"$pid_file"'"
            log_file="'"$log_file"'"

            echo "[Watcher] Looking for PID file: $pid_file" >> "$log_file"
            sleep 1

            if [[ -f "$pid_file" ]]; then
                pid=$(<"$pid_file")
                __besman_echo_yellow "Monitoring assessment in background (PID: $pid)" >> "$log_file"

                while ps -p "$pid" > /dev/null 2>&1; do
                    sleep 2
                done

                case "$playbook_name" in
                    LLMSecAutocomplete-cyberseceval)
                        if [[ -s "$BESMAN_RESULTS_PATH/autocomplete_stat.json" ]]; then
                            jq 'to_entries[0].value' "$BESMAN_RESULTS_PATH/autocomplete_stat.json" >"$BESMAN_RESULTS_PATH/autocomplete_stat.tmp.json"
                            mv "$BESMAN_RESULTS_PATH/autocomplete_stat.tmp.json" "$BESMAN_RESULTS_PATH/autocomplete_stat.json"
                        else
                            __besman_echo_red "[ERROR] autocomplete_stat.json is missing or empty."
                            export AUTOCOMPLETE_RESULT=1
                        fi
                        ;;

                    LLMSecCodeInterpreter-cyberseceval)
                        if [[ -s "$BESMAN_RESULTS_PATH/interpreter_stat.json" ]]; then
                            jq 'to_entries[0].value' "$BESMAN_RESULTS_PATH/interpreter_stat.json" >"$BESMAN_RESULTS_PATH/interpreter_stat.tmp.json"
                            mv "$BESMAN_RESULTS_PATH/interpreter_stat.tmp.json" "$BESMAN_RESULTS_PATH/interpreter_stat.json"
                            export CODE_INTERPRETER_RESULT=0
                        else
                            __besman_echo_red "[ERROR] interpreter_stat.json is missing or empty."
                            export CODE_INTERPRETER_RESULT=1
                        fi
                        ;;

                    LLMSecFalseRefusalRate-cyberseceval)
                        if [[ -s "$BESMAN_RESULTS_PATH/frr_stat.json" ]]; then
                            jq 'to_entries[0].value' "$BESMAN_RESULTS_PATH/frr_stat.json" >"$BESMAN_RESULTS_PATH/frr_stat.tmp.json"
                            mv "$BESMAN_RESULTS_PATH/frr_stat.tmp.json" "$BESMAN_RESULTS_PATH/frr_stat.json"
                            export FRR_RESULT=0
                        else
                            __besman_echo_red "[ERROR] frr_stat.json is missing or empty."
                            export FRR_RESULT=1
                        fi
                        ;;

                    LLMSecInstruct-cyberseceval)
                        if [[ -s "$BESMAN_RESULTS_PATH/instruct_stat.json" ]]; then
                            jq 'to_entries[0].value' "$BESMAN_RESULTS_PATH/instruct_stat.json" > "$BESMAN_RESULTS_PATH/instruct_stat.tmp.json"
                            mv "$BESMAN_RESULTS_PATH/instruct_stat.tmp.json" "$BESMAN_RESULTS_PATH/instruct_stat.json"
                            export INSTRUCT_RESULT=0
                        else
                            __besman_echo_red "[ERROR] instruct_stat.json is missing or empty."
                            export INSTRUCT_RESULT=1
                        fi
                        ;;

                    LLMSecPromptInjection-cyberseceval)
                        if [[ -s "$BESMAN_RESULTS_PATH/prompt_injection_stat.json" ]]; then
                            jq 'to_entries[0].value' "$BESMAN_RESULTS_PATH/prompt_injection_stat.json" >"$BESMAN_RESULTS_PATH/prompt_injection_stat.tmp.json" &&
                                mv "$BESMAN_RESULTS_PATH/prompt_injection_stat.tmp.json" "$BESMAN_RESULTS_PATH/prompt_injection_stat.json"
                        else
                            __besman_echo_red "[ERROR] prompt_injection_stat.json is missing or empty."
                            export AUTOCOMPLETE_RESULT=1
                        fi
                        ;;

                    LLMSecSpearPhishing-cyberseceval)
                        if [[ -s "$BESMAN_RESULTS_PATH/phishing_stats.json" ]]; then
                            jq 'to_entries[0].value' "$BESMAN_RESULTS_PATH/phishing_stats.json" >"$BESMAN_RESULTS_PATH/phishing_stats.tmp.json" \
                                && mv "$BESMAN_RESULTS_PATH/phishing_stats.tmp.json" "$BESMAN_RESULTS_PATH/phishing_stats.json"
                        else
                            __besman_echo_red "[ERROR] phishing_stats.json is missing or empty."
                            export AUTOCOMPLETE_RESULT=1
                        fi
                        ;;

                    LLMVulnScan-garak)
                        if [[ -f "$report_file" ]]; then
                            [[ -f "$DETAILED_REPORT_PATH" ]] && rm "$DETAILED_REPORT_PATH"
                            jq -n "reduce inputs as \$i ({}; \
                                if \$i.entry_type == \"eval\" then \
                                    .[\$i.probe | split(\".\")[0]] |= (. // {}) | \
                                    .[\$i.probe | split(\".\")[0]][(\$i.probe | split(\".\")[1])] |= (. // {}) | \
                                    .[\$i.probe | split(\".\")[0]][(\$i.probe | split(\".\")[1])][(\$i.detector | split(\".\")[-1])] = \$i \
                                else \
                                    . \
                                end)" "$report_file" > "$DETAILED_REPORT_PATH"
                            export GARAK_RESULT=0
                        else
                            __besman_echo_red "[ERROR] Garak report not found at $report_file"
                            export GARAK_RESULT=1
                            conda deactivate
                            return 1
                        fi
                        ;;

                    *)
                        __besman_echo_red "[ERROR] Unknown playbook: $playbook_name"
                        return 1
                        ;;
                esac

                __besman_echo_white "Assessment finished. Running post-assessment steps..." >> "$log_file"
                __besman_prepare >> "$log_file" 2>&1
                __besman_cleanup >> "$log_file" 2>&1
            else
                __besman_echo_red "[ERROR] PID file not found. Cannot monitor assessment." >> "$log_file"
                __besman_cleanup >> "$log_file" 2>&1
            fi
        ' >"$log_file" 2>&1 &

        disown

    else
        if [[ $flag -eq 0 ]]; then
            __besman_prepare
            __besman_publish
            __besman_cleanup
        fi
        __besman_cleanup
    fi
    [[ "$?" -eq 0 ]] && __besman_echo_green "Done."
    unset playbook_name playbook_version playbook_file
}
