#!/bin/bash

function __besman_ansible_playbook
{
    __besman_echo_white "Running $1"
    ansible-playbook $1 --ask-become-pass
}

function __besman_ansible_playbook_extra_vars
{
    __besman_echo_white "Running $1 with --extra-vars $2"
    ansible-playbook $1 --ask-become-pass --extra-vars "$2"
}

function __besman_ansible_galaxy_install_from_requirements
{
    __besman_echo_white "Installing ansible roles from $1/requirements.yml under $2"
    ansible-galaxy install -r $1/requirements.yml -p $2
}