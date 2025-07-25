#!/usr/bin/env bash

function __bes_help {
    __besman_echo_no_colour '  '
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
    __besman_echo_no_colour '   attest: Attest the OSAR report '
    __besman_echo_no_colour '   verify: Verify the OSAR report attestation '
    __besman_echo_no_colour '   rm | remove: Remove BeSman from machine. '
    __besman_echo_no_colour '   status: Display the '
    __besman_echo_no_colour '               1. list of installed environments and its current version'
    __besman_echo_no_colour '               2. list of background processes'
    __besman_echo_no_colour '   reload: Reloads the configuration of the current environment '
    __besman_echo_no_colour '   config: Downloads the environment configuration'
    __besman_echo_no_colour '   kill: Kills the background process'
    __besman_echo_no_colour '  '
    __besman_echo_white ' OPTIONS '
    __besman_echo_no_colour '   -env | --environment: For passing the name of the environment script. '
    __besman_echo_no_colour '   -V | --version: For passing the version number. '
    __besman_echo_no_colour '   -P | --playbook: For passing the playbook name '
    __besman_echo_no_colour '   --role: To list the role names '
    __besman_echo_no_colour '   --file: Filename to be attested or verified '
    __besman_echo_no_colour '   --path: Path to the file to be attested or verified '
    __besman_echo_no_colour '   --background | -bg: For background process'
    __besman_echo_no_colour '  '
    __besman_echo_white 'For more details execute below command'
    __besman_echo_yellow '   $ bes help <command name>'
    __besman_echo_no_colour '   Choose command name from list of COMMANDS'
    __besman_echo_no_colour '  '
}

function __bes_help_install {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   install - To install available RT/BT environment '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '   $ bes install -env <environment> -V <version> '
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   The bes install command allows user to effortlessly set up the required environment for'
    __besman_echo_no_colour '   OSS project with just a few simple steps. By specifying the environment'
    __besman_echo_no_colour '   name and version, the command ensures that user system is equipped with'
    __besman_echo_no_colour '   all the necessary dependencies. It intelligently checks user system'
    __besman_echo_no_colour '   to see if the required dependencies are already installed and skips them'
    __besman_echo_no_colour '   if found, saving you valuable time. If a specific version is not available,'
    __besman_echo_no_colour '   it will seamlessly handle the installation process, including uninstalling'
    __besman_echo_no_colour '   any conflicting versions. With bes install, user can focus on OSS project RT/BT activity'
    __besman_echo_no_colour '   without worrying about complex setup procedures.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '  $ bes install -env fastjson-RT-env -V 0.0.2'
    __besman_echo_no_colour '  $ bes install -env zaproxy-BT-env -V 0.0.1'
    __besman_echo_no_colour '  '
}

function __bes_help_uninstall {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   uninstall - To uninstall an installed RT/BT environment. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '  $ bes uninstall -env <environment name>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   It efficiently removes all dependencies'
    __besman_echo_no_colour '   installed by the "bes install" command for a specific RT/BT environment.'
    __besman_echo_no_colour '   It provides a quick and effective way to clean up user system.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '  $ bes uninstall -env fastjson-RT-env'
    __besman_echo_no_colour '  $ bes uninstall -env zaproxy-BT-env'
    __besman_echo_no_colour '  '
}

function __bes_help_config {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   config - To download environment config file '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '  $ bes config -env <environment name> -V <version>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   This command can be used to download'
    __besman_echo_no_colour '   an environment configuration for making'
    __besman_echo_no_colour '   changes in environment configuration.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '  $ bes config -env fastjson-RT-env -V <version>'
    __besman_echo_no_colour '  '
}

function __bes_help_list {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   list - To list the available environments, playbooks and roles. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_no_colour '   Display list of Environments, Playbooks and Roles'
    __besman_echo_yellow '      $ bes list'
    __besman_echo_no_colour '  '
    __besman_echo_no_colour '   Display list of Playbooks'
    __besman_echo_yellow '      $ bes list [options]'
    __besman_echo_no_colour '  '
    __besman_echo_no_colour '[options]'
    __besman_echo_no_colour '-env | --environment      : List of available environments'
    __besman_echo_no_colour '-P | --playbook           : List of available playbooks'
    __besman_echo_no_colour '--role                     : List of available roles'

    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   It provides users with a comprehensive overview'
    __besman_echo_no_colour '   of all available environments, playbooks and roles from'
    __besman_echo_no_colour '   both remote repositories and local system.'
    __besman_echo_no_colour '   This functionality simplifies resource management and streamlines'
    __besman_echo_no_colour '   workflow by presenting a consolidated view of accessible resources.'
    __besman_echo_no_colour '  '
}

function __bes_help_status {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   status - To show the list of '
    __besman_echo_no_colour '              1. installed environments and its current version'
    __besman_echo_no_colour '              1. list of background processes and its status'
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes status [options]'
    __besman_echo_no_colour ''
    __besman_echo_no_colour '[options]'
    __besman_echo_no_colour '-------------'
    __besman_echo_no_colour '-env | --environment      : To get the list of installed environments'
    __besman_echo_no_colour '-bg | --background        : To get the list of background processes'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   Displays the list of installed environments'
    __besman_echo_no_colour '  '
}

function __bes_help_set {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   set - To set/change the BeSman config variables. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_no_colour '   Display list of the BeSman config variables'
    __besman_echo_yellow '      $ bes set '
    __besman_echo_no_colour '  Set BeSman config variable '
    __besman_echo_yellow '      $ bes set <variable> <value>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   To show the available list of BeSman config variables'
    __besman_echo_no_colour '   and set the BeSman config variables.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '  $ bes set BESMAN_NAMESPACE Be-Secure'
    __besman_echo_no_colour '   '

    __besman_echo_white "-----------------------------------------------------BESMAN CONFIG VARIABLES-------------------------------------------------------"
    printf "%-30s %-70s %-25s\n" "Variable" "Usage" "Expected Input"
    __besman_echo_white "-----------------------------------------------------------------------------------------------------------------------------------"

    printf "%-30s %-70s %-25s\n" "BESMAN_USER_NAMESPACE" "Namespace to clone repo during env scripts installation" "GitHub or GitLab namespace"
    printf "%-30s %-70s %-25s\n" "BESMAN_CODE_COLLAB_PLATFORM" "Name of the code collab platform" "github or gitlab"
    printf "%-30s %-70s %-25s\n" "BESMAN_CODE_COLLAB_URL" "URL of the code collab platform" "https://github.com or GitLab URL"
    printf "%-30s %-70s %-25s\n" "BESMAN_VCS" "Version control system used for repo management" "Git or GH"
    printf "%-30s %-70s %-25s\n" "BESMAN_NAMESPACE" "Namepace for BeS operations" "GitHub or GitLab namespace"
    printf "%-30s %-70s %-25s\n" "BESMAN_ENV_REPO" "Repo from which user install env scripts" "namespace/repo_name"
    printf "%-30s %-70s %-25s\n" "BESMAN_ENV_REPO_BRANCH" "Branch/tag of the repo from which user install env scripts" "branch_name or tag"
    printf "%-30s %-70s %-25s\n" "BESMAN_PLAYBOOK_REPO" "Repo from which user pull playbooks" "namespace/repo_name"
    printf "%-30s %-70s %-25s\n" "BESMAN_PLAYBOOK_REPO_BRANCH" "Branch/tag of the repo from which user pulls playbook" "branch_name or tag"
    printf "%-30s %-70s %-25s\n" "BESMAN_LOCAL_ENV_DIR" "Local env dir from which user can install env scripts" "complete path to dir"
    printf "%-30s %-70s %-25s\n" "BESMAN_LOCAL_ENV" "If value is true, env is installed from BESMAN_LOCAL_ENV_DIR" "true or false"
    printf "%-30s %-70s %-25s\n" "BESMAN_LOCAL_PLAYBOOK_DIR" "Local playbook dir from which user can run playbook" "complete path to dir"
    printf "%-30s %-70s %-25s\n" "BESMAN_LOCAL_PLAYBOOK" "If value is true, playbook is installed from BESMAN_LOCAL_PLAYBOOK_DIR" "true or false"
    printf "%-30s %-70s %-25s\n" "BESMAN_INSECURE_SSL" "If value is true, curl will not check for SSL certificate" "true or false"
    printf "%-30s %-70s %-25s\n" "BESMAN_CURL_CONNECT_TIMEOUT" "Timeout value for curl commands"
    printf "%-30s %-70s %-25s\n" "BESMAN_SKIP_PUBLISH_IN_BACKGROUND" "Skip publish step in background mode" "true or false"

    __besman_echo_white "-----------------------------------------------------------------------------------------------------------------------------------"
}
function __bes_help_create {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   create - To create environment script. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_no_colour '   For environments which relies on ansible role '
    __besman_echo_yellow '      $ bes create -env <environment> -V <version>'
    __besman_echo_no_colour '  '
    __besman_echo_no_colour '   For environments with only the skeletal code '
    __besman_echo_yellow '      $ bes create -env <environment> -V <version> basic '
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   It creates environment scripts.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '  bes create -env fastjson-RT-env -V  0.0.3'
    __besman_echo_no_colour '  bes create -env fastjson-RT-env -V 0.0.3 basic'
    __besman_echo_no_colour '  '
}

function __bes_help_upgrade {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   upgrade - Upgrades BeSman to the latest version '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes upgrade'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   It upgrades BeSman to the latest version.'
    __besman_echo_no_colour '  '
}

function __bes_help_help {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   help - Displays the BeSman help command. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '      $ bes help'
    __besman_echo_no_colour 'Display help for specific command - '
    __besman_echo_yellow '      $ bes help <command name>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   It displays the description of BeSman, details and list of BeSman commands.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '  $ bes help install'
    __besman_echo_no_colour '  $ bes help list'
    __besman_echo_no_colour '  '
}

function __bes_help_version {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   version - Displays the version of BeSman utility. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes -V'
    __besman_echo_yellow '    $ bes --version'
    __besman_echo_no_colour '  '
}

function __bes_help_remove {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   remove - To uninstall the BeSman utility '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes rm'
    __besman_echo_yellow '    $ bes remove'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   It uninstall the BeSman utility from user system.'
    __besman_echo_no_colour '  '
}

function __bes_help_run {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   run - To execute a playbook '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes run --playbook <playbook name> -V <playbook version> [option]'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   Used to execute available playbooks in user system.'
    __besman_echo_no_colour '  '
    __besman_echo_no_colour '[option]'
    __besman_echo_no_colour '-----------'
    __besman_echo_no_colour '-bg | --background        : Runs the playbook in the background.'
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes run --playbook SBOM-spdxSbomGenerator -V 0.0.1'
    __besman_echo_no_colour '  '
}

function __bes_help_attest {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   attest - To attest the OSAR report '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes attest --file <OSAR file name> --path <Directory path containing OSAR file>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   Used to attest and create the key and signature file for OSAR report.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'ARGUMENTS  '
    __besman_echo_no_colour '   --file (Required) Name of the OSAR file'
    __besman_echo_no_colour '   --path (Optional) Absolute directory path containing OSAR file.'
    __besman_echo_no_colour '      If not provided file is expected to be present in current working directory.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes attest --file fastjson-1.2.24-osar.json'
    __besman_echo_no_colour '   bes attest --file fastjson-1.2.24-osar.json --path /opt/besecure-assessment-datastore/fastjson/1.2.24/'
    __besman_echo_no_colour '  '
}

function __bes_help_verify {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   verify - To verify the OSAR report attestation '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes verify --file <OSAR file name> --path <Directory path containing OSAR,Key,signature and bundle files.>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   Used to verify the attestation of OSAR report.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'ARGUMENTS  '
    __besman_echo_no_colour '   --file (Required) Name of the OSAR file.'
    __besman_echo_no_colour '   --path (Optional) Absolute path for the directory containing OSAR file along with key and bundle files.'
    __besman_echo_no_colour '      If not provided files are expected to be present in current working directory.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes verify --file fastjson-1.2.24-osar.json'
    __besman_echo_no_colour '   bes verify --file fastjson-1.2.24-osar.json --path /opt/besecure-assessment-datastore/fastjson/1.2.24/'
    __besman_echo_no_colour '  '
}

function __bes_help_validate {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   validate - To Validate the installtion of an environment. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes validate -env <environment name>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'DESCRIPTION'
    __besman_echo_no_colour '   Used to validate the installtion of an environment in user system.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes validate -env fastjson-RT-env'
    __besman_echo_no_colour '  '
}

function __bes_help_update {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   update - Update the configurations of the installed environment. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes update -env <environment name>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes update -env fastjson-RT-env'
    __besman_echo_no_colour '  '
}

function __bes_help_reset {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   reset - Reset the environment to default configurations. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes reset -env <environment name>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes reset -env fastjson-RT-env'
    __besman_echo_no_colour '  '
}

function __bes_help_pull {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   pull - Fetches the playbook from remote to local. '
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes pull --playbook <playbook name> -V <playbook version>'
    __besman_echo_no_colour '  '
    __besman_echo_white 'EXAMPLE'
    __besman_echo_no_colour '   bes pull --playbook SBOM-spdxSbomGenerator -V 0.0.1'
    __besman_echo_no_colour '  '
}

function __bes_help_reload() {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   reload - Reloads the configuration of the current environment.'
    __besman_echo_no_colour '            Useful when using a common environment for multiple artifacts.'
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes reload'
    __besman_echo_no_colour '  '
}

function __bes_help_kill() {
    __besman_echo_no_colour '  '
    __besman_echo_white 'NAME'
    __besman_echo_no_colour '   kill - Kills the background process'
    __besman_echo_no_colour ''
    __besman_echo_no_colour '  '
    __besman_echo_white 'SYNOPSIS  '
    __besman_echo_yellow '    $ bes kill [option] | [PID]'
    __besman_echo_no_colour '  '
    __besman_echo_no_colour '[option]'
    __besman_echo_no_colour '----------  '
    __besman_echo_no_colour 'all        - Kills all the background processes'
    __besman_echo_no_colour '  '
}
