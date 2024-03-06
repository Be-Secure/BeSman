![BeSman](./BeSman-logo-horizontal.png)

BeSman (pronounced as ‘B-e-S-man’) is a command-line utility designed for provisioning customized security environments. It helps security professionals streamline the project setup phase, enabling them to focus on their specific tasks.

BeSman can also be used to run [BeS playbooks](https://github.com/Be-Secure/besecure-playbooks-store).

# What is an environment script

An environment script is a script which contains the instructions to install all the tools and utilities required for a security professional to work on a specific project. The BeS environment scripts are stored in this [repo](https://github.com/Be-Secure/besecure-ce-env-repo).

Each environment script contains the following life cycle functions -

- **install**: Installs the required tools.
- **uninstall**: Removes the installed tools.
- **validate**: Checks whether all the tools are installed and required configurations are met.
- **update**: Update configurations of the tools.
- **reset**: Reset the environment to the default state.

There are two types of enviornment script - **Red Team(RT) environment script** & **Blue Team(RT) environment script**

## RT env

The RT env would contain the instruction to install/manage the tools required for a security professional to perform RT activities on a project such as vulnerability assessment and exploit creation.

## BT env

The RT env would contain the instruction to install/manage the tools required for a security professional to perform BT activities such as vulnerability remediation and patching.

# What is a BeS Playbook

A playbook in Be-Secure ecosystem refers to a set of instructions for completing a routine task. Not to be confused with an Ansible playbook. There can be automated(.sh), interactive(.ipynb) & manual(\*.md) playbooks. It helps the security analyst who works in a BeSLab instance to carry out routine tasks in a consistent way.

The playbooks are stored in this [repo](https://github.com/Be-Secure/besecure-playbooks-store).

Each playbook file contains the following lifecycle functions,

- **init**: Initializes variables and other configuraitons to perform the activity and publish the report.
- **execute**: Performs the intended activity.
- **prepare**: Filters data from detailed report to generate OSAR.
- **publish**: Publishes the detailed report as well as OSAR.
- **cleanup**: Does clean up of variables and files created during run time.
- **launch**: Trigger function which calls all the above functions.

The playbooks are stored in this [repo](https://github.com/Be-Secure/besecure-playbooks-store).

# Installation

## For Windows

BeSman only works with linux machines. So, if you are a windows user, you can use [oah-installer](https://github.com/be-secure/oah-installer), a component of [**OpenAppHack(OAH)**](https://openapphack.github.io/OAH/), to install [oah-shell](https://github.com/be-secure/oah-shell) in the local system and using it to bring up [oah-bes-vm](https://github.com/be-secure/oah-bes-vm) with BeSman installed.

### Pre-requisites

- <a href="https://www.virtualbox.org/" target="_blank">Virtual Box</a>
- <a href="https://www.vagrantup.com/" target="_blank">Vagrant</a>
- <a href="https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html" target="_blank">Ansible</a>
- <a href="https://gitforwindows.org/" target="_blank">Git Bash</a>

1.  Open your git bash

2.  Execute the below command to set the correct namespace

        export BES_NAMESPACE=Be-Secure

3.  Install oah-shell

    curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash

4.  Confirm the installation oah-shell by executing the below command which would list various oah commands

        oah

5.  Execute the below command to get the list of environments

        oah list

    Note: Make sure **oah-bes-vm** is listed. If not, execute step 2 and run the below command

         source ${OAH_DIR}/bin/oah-init

6.  Setup oah-bes-vm for BeSman by executing the below command.

        oah install -v oah-bes-vm

## For Linux

### Pre-requisites

- <a href="https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html" target="_blank">Ansible</a>
- <a href="https://github.com/cli/cli/blob/trunk/docs/install_linux.md" target="_blank">Github CLI</a>

1.  Download the latest binary

        curl -L https://raw.githubusercontent.com/Be-Secure/BeSman/dist/dist/get.besman.io | bash

2.  Source the files into memory

        source $HOME/.besman/bin/besman-init.sh

3.  Run the below command to confirm installation

        bes help

# Usage

## List all environments

        bes list

## Installing an environment:

        bes install -env <environment name> -V <Version>

        Eg: $ bes install -env fastjson-BT-env -V 0.0.1

## Uninstalling an environment:

        $ bes uninstall -env <environment name> -V <version>

        Eg: $ bes uninstall -env  fastjson-RT-env -V 0.0.1

## Other commands

You can get the other command from the BeSman [webpage](https://be-secure.github.io/Be-Secure/bes-besman-details/)
