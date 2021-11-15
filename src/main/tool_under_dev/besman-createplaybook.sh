#!/bin/bash

function __bes_createplaybook
{
    print_req || return 1
    sanity_cheks || return 1   
    clone_repo || return 1
    # playbook_name=$1
    # language=$2
    create_playbook || return 1
    open_playbook || return 1

}

function clone_repo
{
    __besman_create_fork $BESMAN_PLAYBOOK_REPO || return 1
    if [[ ! -d $HOME/$BESMAN_PLAYBOOK_REPO ]]; then
        git clone -q https://github.com/$BESMAN_USER_NAMESPACE/$BESMAN_PLAYBOOK_REPO $HOME/$BESMAN_PLAYBOOK_REPO
        if [[ "$?" != "0" ]]; then
            __besman_echo_red "Something went wrong."
            return 1

        fi
        __besman_echo_white "The Be-Secure playbook repository has been forked and cloned under $HOME/$BESMAN_PLAYBOOK_REPO."
    else
        __besman_echo_white "Folder $HOME/$BESMAN_PLAYBOOK_REPO already exist."
        return 0
    fi
}

function print_req
{
    __besman_echo_white "You need a GitHub account to perform this operation."
    __besman_echo_no_colour ""
    __besman_echo_white "Please make sure you have the same and the follwing values populated under $BESMAN_DIR/etc/user-config.cfg prior to the execution of this command."
    __besman_echo_no_colour ""
    __besman_echo_yellow "1.  BESMAN_USER_NAMESPACE"
    __besman_echo_no_colour ""
    __besman_echo_yellow "2.  BESMAN_USER_PLAYBOOK_REPO"
    __besman_echo_no_colour ""
    __besman_interactive_uninstall || return 1
    
}

function sanity_cheks
{
    if [[ ! -f $BESMAN_DIR/etc/user-config.cfg ]]; then
        
        __besman_echo_red "Could not find user-config file. Please re-install BeSman"
        __besman_echo_white "Exiting!!!"
        # source "$BESMAN_DIR/bin/besman-init.sh"
        return 1
    else
        return 0        
    fi

    # if [[ -z $BESMAN_USER_NAMESPACE ]]; then
        
    #     __besman_echo_red "Value empty for BESMAN_USER_NAMESPACE"
    #     __besman_echo_no_colour ""
    #     __besman_echo_no_colour "Please export your GitHub ID using the following command"
    #     __besman_echo_no_colour ""
    #     __besman_echo_no_colour ""
    #     __besman_echo_yellow "export BESMAN_USER_NAMESPACE=<namespace>"
    #     __besman_echo_no_colour ""
    #     __besman_echo_no_colour "eg: export BESMAN_USER_NAMESPACE=abc123"
    #     return 1
    # fi

    if [[ -z $BESMAN_PLAYBOOK_REPO ]]; then

        __besman_echo_red "Value empty for BESMAN_PLAYBOOK_REPO"
        __besman_echo_no_colour ""
        __besman_echo_no_colour "Please export your GitHub repo to which you wish to push your playbook using the following command"
        __besman_echo_no_colour ""
        __besman_echo_no_colour ""
        __besman_echo_yellow "$ export BESMAN_PLAYBOOK_REPO=<repo_name>"
        __besman_echo_no_colour ""
        __besman_echo_no_colour "eg:$ export BESMAN_PLAYBOOK_REPO=abc123"
        return 1

    fi
}

function create_playbook
{
    __besman_echo_white ""
    cat<<EOF
When prompted please enter the name of the playbook in the asked order.
The playbook name should be of the below format.
EOF
    __besman_echo_yellow "besman-cve_number-category_of_vulerability-env_name-playbook."
    __besman_echo_white "Eg:- besman-cve-2019-6339-rce-drupal-playbook"
    
    cat<<EOF
    
For part of the names that you don't know, press ENTER, when prompted 
and that part in the file name would be "untitled".
The default extension of the playbook will be ".txt".
You can rename the playbook file to change the extension.
    
EOF


    inputs=("cve_number" "vulnerability" "env_name")
    playbook_args=()

    for (( i=0; i<${#inputs[@]}; i++ ))
    do
        read -p "Enter ${inputs[i]}:" c
        # __besman_echo_no_colour "If you don't know the input value, press ENTER."
        if [[ -z $c ]]; then
            playbook_args=("${playbook_args[@]}" "")
        else
            playbook_args=("${playbook_args[@]}" "$c")        
        fi
    done

    for (( j=0; j<3 ;j++ ))
    do
        # echo ${args[$j]}
        if [[ -z ${playbook_args[$j]} ]]; then
            # playbook_args=("${playbook_args[$j]}" "untitled")
            playbook_args[$j]="untitled"
            # args=("${args[@]/${args[j]}/untitled}")
        fi
    done

    

    playbook_path=$HOME/$BESMAN_PLAYBOOK_REPO/besman-${playbook_args[0]}-${playbook_args[1]}-${playbook_args[2]}-playbook.txt 
    
    if [[ ! -f $playbook_path ]]; then
        __besman_echo_yellow "Creating playbook..."
        touch $playbook_path
        __besman_echo_green "The playbook has been created under $playbook_path"
    else
        __besman_echo_yellow "Playbook under the name besman-${playbook_args[0]}-${playbook_args[1]}-${playbook_args[2]}-playbook is already present."
        __besman_echo_white "Exiting!!!"
        return 1
    fi
    

}

function open_playbook
{
    __besman_echo_white "Please select an option from below interfaces to open the playbook"
    editor_list=("1.jupyter-lab" "2.vscode" "3.exit")
    for i in ${editor_list[@]}
    do
        echo $i
    done
    read -p "Enter the number here:" choice
    if [[ $choice == "1" || $choice == "jupyter-lab" || $choice == "1.jupyter-lab" ]]; then
        open_playbook_jupyter
    elif [[ $choice == "2" || $choice == "vscode" || $choice == "2.vscode" ]]; then
        open_playbook_code
    elif [[ $choice == "3" || $choice == "exit" || $choice == "3.exit" ]]; then
        return 1
    else
        __besman_echo_red "Invalid option"
        __besman_echo_white "Please try again"
        open_playbook
    fi

}

function open_playbook_jupyter
{
    __besman_echo_white "Opening playbook using Jupter-lab notebook"
    jupyter notebook $HOME/$BESMAN_PLAYBOOK_REPO/
    if [[ "$?" != "0" ]]; then
        __besman_echo_red "Opening playbook using Jupter notebook failed."
        __besman_echo_white "Please try selecting the vscode option for the same"
        open_playbook
    fi
}

function open_playbook_code
{
    __besman_echo_white "Opening playbook using Visual Studio Code"
    code $playbook_path
    if [[ "$?" != "0" ]]; then
        __besman_echo_red "Opening playbook using vscode failed."
        __besman_echo_white "Please try selecting the jupyter-lab option for the same"
        open_playbook
    fi
}