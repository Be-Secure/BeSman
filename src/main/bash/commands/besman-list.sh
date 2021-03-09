#!/bin/bash

function __bes_list {

sed -i '/^$/d' $BESMAN_DIR/var/list.txt

__besman_echo_no_colour "Available environments and their respective version numbers"
__besman_echo_no_colour "---------------------------------------------------------------"
sed 's/,/ - /1' $BESMAN_DIR/var/list.txt
__besman_echo_no_colour ""
}