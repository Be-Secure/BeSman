#!/usr/bin/env bash

function __bes_help {    
__besman_echo_white 'NAME'
__besman_echo_no_colour '   bes - The cli for BeSman  '
__besman_echo_no_colour '  '
__besman_echo_white 'SYNOPSIS  '
__besman_echo_no_colour '   bes [command] [options] [ [environment name] | [playbook name] | [version] ] '
__besman_echo_no_colour '  '
__besman_echo_white 'DESCRIPTION'
__besman_echo_no_colour '   BeSman (pronounced as ‘B-e-S-man’) is a command-line utility designed for creating and provisioning customized security environments.'
__besman_echo_no_colour '   It helps security professionals to reduce the turn around time for assessment of Open Source projects, AI Models, Model Datasets'
__besman_echo_no_colour '   leaving them focus on the assessment task rather than setting up environment for it.'
__besman_echo_no_colour '   BeSman also provides seamless support for creating and executing BeS playbooks, enabling users to automate complex workflows and tasks.' 
__besman_echo_no_colour '   With BeSman, users can efficiently manage and execute playbooks, streamlining their processes and enhancing productivity.'
__besman_echo_no_colour '  '
__besman_echo_white ' COMMANDS '
__besman_echo_no_colour '   help: Display the help command '
__besman_echo_no_colour '   list: List available environments, playbooks, roles. '
__besman_echo_no_colour '   install: Install available environments. '
__besman_echo_no_colour '   uninstall: Uninstall the installed environment. '
__besman_echo_no_colour '   update: Update the configurations of the installed environment. '
__besman_echo_no_colour '   validate: Validate the installtion of the environment. '
__besman_echo_no_colour '   reset: Reset the environment to default configurations. '
__besman_echo_no_colour '   create: Create environment script. '
__besman_echo_no_colour '   set: Change the BeSman config variables. '
__besman_echo_no_colour '   pull: Fetches the playbook from remote to local. '
__besman_echo_no_colour '   run: Execute available playbooks. '
__besman_echo_no_colour '   upgrade: Upgrade BeSman to the latest version '
__besman_echo_no_colour '   rm | remove: Remove BeSman from machine. '
__besman_echo_no_colour '  '
__besman_echo_white ' OPTIONS '
__besman_echo_no_colour '   -env | --environment: For passing the name of the environment script. '
__besman_echo_no_colour '   -V | --version: For passing the version number. '
__besman_echo_no_colour '   -P | --playbook: For passing the playbook name '
__besman_echo_no_colour '   --roles: To list the role names '
}
