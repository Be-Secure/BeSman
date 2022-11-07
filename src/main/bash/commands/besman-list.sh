#!/bin/bash

function __bes_list {

local playbook_flag=$1
local env

# For listing playbooks
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
    # For listing environments
    __besman_echo_no_colour "Available environments and their respective version numbers (* - local; ^ - remote)"
    __besman_echo_no_colour "-----------------------------------------------------------------------------------"
    
    sed -i '/^$/d' $BESMAN_DIR/var/list.txt
      
    while read line; 
    do 

        local arr=()
        arr=$(echo $line | sed 's/,/ /g')
        
        local list=""
        
        for i in ${arr[@]};
        do
        
            if echo $i | grep -q "env" # If i is env name.
            then
        
                list=$i
        
                local env=$(echo $i | cut -d "/" -f 3) # To get the name of the env. Removes namespace and repo name
        
            elif [[ -d $BESMAN_DIR/envs/besman-$env ]];  then

                if ls $BESMAN_DIR/envs/besman-$env | grep -q "$i" # Checks if version is listed under installed dir of env
                then
        
                    list="$list $i*" # * depicts local
        
                else
        
                    list="$list $i^" # ^ depicts remote
        
                fi
        
            else
        
                list="$list $i^" # Remote and env not installed
        
            fi

        done
        
        echo $list
        
    done < $BESMAN_DIR/var/list.txt


    __besman_echo_no_colour ""

    unset playbook_flag arr env list

fi
}