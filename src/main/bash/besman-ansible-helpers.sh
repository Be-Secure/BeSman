#!/bin/bash


function __besman_check_if_ansible_env_vars_exists
{
    if [[ -z $BESMAN_ANSIBLE_ROLES_PATH ]]; then

        cat <<EOF
Please use the below command to set the 
download path for ansible roles

    $ export BESMAN_ANSIBLE_ROLES_PATH=$HOME/<some_path>

EOF
        return 1
    fi

    if [[ -z $BESMAN_ANSIBLE_ROLES ]]; then

        cat <<EOF

Please use the below command to add the
roles you wish to install

    $ export BESMAN_ANSIBLE_ROLES=<namespace>/<repo_name>:<namespace>/<repo_name>:<namespace>/<repo_name>:....

EOF
        return 1
    fi    
}

function __besman_check_for_ansible
{
    if [[ -z $(which ansible) ]]; then
        __besman_echo_red "Ansible not found"
        return 1
    fi

}

function __besman_check_for_trigger_playbook
{
    local playbook=$1
    if [[ ! -f $playbook ]]; then
        echo "$playbook"
        return 1
    else
        return 0
    fi
}


function __besman_update_requirements_file
{
    local roles namespace repo_name github_url role

    github_url=https://github.com
    readarray -d ',' -t roles <<< "$BESMAN_ANSIBLE_ROLES"
    [[ ! -d $BESMAN_ANSIBLE_ROLES_PATH ]] && mkdir -p "$BESMAN_ANSIBLE_ROLES_PATH"
    [[ ! -f $BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml ]] && touch "$BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml" && echo "---" >> "$BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml"
    for role in "${roles[@]}"; do
        namespace=$(echo "$role" | cut -d "/" -f 1)
        repo_name=$(echo "$role" | cut -d "/" -f 2)
        if ! grep -wq "$github_url/$namespace/$repo_name" "$BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml"
        then
            echo "- src: $github_url/$namespace/$repo_name" >> "$BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml"
            continue
        else
            __besman_echo_no_colour "Ignoring role $github_url/$namespace/$repo_name as it is already present in requirements.yml"
        fi
    done
    unset roles namespace repo_name github_url role
}

function __besman_run_ansible_playbook_with_become
{
    local playbook=$1
    __besman_echo_white "Running $playbook"
    ansible-playbook "$playbook" --ask-become-pass
    unset playbook
}

function __besman_run_ansible_playbook_extra_vars
{
    local playbook vars
    if [[ ( -n $BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS ) && ($BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS == false) ]]; then
        export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false 
        __besman_echo_yellow "Not displaying skipped hosts"
        __besman_echo_yellow "If you wish to display them run the below command"
        __besman_echo_white "export BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS=true"
    elif [[ ( -n $BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS ) && ($BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS == true) ]]; then
        export BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS=true
        __besman_echo_yellow "Displaying skipped hosts"
        __besman_echo_yellow "If you wish to not display them run the below command"
        __besman_echo_white "export BESMAN_DISPLAY_SKIPPED_ANSIBLE_HOSTS=false"
    fi
    playbook=$1
    [[ ! -f $playbook ]] && __besman_echo_red "$playbook not found" && unset playbook vars && return 1
    vars=$2
    __besman_echo_white "Running $playbook with --extra-vars $vars"
    ansible-playbook "$playbook" --ask-become-pass --extra-vars "$vars"
    [[ "$?" -ne 0 ]] && return 1
    unset playbook vars
}

function __besman_create_roles_config_file()
{
    local env_config_file roles_config_file
    [[ -z $BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH ]] && __besman_echo_yellow "Skipping creation of roles config" && return 1
    [[ ! -d $BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH ]] && mkdir -p "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH"
    env_config_file=$BESMAN_ENV_CONFIG_FILE_PATH # BESMAN_ENV_CONFIG_FILE_PATH is set from env-helpers:__besman_source_env_params()
    roles_config_file=$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_NAME-roles-config.yml
    touch "$roles_config_file"
    echo "---" > "$roles_config_file"
    while read -r line; do
        [[ "$line" == "---" ]] && continue
        if echo "$line" | grep -qe "^BESMAN_"  # For only exporting env variables starting with BESMAN_
        then
          continue
        else
          echo "$line" >> "$roles_config_file"
        fi
    done < "$env_config_file"
}


function __besman_ansible_galaxy_install_roles_from_requirements
{
    __besman_echo_white "Installing ansible roles from $BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml under $BESMAN_ANSIBLE_ROLES_PATH"
    ansible-galaxy install -r "$BESMAN_DIR/tmp/$BESMAN_ARTIFACT_NAME/requirements.yaml" -p "$BESMAN_ANSIBLE_ROLES_PATH"
}

function __besman_create_ansible_playbook
{

    cat <<EOF >> "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
---
- name: Triggering roles
  hosts: localhost || all
  vars_files:
    - ./$BESMAN_ARTIFACT_NAME-roles-config.yml
  vars:
    - home_dir: lookup('env','HOME')
    - oah_command: '{{ bes_command }}'
  roles:
    
EOF

    readarray -d ',' -t roles <<< "$BESMAN_ANSIBLE_ROLES"
    for i in "${roles[@]}"; do
        repo_name=$(echo "$i" | cut -d "/" -f 2)
        [[ ! -d $BESMAN_ANSIBLE_ROLES_PATH/$repo_name ]]  && __besman_echo_white "$repo_name not found" && continue
        echo "      - $repo_name" >> "$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK"
    done

}
