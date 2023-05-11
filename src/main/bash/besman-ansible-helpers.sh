#!/bin/bash


function __besman_check_if_ansible_env_vars_exists
{
    if [[ -z $BESMAN_ANSIBLE_ROLE_PATH ]]; then

        cat <<EOF
Please use the below command to set the 
download path for ansible roles

    $ export BESMAN_ANSIBLE_ROLE_PATH=$HOME/<some_path>

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
        echo $playbook
        return 1
    else
        return 0
    fi
}


function __besman_update_requirements_file
{
    local roles namespace repo_name github_url

    github_url=https://github.com
    roles=$(echo $BESMAN_ANSIBLE_ROLES | sed 's/:/ /g')
    [[ ! -f $BESMAN_ANSIBLE_ROLE_PATH/requirements.yml ]] && touch $BESMAN_ANSIBLE_ROLE_PATH/requirements.yml && echo "---" >> $BESMAN_ANSIBLE_ROLE_PATH/requirements.yml 
    for i in "${roles[@]}"; do
        namespace=$(echo $i | cut -d "/" -f 1)
        repo_name=$(echo $i | cut -d "/" -f 2)
        if ! cat $BESMAN_ANSIBLE_ROLE_PATH/requirements.yml | grep -wq "$github_url/$namespace/$repo_name"
        then
            echo "- src: $github_url/$namespace/$repo_name" >> $BESMAN_ANSIBLE_ROLE_PATH/requirements.yml
            continue
        else
            __besman_echo_no_colour "Ignoring role $github_url/$namespace/$repo_name as it is already present in requirements.yml"
        fi
    done
    unset roles namespace repo_name github_url
}

function __besman_run_ansible_playbook_with_become
{
    local playbook=$1
    __besman_echo_white "Running $playbook"
    ansible-playbook $playbook --ask-become-pass
    unset playbook
}

function __besman_run_ansible_playbook_extra_vars
{
    local playbook vars
    playbook=$1
    [[ ! -f $playbook ]] && __besman_echo_red "$playbook not found" && unset playbook vars && return 1
    vars=$2
    __besman_echo_white "Running $playbook with --extra-vars $vars"
    ansible-playbook $playbook --ask-become-pass --extra-vars "$vars"
    [[ "$?" -ne 0 ]] && return 1
    unset playbook vars
}



function __besman_ansible_galaxy_install_roles_from_requirements
{
    __besman_echo_white "Installing ansible roles from $BESMAN_ANSIBLE_ROLE_PATH/requirements.yml under $BESMAN_ANSIBLE_ROLE_PATH"
    ansible-galaxy install -r "$BESMAN_ANSIBLE_ROLE_PATH"/requirements.yml -p "$BESMAN_ANSIBLE_ROLE_PATH"
}

function __besman_create_ansible_playbook
{
    local playbook=$1
    touch $playbook
    cat <<EOF >> $playbook
---
- name: Triggering roles
  hosts: localhost || all
  vars:
    - home_dir: lookup('env','HOME')
    - oah_command: '{{ bes_command }}'
    - role_path: '{{ role_path }}'
  roles:
    
EOF

    roles=$(echo $BESMAN_ANSIBLE_ROLES | sed 's/:/ /g')
    for i in "${roles[@]}"; do
        repo_name=$(echo "$i" | cut -d "/" -f 2)
        [[ ! -d $BESMAN_ANSIBLE_ROLE_PATH/$repo_name ]]  && __besman_echo_white "$repo_name not found" && continue
        echo "      - '{{ role_path }}/$repo_name'" >> "$playbook"
    done

}
