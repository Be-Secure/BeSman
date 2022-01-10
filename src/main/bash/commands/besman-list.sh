#!/bin/bash

function __bes_list {

if [[ -n $1 ]]; then
    ls $BESMAN_DIR/playbook >> $HOME/temp.txt
    __besman_echo_no_colour "Available playbooks"
    __besman_echo_no_colour "-------------------"
    cat $HOME/temp.txt | grep -v "README.md"
    [[ -f $HOME/temp.txt ]] && rm $HOME/temp.txt
else
sed -i '/^$/d' $BESMAN_DIR/var/list.txt
__besman_echo_no_colour "Available environments and their respective version numbers"
__besman_echo_no_colour "---------------------------------------------------------------"
sed 's/,/ - /1' $BESMAN_DIR/var/list.txt
__besman_echo_no_colour ""
# unset contents list_file 
fi
}