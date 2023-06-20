#!/bin/bash

function __bes_create
{
   
    # bes create --playbook cve vuln name ext  
    local type=$1 #stores the type of the input - playbook/environment
    local return_val 
    
    # Checks whether the $type is playbook or not
    if [[ $type == "--playbook" || $type == "-P" ]]; then
    
        # checks whether the user github id has been populated or not under $BESMAN_USER_NAMESPACE 
        __besman_check_github_id || return 1
        # checks whether the user has already logged in or not to gh tool
        __besman_gh_auth_status "$BESMAN_USER_NAMESPACE"
        return_val=$?
        # if return_val == 0 then the user is already logged in
        if [[ $return_val == "0" ]]; then
    
            __besman_echo_white "Already logged in as $BESMAN_USER_NAMESPACE"

        # if return_val !=0 then user is not logged in
        else

            __besman_echo_white "authenticating.."
            __besman_gh_auth || return 1 
        
        fi
        
        __besman_echo_white "forking"
        __besman_gh_fork "$BESMAN_NAMESPACE" "$BESMAN_PLAYBOOK_REPO" 
        
        [[ "$?" != "0" ]] && return 1        
        
        if [[ ! -d $HOME/$BESMAN_PLAYBOOK_REPO ]]; then
            __besman_echo_white "cloning"  
            __besman_gh_clone "$BESMAN_USER_NAMESPACE" "$BESMAN_PLAYBOOK_REPO" "$HOME/$BESMAN_PLAYBOOK_REPO"
            [[ "$?" != "0" ]] && return 1
        
        fi
        
        local flag=$2
        local purpose=$3
        local vuln=$4
        local env=$5
        local ext=$6
        
        [[ -z $ext ]] && ext="md"
        
        __besman_create_playbook "$purpose" "$vuln" "$env" "$ext" 

        

        unset vuln env ext target_path return_val purpose
    else
        # bes create -env fastjson-RT-env 
        # $1 would be the type - env/playbook
        local environment_name overwrite template_type env_file
        environment_name=$2
        template_type=$3
        env_file=$BESMAN_DIR/envs/besman-$environment_name.sh
        if [[ -f "$BESMAN_DIR/envs/besman-$environment_name.sh" ]]; then
            __besman_echo_yellow "File exists with the same name under $BESMAN_DIR/envs/"
            read -p "Do you wish to overwrite (y/n)?: " overwrite
            if [[ ( "$overwrite" == "" ) || ( "$overwrite" == "y" ) || ( "$overwrite" == "Y" ) ]]; then
                rm "$BESMAN_DIR/envs/besman-$environment_name.sh"
            else
                __besman_echo_yellow "Exiting..."
                return 1
            fi
        fi
        
        if [[ ( -n "$template_type" ) && ( "$template_type" == "basic" ) ]]; then

            __besman_create_env_basic "$environment_name" || return 1
        elif [[ -z "$template_type" ]]; then
            __besman_create_env_with_config "$environment_name" 

        fi

    fi
    __besman_update_list "$environment_name" 
    code "$env_file" 
}



function __besman_create_env_with_config()
{
    local environment_name roles env_file 
    environment_name=$1
    env_file="$BESMAN_DIR/envs/besman-$environment_name.sh"
    # if echo "$environment_name" | grep -q "BT" 
    # then
    #     roles=\$BESMAN_BT_ROLES
    # elif echo "$environment_name" | grep -q "RT" 
    # then
    #     roles=\$BESMAN_RT_ROLES

    # fi
    cat <<EOF > "$env_file"
#!/bin/bash

function __besman_install_$environment_name
{
    
    __besman_check_for_gh || return 1
    __besman_check_github_id || return 1
    __besman_check_for_ansible || return 1
    __besman_update_requirements_file
    __besman_ansible_galaxy_install_roles_from_requirements
    __besman_check_for_trigger_playbook "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=install role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    if [[ -d \$BESMAN_OSSP_CLONE_PATH ]]; then
        __besman_echo_white "The clone path already contains dir names \$BESMAN_OSSP"
    else
        __besman_gh_clone "\$BESMAN_ORG" "\$BESMAN_OSSP" "\$BESMAN_OSSP_CLONE_PATH"
    fi

}

function __besman_uninstall_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=remove role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    if [[ -d \$BESMAN_OSSP_CLONE_PATH ]]; then
        __besman_echo_white "Removing \$BESMAN_OSSP_CLONE_PATH..."
        rm -rf "\$BESMAN_OSSP_CLONE_PATH"
    else
        __besman_echo_yellow "Could not find dir \$BESMAN_OSSP_CLONE_PATH"
    fi
}

function __besman_update_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=update role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
}

function __besman_validate_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=validate role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
}

function __besman_reset_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_OSS_TRIGGER_PLAYBOOK_PATH/\$BESMAN_OSS_TRIGGER_PLAYBOOK" "bes_command=reset role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
}
EOF
    __besman_echo_white "Created env file $environment_name under $BESMAN_DIR/envs"

}

function __besman_create_env_basic
{
    local environment_name env_file
    environment_name=$1
    env_file=$BESMAN_DIR/envs/besman-$environment_name.sh
    [[ -f $env_file ]] && __besman_echo_red "Environment file exists" && return 1
    cat <<EOF >> "$env_file"
#!/bin/bash

function __besman_install_$environment_name
{

}

function __besman_uninstall_$environment_name
{
    
}

function __besman_update_$environment_name
{
    
}

function __besman_validate_$environment_name
{
    
}

function __besman_reset_$environment_name
{
    
}
EOF
__besman_echo_white "Creating env file.."
}

function __besman_update_list()
{
    local environment_name=$1
    if grep -qw "Local/Local/$environment_name,0.0.1" $BESMAN_DIR/var/list.txt
    then
        return 1
    else
        __besman_echo_white "Updating local list"
        echo "Local/Local/$environment_name,0.0.1" >> $BESMAN_DIR/var/list.txt
    fi
    
}


function __besman_create_playbook
{
    local args=("${@}")
    # checks whether any parameters are empty and if empty assign it as untitled.
    for (( i=0;i<${#};i++ ))
    do
        if [[ -z ${args[$i]}  ]]; then
            args[$i]="untitled"

        fi
    
    done
    
    local purpose=${args[0]} # CVE/assessment etc..
    local vuln=${args[1]}
    local env=${args[2]}
    local ext=${args[3]}
    # [[ -z $ext ]] && ext="md"
    local target_path=$HOME/$BESMAN_PLAYBOOK_REPO
    
    touch $target_path/besman-$purpose-$vuln-$env-playbook.$ext
    
    if [[ "$?" == "0" ]]; then
    
    __besman_echo_green "Playbook created successfully"
    
    else
    
    __besman_echo_red "Could not create playbook"
    
    fi
    
    # opens the created playbook in a jupyter notebook/vscode
    __besman_open_file $target_path
    
    unset args vuln env ext purpose
}   

