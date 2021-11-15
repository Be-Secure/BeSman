#!/bin/bash

function __bes_list {

if [[ -n $1 ]]; then
    list_file=$BESMAN_DIR/var/playbook_list.txt
    contents=playbooks
else
    contents=environments
    list_file=$BESMAN_DIR/var/list.txt
fi
# [[ ( $1 == "--playbook" ) || ( $1 == "-P" ) ]] && cat $BESMAN_DIR/var/playbook_list.txt && return

sed -i '/^$/d' $list_file

__besman_echo_no_colour "Available $contents and their respective version numbers"
__besman_echo_no_colour "---------------------------------------------------------------"
sed 's/,/ - /1' $list_file
__besman_echo_no_colour ""
}