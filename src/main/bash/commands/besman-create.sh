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
        local environment_name overwrite template_type version ossp env_file_name 
        environment_name=$2
        version=$3
        template_type=$4
        [[ -z $version ]] && version="0.0.1"
        ossp=$(echo "$environment_name" | cut -d "-" -f 1)
        env_file_name="besman-$environment_name.sh"
        __besman_set_variables
        env_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/$env_file_name
        config_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/besman-$environment_name-config.yaml
        mkdir -p "$BESMAN_LOCAL_ENV_DIR/$ossp/$version"
        if [[ -f "$env_file_path" ]]; then
            __besman_echo_yellow "File exists with the same name under $env_file_path"
            read -rp "Do you wish to overwrite (y/n)?: " overwrite
            if [[ ( "$overwrite" == "" ) || ( "$overwrite" == "y" ) || ( "$overwrite" == "Y" ) ]]; then
                rm "$env_file_path"
            else
                __besman_echo_yellow "Exiting..."
                return 1
            fi
        fi
        
        if [[ ( -n "$template_type" ) && ( "$template_type" == "basic" ) ]]; then

            __besman_create_env_basic "$env_file_path" || return 1
            __besman_create_env_config_basic "$environment_name" "$version"
        elif [[ -z "$template_type" ]]; then
            __besman_create_env_with_config "$env_file_path" 
            __besman_create_env_config "$environment_name" "$version"

        fi

    fi
    __besman_update_env_dir_list "$environment_name" "$version"
    __besman_echo_no_colour ""
    __besman_open_file_vscode "$env_file_path" "$config_file_path" || return 1

    
}

function __besman_create_env_config_basic()
{
    {
    local environment_name config_file ossp_name env_type config_file_path version overwrite
    environment_name=$1
    version=$2
    ossp_name=$(echo "$environment_name" | cut -d "-" -f 1)
    env_type=$(echo "$environment_name" | cut -d "-" -f 2)
    config_file="besman-$ossp_name-$env_type-env-config.yaml"
    config_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/$config_file
    if [[ -f $config_file_path ]]; then
        __besman_echo_yellow "Config file $config_file exists under $BESMAN_LOCAL_ENV_DIR/$ossp/$version"
        read -rp " Do you wish to replace?(y/n): " overwrite
        if [[ ( "$overwrite" == "" ) || ( "$overwrite" == "y" ) || ( "$overwrite" == "Y" ) ]]; then
            rm "$config_file_path"
        else
            return 
        fi
    fi
    [[ ! -f $config_file_path ]] && touch "$config_file_path" && __besman_echo_yellow "Creating new config file $config_file_path"
    cat <<EOF > "$config_file_path"
---
# If you wish to update the default configuration values, copy this file and place it under your home dir, under the same name.
# These variables are used to drive the installation of the environment script.
# The variables that start with BESMAN_ are converted to environment vars.
# If you wish to add any other vars that should be used globally, add the var using the below format.
# BESMAN_<var name>: <value>
# If you are not using any particular value, remove it or comment it(#).
#*** - These variables should not be removed, nor left empty.
# BESMAN_ORG - used to mention where you should clone the repo from, default value is Be-Secure
BESMAN_ORG: Be-Secure #***

# BESMAN_ARTIFACT_TYPE - project/ml model/training dataset
BESMAN_ARTIFACT_TYPE: # project/ml model/training dataset #***

# BESMAN_ARTIFACT_NAME - name of the artifact under assessment.
BESMAN_ARTIFACT_NAME: $ossp_name #***

# BESMAN_ARTIFACT_VERSION - version of the artifact under assessment.
BESMAN_ARTIFACT_VERSION: #Enter the version of the artifact here. #***

# BESMAN_ARTIFACT_URL - Source code url of the artifact under assessment.
BESMAN_ARTIFACT_URL: https://github.com/Be-Secure/$ossp_name #***

#BESMAN_ENV_NAME - This variable stores the name of the environment file.
BESMAN_ENV_NAME: $environment_name #***

# BESMAN_ARTIFACT_DIR - The path where you wish to clone the source code of the artifact under assessment.
# If you wish to change the clone path, provide the complete path.
BESMAN_ARTIFACT_DIR: \$HOME/\$BESMAN_ARTIFACT_NAME #***

# BESMAN_TOOL_PATH - The path where we download the assessment and other required tools during installation.
BESMAN_TOOL_PATH: /opt #***

# BESMAN_LAB_OWNER_TYPE - Organization/lab/individual.
BESMAN_LAB_OWNER_TYPE: Organization #***

# BESMAN_LAB_OWNER_NAME - Name of the owner of the lab. Default is Be-Secure.
BESMAN_LAB_OWNER_NAME: Be-Secure #***

# BESMAN_ASSESSMENT_DATASTORE_DIR - This is the local dir where we store the assessment reports. Default is home.
BESMAN_ASSESSMENT_DATASTORE_DIR: \$HOME/besecure-assessment-datastore #***

# BESMAN_ASSESSMENT_DATASTORE_URL - The remote repo where we store the assessment reports.
BESMAN_ASSESSMENT_DATASTORE_URL: https://github.com/Be-Secure/besecure-assessment-datastore #***
EOF
}

}
function __besman_open_file_vscode() {
    if [[ -z $(which code) ]]; then
        return 1
    fi
    local env_file config_file response
    env_file=$1
    config_file=$2
    read -rp "Do you wish to open the files in vscode?(y/n): " response
    if [[ ( "$response" == "" ) || ( "$response" == "y" ) || ( "$response" == "Y" ) ]]; then

        __besman_echo_no_colour ""
        __besman_echo_white "Opening files in vscode"
        code "$env_file" "$config_file"
    else
        return 1
    fi
    
}
function __besman_set_variables()
{
    local path
    __bes_set "BESMAN_LOCAL_ENV" "true"
    [[ -n $BESMAN_LOCAL_ENV_DIR ]] && return 0
    while [[ ( -z $path ) || ( ! -d $path )  ]] 
    do
        read -rp "Enter the complete path to your local environment directory: " path
    done
    __bes_set "BESMAN_LOCAL_ENV_DIR" "$path"

}

function __besman_create_env_config()
{
    local environment_name config_file ossp_name env_type config_file_path version overwrite
    environment_name=$1
    version=$2
    ossp_name=$(echo "$environment_name" | cut -d "-" -f 1)
    env_type=$(echo "$environment_name" | cut -d "-" -f 2)
    config_file="besman-$ossp_name-$env_type-env-config.yaml"
    config_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/$config_file
    if [[ -f $config_file_path ]]; then
        __besman_echo_yellow "Config file $config_file exists under $BESMAN_LOCAL_ENV_DIR/$ossp/$version"
        read -rp " Do you wish to replace?(y/n): " overwrite
        if [[ ( "$overwrite" == "" ) || ( "$overwrite" == "y" ) || ( "$overwrite" == "Y" ) ]]; then
            rm "$config_file_path"
        else
            return 
        fi
    fi
    [[ ! -f $config_file_path ]] && touch "$config_file_path" && __besman_echo_yellow "Creating new config file $config_file_path"
    cat <<EOF > "$config_file_path"
---
# If you wish to update the default configuration values, copy this file and place it under your home dir, under the same name.
# These variables are used to drive the installation of the environment script.
# The variables that start with BESMAN_ are converted to environment vars.
# If you wish to add any other vars that should be used globally, add the var using the below format.
# BESMAN_<var name>: <value>
# If you are not using any particular value, remove it or comment it(#).
#*** - These variables should not be removed, nor left empty.
# BESMAN_ORG - used to mention where you should clone the repo from, default value is Be-Secure
BESMAN_ORG: Be-Secure #***

# BESMAN_ARTIFACT_TYPE - project/ml model/training dataset
BESMAN_ARTIFACT_TYPE: # project/ml model/training dataset #***

# BESMAN_ARTIFACT_NAME - name of the artifact under assessment.
BESMAN_ARTIFACT_NAME: $ossp_name #***

# BESMAN_ARTIFACT_VERSION - version of the artifact under assessment.
BESMAN_ARTIFACT_VERSION: #Enter the version of the artifact here. #***

# BESMAN_ARTIFACT_URL - Source code url of the artifact under assessment.
BESMAN_ARTIFACT_URL: https://github.com/Be-Secure/$ossp_name #***

#BESMAN_ENV_NAME - This variable stores the name of the environment file.
BESMAN_ENV_NAME: $environment_name #***

# BESMAN_ARTIFACT_DIR - The path where you wish to clone the source code of the artifact under assessment.
# If you wish to change the clone path, provide the complete path.
BESMAN_ARTIFACT_DIR: \$HOME/\$BESMAN_ARTIFACT_NAME #***

# BESMAN_TOOL_PATH - The path where we download the assessment and other required tools during installation.
BESMAN_TOOL_PATH: /opt #***

# BESMAN_LAB_OWNER_TYPE - Organization/lab/individual.
BESMAN_LAB_OWNER_TYPE: Organization #***

# BESMAN_LAB_OWNER_NAME - Name of the owner of the lab. Default is Be-Secure.
BESMAN_LAB_OWNER_NAME: Be-Secure #***

# BESMAN_ASSESSMENT_DATASTORE_DIR - This is the local dir where we store the assessment reports. Default is home.
BESMAN_ASSESSMENT_DATASTORE_DIR: \$HOME/besecure-assessment-datastore #***

# BESMAN_ASSESSMENT_DATASTORE_URL - The remote repo where we store the assessment reports.
BESMAN_ASSESSMENT_DATASTORE_URL: https://github.com/Be-Secure/besecure-assessment-datastore #***

# BESMAN_ANSIBLE_ROLES_PATH - The path where we download the ansible role of the assessment tools and other utilities
BESMAN_ANSIBLE_ROLES_PATH: \$BESMAN_DIR/tmp/\$BESMAN_ARTIFACT_NAME/roles #***

# BESMAN_ANSIBLE_ROLES - The list of tools you wish to install. The tools are installed using ansible roles.
# To get the list of ansible roles run 
#   $ bes list --role
BESMAN_ANSIBLE_ROLES: #add the roles here. format - <Github id>/<repo name>,<Github id>/<repo name>,<Github id>/<repo name>,... #***

# BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH - sets the path of the playbook with which we run the ansible roles.
# Default path is ~/.besman/tmp/<artifact name dir>/
BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH: \$BESMAN_DIR/tmp/\$BESMAN_ARTIFACT_NAME #***

#BESMAN_ARTIFACT_TRIGGER_PLAYBOOK - Name of the trigger playbook which runs the ansible roles.
BESMAN_ARTIFACT_TRIGGER_PLAYBOOK: besman-\$BESMAN_ARTIFACT_NAME-$env_type-trigger-playbook.yaml #***

# BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS - If the users likes to display all the skipped steps, set it to true.
# Default value is false
BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS: false #***


# The default values of the ansible roles will be present in their respective repos.
# You can go to https://github.com/Be-Secure/<repo of the ansible role>/blob/main/defaults/main.yml.
# If you wish to change the default values copy the variable from the https://github.com/Be-Secure/<repo of the ansible role>/blob/main/defaults/main.yml
# and paste it here and change the value.
# Format is <variable name>: <value> 
# Eg: openjdk_version: 11
EOF
}

function __besman_create_env_with_config()
{
    local env_file_path
    env_file_path=$1

    cat <<EOF > "$env_file_path"
#!/bin/bash

function __besman_install_$environment_name
{

    __besman_check_vcs_exist || return 1 # Checks if GitHub CLI is present or not.
    __besman_check_github_id || return 1 # checks whether the user github id has been populated or not under BESMAN_USER_NAMESPACE 
    __besman_check_for_ansible || return 1 # Checks if ansible is installed or not.
    __besman_create_roles_config_file
    
    # Requirements file is used to list the required ansible roles. The data for requirements file comes from BESMAN_ANSIBLE_ROLES env var.
    # This function updates the requirements file from BESMAN_ANSIBLE_ROLES env var.
    __besman_update_requirements_file 
    __besman_ansible_galaxy_install_roles_from_requirements # Downloads the ansible roles mentioned in BESMAN_ANSIBLE_ROLES to BESMAN_ANSIBLE_ROLES_PATH
    # This function checks for the playbook BESMAN_ARTIFACT_TRIGGER_PLAYBOOK under BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH.
    # The trigger playbook is used to run the ansible roles.
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook # Creates the trigger playbook if not present.
    # Runs the trigger playbook. We are also passing these variables - bes_command=install; role_path=\$BESMAN_ANSIBLE_ROLES_PATH
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=install role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Clones the source code repo.
    if [[ -d \$BESMAN_ARTIFACT_DIR ]]; then
        __besman_echo_white "The clone path already contains dir names \$BESMAN_ARTIFACT_NAME"
    else
        __besman_echo_white "Cloning source code repo from \$BESMAN_USER_NAMESPACE/\$BESMAN_ARTIFACT_NAME"
        __besman_repo_clone "\$BESMAN_USER_NAMESPACE" "\$BESMAN_ARTIFACT_NAME" "\$BESMAN_ARTIFACT_DIR" || return 1
        cd "\$BESMAN_ARTIFACT_DIR" && git checkout -b "$\BESMAN_ARTIFACT_VERSION"_tavoss 1.2.24
        cd "$\HOME"
    fi

    if [[ -d $\BESMAN_ASSESSMENT_DATASTORE_DIR ]] 
    then
        __besman_echo_white "Assessment datastore found at $\BESMAN_ASSESSMENT_DATASTORE_DIR"
    else
        __besman_echo_white "Cloning assessment datastore from $\BESMAN_USER_NAMESPACE/besecure-assessment-datastore"
        __besman_repo_clone "$\BESMAN_USER_NAMESPACE" "besecure-assessment-datastore" "$\BESMAN_ASSESSMENT_DATASTORE_DIR" || return 1

    fi
    # Please add the rest of the code here for installation
}

function __besman_uninstall_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=remove role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    if [[ -d \$BESMAN_ARTIFACT_DIR ]]; then
        __besman_echo_white "Removing \$BESMAN_ARTIFACT_DIR..."
        rm -rf "\$BESMAN_ARTIFACT_DIR"
    else
        __besman_echo_yellow "Could not find dir \$BESMAN_ARTIFACT_DIR"
    fi
    # Please add the rest of the code here for uninstallation

}

function __besman_update_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=update role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Please add the rest of the code here for update

}

function __besman_validate_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=validate role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Please add the rest of the code here for validate

}

function __besman_reset_$environment_name
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=reset role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Please add the rest of the code here for reset

}
EOF
    __besman_echo_white "Created env file $environment_name under $BESMAN_DIR/envs"

}

function __besman_create_env_basic
{
    local env_file_path
    env_file_path=$1
    [[ -f $env_file_path ]] && __besman_echo_red "Environment file exists" && return 1
    touch "$env_file_path"
    cat <<EOF > "$env_file_path"
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

function __besman_update_env_dir_list()
{
    local environment_name version
    environment_name=$1
    version=$2

    if grep -qw "Be-Secure/besecure-ce-env-repo/$environment_name,$version" "$BESMAN_LOCAL_ENV_DIR/list.txt"
    then
        return 1
    else
        __besman_echo_white "Updating local list"
        echo "Be-Secure/besecure-ce-env-repo/$environment_name,$version" >> "$BESMAN_LOCAL_ENV_DIR/list.txt"
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

