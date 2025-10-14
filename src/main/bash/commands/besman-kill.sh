#!/bin/bash
function __bes_kill() {
    local logDir="$BESMAN_DIR/log"

    if [[ $# -eq 0 ]]; then
        __besman_echo_error "No PID or 'all' specified."
        __besman_echo_white "Usage: __bes_kill <pid1> <pid2> ... | all"
        return 1
    fi

    if [[ "$1" == "all" ]]; then
        shopt -s nullglob
        local pidfiles=("$logDir"/*.pid)
        shopt -u nullglob

        if [[ ${#pidfiles[@]} -eq 0 ]]; then
            __besman_echo_warn "No .pid files found in $logDir"
            return 0
        fi

        for pidfile in "${pidfiles[@]}"; do
            local pid
            pid=$(<"$pidfile")
            local proc_name
            proc_name=$(basename "$pidfile" .pid)
            if [[ "$pid" =~ ^[0-9]+$ ]] && ps -p "$pid" > /dev/null 2>&1; then
                if kill "$pid"; then
                    __besman_echo_white "Killed process $proc_name (PID: $pid)"
                else
                    __besman_echo_error "Failed to kill $proc_name (PID: $pid)"
                fi
            else
                __besman_echo_warn "No running process for $proc_name (PID: $pid). Removing stale PID file."
            fi
            rm -f "$pidfile"
        done
    else
        for pid in "$@"; do
            if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
                __besman_echo_error "Invalid PID: $pid"
                continue
            fi
            # Find the corresponding .pid file
            local pidfile
            pidfile=$(grep -l "^$pid\$" "$logDir"/*.pid 2>/dev/null | head -n 1)
            if [[ -z "$pidfile" ]]; then
                __besman_echo_error "No process found for PID: $pid"
                return 1
            fi
            if ps -p "$pid" > /dev/null 2>&1; then
                if kill "$pid"; then
                    __besman_echo_white "Killed PID: $pid"
                else
                    __besman_echo_error "Failed to kill PID: $pid"
                fi
            else
                __besman_echo_warn "No running process for PID: $pid"
            fi
            [[ -n "$pidfile" ]] && rm -f "$pidfile"
        done
    fi
}