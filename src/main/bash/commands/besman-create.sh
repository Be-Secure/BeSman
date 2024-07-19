#!/bin/bash

function __bes_create {

    # bes create --playbook cve vuln name ext
    local type=$1 #stores the type of the input - playbook/environment
    local return_val

    trap "__besman_echo_red '\nUser interrupted';__besman_handle_interruption || return 1" SIGINT
    
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
        trap "__besman_echo_red '\nUser interrupted';__besman_handle_interruption || return 1" SIGINT

        # bes create -env fastjson-RT-env
        # $1 would be the type - env/playbook
        local environment_name overwrite template_type version ossp env_file_name
        environment_name=$2
        version=$3
        template_type=$4
        [[ -z $version ]] && version="0.0.1"
        if echo "$environment_name" | grep -qE 'RT|BT'; then
            ossp=$(echo "$environment_name" | sed -E 's/-(RT|BT)-env//')
        else
            ossp=$(echo "$environment_name" | cut -d "-" -f 1)

        fi
        env_file_name="besman-$environment_name.sh"
        __besman_set_variables || return 1
        env_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/$env_file_name
        config_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/besman-$environment_name-config.yaml
        mkdir -p "$BESMAN_LOCAL_ENV_DIR/$ossp/$version"
        if [[ -f "$env_file_path" ]]; then
            __besman_echo_yellow "File exists with the same name under $env_file_path"
            read -rp "Do you wish to overwrite (y/n)?: " overwrite
            if [[ ("$overwrite" == "") || ("$overwrite" == "y") || ("$overwrite" == "Y") ]]; then
                rm "$env_file_path"
            else
                __besman_echo_yellow "Exiting..."
                return 1
            fi
        fi

        if [[ (-n "$template_type") && ("$template_type" == "basic") ]]; then

            __besman_create_env_basic "$env_file_path" || return 1
            __besman_create_env_config_basic "$environment_name" "$version" || return 1
        elif [[ -z "$template_type" ]]; then
            __besman_create_env_with_config "$env_file_path"
            __besman_create_env_config "$environment_name" "$version" || return 1

        fi

    fi
    __besman_update_env_dir_list "$environment_name" "$version"
    __besman_echo_no_colour ""
    __besman_update_metadata "$environment_name" "$version" || return 1


    __besman_cleanup_tmp_files
    __besman_open_file_vscode "$env_file_path" "$config_file_path" || return 1

}

function __besman_cleanup_tmp_files()
{
    local files=("$BESMAN_DIR/tmp/playbook_details.txt" "$BESMAN_DIR/tmp/playbook_for_metadata.txt" "$BESMAN_DIR/tmp/author_details.txt")

    for file in "${files[@]}"
    do
        [[ -f "$file" ]] && rm "$file"
    done
}

function __besman_update_metadata()
{
    local environment=$1
    local env_version=$2
    local author_name
    local author_type
    local playbook_name
    local playbook_version
    local playbook_tmp_file="$BESMAN_DIR/tmp/playbook_details.txt"
    local playbook_for_metadata="$BESMAN_DIR/tmp/playbook_for_metadata.txt"
    local author_details="$BESMAN_DIR/tmp/author_details.txt"
    local script_file="$BESMAN_DIR/scripts/besman-generate-env-metadata.py"


    __besman_echo_white "Updating metadata..."

    [[ ! -f $script_file ]] && __besman_echo_red "Missing script $script_file" && return 1

    __besman_echo_yellow "Enter the author details"

    while true 
    do
        read -rp "Enter author name:" author_name

        if [[ -z $author_name ]] 
        then
            __besman_echo_red "You should enter a value!!!"
        elif [[ $(echo "$author_name" | wc -w) -ne 1 ]]
        then
            __besman_echo_red "Expecting the github/gitlab id of the user/lab/org without space"
        else

            break 
        fi
            
    done

    while true
    do
        read -rp "Enter author type(Lab/User/Organization):" author_type

        if [[  $author_type != "Lab" && $author_type != "User" && $author_type != "Organization" ]] 
        then
            __besman_echo_red "Incorrect value.\n"
            __besman_echo_white "Please use one from below"
            __besman_echo_yellow "\nLab/User/Organization\n"
        else
            echo "$author_name $author_type" >> "$author_details"
            break
        fi
        
    done
    
    __besman_get_playbook_details || return 1
    __besman_echo_yellow "\nChoose playbooks from the below list\n"
    __besman_print_playbook_details "$playbook_tmp_file"
    __besman_echo_no_colour ""
    while true 
    do
        while true 
        do
            read -rp "Enter playbook name from above:" playbook_name
            if [[ -z "$playbook_name" ]] 
            then
                __besman_echo_red "\nYou should enter a value\n"
            else
                break
            fi
        
        done

        while true
        do
            read -rp "Enter playbook version:" playbook_version
            if [[ -z $playbook_version ]] 
            then
                __besman_echo_red "\nYou should enter a value\n"
            else

                break
            fi
        
        done

        __besman_check_playbook_valid "$playbook_name" "$playbook_version"


        if [[ "$?" == "1" ]] 
        then
            __besman_echo_red "Playbook $(__besman_echo_yellow "$playbook_name") with version $(__besman_echo_yellow "$playbook_version") is not valid"
        else
            __besman_check_for_duplicate "$playbook_for_metadata" "$playbook_name" "$playbook_version"

            if [[ "$?" != "1" ]] 
            then
                echo "$playbook_name $playbook_version" >>  "$playbook_for_metadata"
            fi
        fi


        __besman_prompt_user_for_metadata "Do you wish to add another playbook?"

        if [[ "$?" == "1" ]] 
        then
            break
        else
            __besman_echo_yellow "\nChoose playbooks from the below list\n"
            __besman_print_playbook_details "$playbook_tmp_file"
            __besman_echo_no_colour ""
        fi

    done

    python3 "$script_file" --environment "$environment" --version "$env_version"

    if [[ "$?" != "0" ]] 
    then
        __besman_echo_red "Something went wront" 
        return 1
    fi
 
}



function __besman_check_for_duplicate()
{
    local file=$1
    local playbook_name=$2
    local playbook_version=$3

    # Checking for file and returning if it does not existing. Otherwise the grep down below will throw error.
    [[ ! -f "$file" ]] && return 2
    if grep -q "$playbook_name $playbook_version" "$file" 
    then
        __besman_echo_red "Playbook $(__besman_echo_yellow "$playbook_name") with version $(__besman_echo_yellow "$playbook_version") already added"
        return 1
    fi
}

function __besman_check_playbook_valid() {
    local playbook_name=$1
    local playbook_version=$2
    local playbook_tmp_file="$BESMAN_DIR/tmp/playbook_details.txt"
    local playbook_details

    if [[ ! -f $playbook_tmp_file ]]; then
        __besman_echo_red "Playbook details file not found: $playbook_tmp_file"
        return 1
    fi

    playbook_details=$(cut -d " " -f 1,2 "$playbook_tmp_file")

    if echo "$playbook_details" | grep -q "$playbook_name.*$playbook_version"; then
        return 0
    else
       return 1
    fi
}
function __besman_print_playbook_details()
{
    local playbook_tmp_file="$1"
    local playbook_details=$(cat $playbook_tmp_file | cut -d " " -f 1,2)

     printf "%-25s %-10s\n" "Name" "Version"
    __besman_echo_no_colour "--------------------------------"

    OLD_IFS=$IFS
    IFS=" "
      
    while read -r line; 
    do 
        # converted_line=$(echo "$line" | sed 's|,|/|g')
        read -r name version <<< "$line"
        printf "%-25s %-10s\n" "$name" "$version"
        
    done <<< $playbook_details
    IFS=$OLD_IFS

}

function __besman_prompt_user_for_metadata()
{
    local text=$1

    while true; do
        read -rp "$text (y/Y/n/N): " prompt
        case $prompt in
            [Yy]* )
                # Add your replacement logic here
                return 0
                ;;
            [Nn]* )
                return 1
                ;;
            * )
                __besman_echo_red "Invalid input. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

function __besman_create_env_config_basic() {
    {
        local environment_name config_file ossp_name env_type config_file_path version overwrite
        environment_name=$1
        version=$2
        ossp_name=$(echo "$environment_name" | sed -E 's/-(RT|BT)-env//')
        env_type=$(echo "$environment_name" | rev | cut -d "-" -f 2 | rev)
        config_file="besman-$ossp_name-$env_type-env-config.yaml"
        config_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/$config_file
        if [[ -f $config_file_path ]]; then
            __besman_echo_yellow "Config file $config_file exists under $BESMAN_LOCAL_ENV_DIR/$ossp/$version"
            read -rp " Do you wish to replace?(y/n): " overwrite
            if [[ ("$overwrite" == "") || ("$overwrite" == "y") || ("$overwrite" == "Y") ]]; then
                rm "$config_file_path"
            else
                return 2
            fi
        fi
        [[ ! -f $config_file_path ]] && touch "$config_file_path" && __besman_echo_yellow "Creating new config file $config_file_path"
        cat <<EOF >"$config_file_path"
---
# If you wish to update the default configuration values, copy this file and place it under your home dir, under the same name.
# These variables are used to drive the installation of the environment script.
# The variables that start with BESMAN_ are converted to environment vars.
# If you wish to add any other vars that should be used globally, add the var using the below format.
# BESMAN_<var name>: <value>
# If you are not using any particular value, remove it or comment it(#).
#*** - These variables should not be removed, nor left empty.

# project/model/training dataset
BESMAN_ARTIFACT_TYPE: #***

# BESMAN_ARTIFACT_NAME - name of the artifact under assessment.
BESMAN_ARTIFACT_NAME: $ossp_name #***

# Version of the artifact under assessment.
BESMAN_ARTIFACT_VERSION: #***

# Source code url of the artifact under assessment.
BESMAN_ARTIFACT_URL: https://github.com/Be-Secure/$ossp_name #***

# This variable stores the name of the environment file.
BESMAN_ENV_NAME: $environment_name #***

# The path where you wish to clone the source code of the artifact under assessment.
# If you wish to change the clone path, provide the complete path.
BESMAN_ARTIFACT_DIR: \$HOME/\$BESMAN_ARTIFACT_NAME #***

# The path where we download the assessment and other required tools during installation.
BESMAN_TOOL_PATH: /opt #***

# This variable indicates the individual's lab affiliation
BESMAN_LAB_TYPE: Organization #***

# Name of the lab. Default is Be-Secure. This variable indicates the individual's lab affiliation
BESMAN_LAB_NAME: Be-Secure #***

# This is the local dir where we store the assessment reports. Default is home.
BESMAN_ASSESSMENT_DATASTORE_DIR: \$HOME/besecure-assessment-datastore #***

# The remote repo where we store the assessment reports.
BESMAN_ASSESSMENT_DATASTORE_URL: https://github.com/Be-Secure/besecure-assessment-datastore #***

ASSESSMENT_STEP:
    - sbom
    - sast
    - scorecard
    - criticality_score

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
    if [[ ("$response" == "") || ("$response" == "y") || ("$response" == "Y") ]]; then

        __besman_echo_no_colour ""
        __besman_echo_white "Opening files in vscode"
        code "$env_file" "$config_file"
    else
        return 1
    fi

}
function __besman_set_variables() {
    local path
    __bes_set "BESMAN_LOCAL_ENV" "true"
    [[ -n $BESMAN_LOCAL_ENV_DIR ]] && return 0
    while [[ (-z $path) || (! -d $path) ]]; do
        read -rp "Enter the complete path to your local environment directory: " path
    done
    [[ -z $path ]] && __besman_echo_red "No path provided" && return 1
    __bes_set "BESMAN_LOCAL_ENV_DIR" "$path"

}

function __besman_create_env_config() {
    local environment_name config_file ossp_name env_type config_file_path version overwrite
    environment_name=$1
    version=$2
    ossp_name=$(echo "$environment_name" | sed -E 's/-(RT|BT)-env//')
    env_type=$(echo "$environment_name" | rev | cut -d "-" -f 2 | rev)
    config_file="besman-$ossp_name-$env_type-env-config.yaml"
    config_file_path=$BESMAN_LOCAL_ENV_DIR/$ossp/$version/$config_file
    if [[ -f $config_file_path ]]; then
        __besman_echo_yellow "Config file $config_file exists under $BESMAN_LOCAL_ENV_DIR/$ossp/$version"
        read -rp " Do you wish to replace?(y/n): " overwrite
        if [[ ("$overwrite" == "") || ("$overwrite" == "y") || ("$overwrite" == "Y") ]]; then
            rm "$config_file_path"
        else
            return 2
        fi
    fi
    [[ ! -f $config_file_path ]] && touch "$config_file_path" && __besman_echo_yellow "Creating new config file $config_file_path"
    cat <<EOF >"$config_file_path"
---
# If you wish to update the default configuration values, copy this file and place it under your home dir, under the same name.
# These variables are used to drive the installation of the environment script.
# The variables that start with BESMAN_ are converted to environment vars.
# If you wish to add any other vars that should be used globally, add the var using the below format.
# BESMAN_<var name>: <value>
# If you are not using any particular value, remove it or comment it(#).
#*** - These variables should not be removed, nor left empty.
# used to mention where you should clone the repo from, default value is Be-Secure
BESMAN_ORG: Be-Secure #***

# project/ml model/training dataset
BESMAN_ARTIFACT_TYPE: #***

# Name of the artifact under assessment.
BESMAN_ARTIFACT_NAME: $ossp_name #***

# Version of the artifact under assessment.
BESMAN_ARTIFACT_VERSION: #***

# Source code url of the artifact under assessment.
BESMAN_ARTIFACT_URL: https://github.com/Be-Secure/$ossp_name #***

# This variable stores the name of the environment file.
BESMAN_ENV_NAME: $environment_name #***

# The path where you wish to clone the source code of the artifact under assessment.
# If you wish to change the clone path, provide the complete path.
BESMAN_ARTIFACT_DIR: \$HOME/\$BESMAN_ARTIFACT_NAME #***

# The path where we download the assessment and other required tools during installation.
BESMAN_TOOL_PATH: /opt #***

# Organization/lab/individual.
BESMAN_LAB_TYPE: Organization #***

# Name of the owner of the lab. Default is Be-Secure.
BESMAN_LAB_NAME: Be-Secure #***

# This is the local dir where we store the assessment reports. Default is home.
BESMAN_ASSESSMENT_DATASTORE_DIR: \$HOME/besecure-assessment-datastore #***

# The remote repo where we store the assessment reports.
BESMAN_ASSESSMENT_DATASTORE_URL: https://github.com/Be-Secure/besecure-assessment-datastore #***

# The path where we download the ansible role of the assessment tools and other utilities
BESMAN_ANSIBLE_ROLES_PATH: \$BESMAN_DIR/tmp/\$BESMAN_ARTIFACT_NAME/roles #***

# The list of tools you wish to install. The tools are installed using ansible roles.
# To get the list of ansible roles run 
#   $ bes list --role
#add the roles here. format - <Github id>/<repo name>,<Github id>/<repo name>,<Github id>/<repo name>,... #***
BESMAN_ANSIBLE_ROLES: 

# sets the path of the playbook with which we run the ansible roles.
# Default path is ~/.besman/tmp/<artifact name dir>/
BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH: \$BESMAN_DIR/tmp/\$BESMAN_ARTIFACT_NAME #***

# Name of the trigger playbook which runs the ansible roles.
BESMAN_ARTIFACT_TRIGGER_PLAYBOOK: besman-\$BESMAN_ARTIFACT_NAME-$env_type-trigger-playbook.yaml #***

# If the users likes to display all the skipped steps, set it to true.
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

function __besman_create_env_with_config() {
    local env_file_path
    env_file_path=$1

    cat <<EOF >"$env_file_path"
#!/bin/bash

function __besman_install
{

    __besman_check_vcs_exist || return 1 # Checks if GitHub CLI is present or not.
    __besman_check_github_id || return 1 # checks whether the user github id has been populated or not under BESMAN_USER_NAMESPACE 
    __besman_check_for_ansible || return 1 # Checks if ansible is installed or not.
    __besman_create_roles_config_file # Creates the role config file with the parameters from env config
    
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
        cd "\$BESMAN_ARTIFACT_DIR" && git checkout -b "\$BESMAN_ARTIFACT_VERSION"_tavoss "\$BESMAN_ARTIFACT_VERSION"
        cd "\$HOME"
    fi

    if [[ -d \$BESMAN_ASSESSMENT_DATASTORE_DIR ]] 
    then
        __besman_echo_white "Assessment datastore found at \$BESMAN_ASSESSMENT_DATASTORE_DIR"
    else
        __besman_echo_white "Cloning assessment datastore from $\BESMAN_USER_NAMESPACE/besecure-assessment-datastore"
        __besman_repo_clone "\$BESMAN_USER_NAMESPACE" "besecure-assessment-datastore" "\$BESMAN_ASSESSMENT_DATASTORE_DIR" || return 1

    fi
    # Please add the rest of the code here for installation
}

function __besman_uninstall
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

function __besman_update
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=update role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Please add the rest of the code here for update

}

function __besman_validate
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=validate role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Please add the rest of the code here for validate

}

function __besman_reset
{
    __besman_check_for_trigger_playbook "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    [[ "\$?" -eq 1 ]] && __besman_create_ansible_playbook
    __besman_run_ansible_playbook_extra_vars "\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/\$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK" "bes_command=reset role_path=\$BESMAN_ANSIBLE_ROLES_PATH" || return 1
    # Please add the rest of the code here for reset

}
EOF
    __besman_echo_white "Created env file $environment_name under $env_file_path"

}

function __besman_create_env_basic {
    local env_file_path
    env_file_path=$1
    [[ -f $env_file_path ]] && __besman_echo_red "Environment file exists" && return 1
    touch "$env_file_path"
    cat <<EOF >"$env_file_path"
#!/bin/bash

function __besman_install
{

}

function __besman_uninstall
{
    
}

function __besman_update
{
    
}

function __besman_validate
{
    
}

function __besman_reset
{
    
}
EOF
    __besman_echo_white "Creating env file.."
}

function __besman_update_env_dir_list() {
    local environment_name version
    environment_name=$1
    version=$2

    if grep -qw "Be-Secure/besecure-ce-env-repo/$environment_name,$version" "$BESMAN_LOCAL_ENV_DIR/list.txt"; then
        return 1
    else
        __besman_echo_white "Updating local list"
        echo "Be-Secure/besecure-ce-env-repo/$environment_name,$version" >>"$BESMAN_LOCAL_ENV_DIR/list.txt"
    fi

}

function __besman_create_playbook {
    local args=("${@}")
    # checks whether any parameters are empty and if empty assign it as untitled.
    for ((i = 0; i < ${#}; i++)); do
        if [[ -z ${args[$i]} ]]; then
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
