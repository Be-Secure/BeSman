#!/bin/bash

function __bes_status {
    local flag="$1"

    show_background() {
        local logDir="$BESMAN_DIR/log"
        local found_any=0
        local white='\033[1;1m'
        local nocolour='\033[0m'
        local yellow='\033[1;33m'
        local green='\033[0;32m'
        local red='\033[0;31m'

        shopt -s nullglob
        local pidfiles=("$logDir"/*.pid)
        shopt -u nullglob

        if [[ ${#pidfiles[@]} -eq 0 ]]; then
            __besman_echo_white "No process is running in background"
            return 0
        fi
        printf "${yellow}%38s${nocolour}\n\n" "Background Processes"
        printf "${white}%-45s${nocolour} ${white}%-10s${nocolour} ${white}%-10s${nocolour}\n" "Process Name" "PID" "Status"
        __besman_echo_no_colour "-------------------------------------------------------------------------------"

        for pidfile in "${pidfiles[@]}"; do
            local pid
            pid=$(<"$pidfile")
            local proc_name
            proc_name=$(basename "$pidfile" .pid)
            local status status_colored
            if [[ "$pid" =~ ^[0-9]+$ ]] && ps -p "$pid" > /dev/null 2>&1; then
                status="${green}Active${nocolour}"
            else
                status="${red}Stale${nocolour}"
            fi
            printf "%-45s %-10s %-10b\n" "$proc_name" "$pid" "$status"
            found_any=1
        done

        if [[ $found_any -eq 0 ]]; then
            __besman_echo_white "No background process PID files found"
        fi
    }

    show_environments() {
        file=($(find $BESMAN_DIR/envs/ -type d -name "besman-*" -print))
        if [[ -z $file ]]; then
            __besman_echo_white "Please install an environment first"
            return 1
        fi
        for f in "${file[@]}"; do
            echo "${f##*/}" > $HOME/tmp1.txt
            n=$(sed 's/besman-//g' $HOME/tmp1.txt)
            if [[ ! -f $BESMAN_DIR/envs/besman-$n/current ]]; then
                __besman_echo_white "No current file found for $n"
                return 1
            fi
            rm $HOME/tmp1.txt
        done
        __besman_echo_white "Installed environments and their version"
        __besman_echo_white "---------------------------------------------"
        for f in "${file[@]}"; do
            echo "${f##*/}" > $HOME/tmp1.txt
            n=$(sed 's/besman-//g' $HOME/tmp1.txt)
            if [[ $n == $(cat $BESMAN_DIR/var/current) ]]; then
                echo "~" $n $(ls $BESMAN_DIR/envs/besman-$n | grep -v $(cat $BESMAN_DIR/envs/besman-$n/current)) $(cat $BESMAN_DIR/envs/besman-$n/current)"*" > $BESMAN_DIR/envs/besman-$n/tmp.txt
                sed 's/current//g' $BESMAN_DIR/envs/besman-$n/tmp.txt
            else
                echo $n $(ls $BESMAN_DIR/envs/besman-$n | grep -v $(cat $BESMAN_DIR/envs/besman-$n/current)) $(cat $BESMAN_DIR/envs/besman-$n/current)"*" > $BESMAN_DIR/envs/besman-$n/tmp.txt
                sed 's/current//g' $BESMAN_DIR/envs/besman-$n/tmp.txt
            fi
            rm $BESMAN_DIR/envs/besman-$n/tmp.txt 
            rm $HOME/tmp1.txt
        done

        unset n file f 
    }

    if [[ "$flag" == "-bg" || "$flag" == "--background" ]]; then
        show_background
    elif [[ "$flag" == "-env" || "$flag" == "--environment" ]]; then
        show_environments
    elif [[ -z "$flag" ]]; then
        show_background
        echo
        show_environments
    else
        __besman_echo_white "Usage: __bes_status [-bg|--background] | [-env|--environment]"
        return 1
    fi
}