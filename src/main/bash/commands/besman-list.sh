#!/bin/bash

function __bes_list {

local playbook_flag=$1
local env
if [[ ( -n $playbook_flag ) && ( -d $BESMAN_DIR/playbook ) ]]; then
    [[ -z $(ls $BESMAN_DIR/playbook | grep -v "README.md") ]] && __besman_echo_white "No playbook available" && return 1
    ls $BESMAN_DIR/playbook >> $HOME/temp.txt
    __besman_echo_no_colour "Available playbooks"
    __besman_echo_no_colour "-------------------"
    cat $HOME/temp.txt | grep -v "README.md"
    [[ -f $HOME/temp.txt ]] && rm $HOME/temp.txt
elif [[ ( -n $playbook_flag ) && ( ! -d $BESMAN_DIR/playbook ) ]]; then
    __besman_echo_white "No playbook available"

else
    __besman_echo_no_colour "Available environments and their respective version numbers"
    __besman_echo_no_colour "---------------------------------------------------------------"
    
    sed -i '/^$/d' $BESMAN_DIR/var/list.txt
      
    while read line; 
    do 

        env=$(echo $line | cut -d "," -f 1 | cut -d "/" -f 3)
        if [[ -f $BESMAN_DIR/envs/besman-$env.sh ]]; then

            echo "$line (local)" | sed 's/,/ - /1'
        
        else

            echo "$line (remote)" | sed 's/,/ - /1'

        fi
        
    done < $BESMAN_DIR/var/list.txt


    __besman_echo_no_colour ""

    unset playbook_flag

fi
}