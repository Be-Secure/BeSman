![BeSman](./BeSman-logo-horizontal.png)

BeSman (pronounced as ‘B-e-S-man’) is a command-line utility designed for creating and provisioning customized security environments. It helps security professionals streamline the project setup phase, enabling them to focus on their specific tasks.

It also provides seamless support for creating and executing playbooks, enabling users to automate complex workflows and tasks. With BeSman, users can efficiently manage and execute playbooks, streamlining their processes and enhancing productivity.


# Key Features

1. Effortless Environment Script Creation: BeSman provides a command-line interface (CLI) for creating environment scripts. Users can easily define the required components, dependencies, configurations, and commands, simplifying the setup process.

2. Rapid Environment Execution: The utility allows users to execute environment scripts with a single command, automating the setup process and saving valuable time. It efficiently installs libraries, frameworks, databases, and other necessary tools, ensuring a fully functional environment.

3. Reusable Environment Scripts: BeSman promotes reusability by allowing users to define and manage reusable environment scripts. Users can create templates or modules that encapsulate common configurations, making it easy to replicate environments across different projects.

4. Customizable Environment Scripts: BeSman supports the use of environment variables, enabling users to define dynamic values that can be easily modified or shared. This flexibility allows for greater adaptability and customization of the environment setup.

5. Playbook Creation: BeSman offers a  command-line interface (CLI) for creating playbooks. Users can define a series of tasks, commands, or actions to be executed in a specific order, automating complex workflows.

6. Rapid Playbook Execution: BeSman allows users to execute playbooks with a single command. It automates the execution of tasks defined in the playbook, saving time and effort.

7. Integration with Environment Scripts: BeSman seamlessly integrates with environment scripts, allowing users to incorporate environment setup and configuration tasks within their playbooks. This ensures a streamlined workflow from environment setup to task execution.

8. Community-Driven Development: BeSman is an open source project that encourages community contributions and collaboration. Users can actively participate in its development, suggest improvements, and report issues, fostering a supportive and innovative ecosystem.  
 


# Key Concepts

- **Environment script**: An environment script is a script file that contains instructions for setting up and configuring the necessary tools, dependencies, and settings required for a specific software or project environment. It typically includes commands or directives to install/manage libraries, frameworks, databases, and other components needed to run the software or project successfully. Environment scripts automate the setup process, ensuring consistency and reproducibility across different environments or systems. They are commonly used in software development, testing, deployment, and other related tasks to streamline the environment setup and configuration
- Each environment script contain the following lifecycle functions,
  - **install**: Installs the required tools.
  - **uninstall**: Removes the installed tools.
  - **validate**: Checks whether all the tools are installed and required configurations are met.
  - **update**: Update configurations of the tools.
  - **reset**: Reset the environment to the default state.
- There are two types of environment script,
  - **RT env** : Stands for Red Team environment script. The env installs all the tools/utilities required for a security analyst to perform vulnerability assessment, create exploits etc.
  - **BT env** : Stand for Blue Team environment script. The env would contain the instruction to install the tools required for a security professional to perform BT activities such as vulnerability remediation and patching.
- The environment scripts are stored and maintained under [besecure-ce-env-repo](https://github.com/Be-Secure/besecure-ce-env-repo).
- **BeS Playbook** : A playbook in Be-Secure ecosystem refers to a set of instructions for completing a routine task. Not to be confused with an Ansible playbook. There can be automated(.sh), interactive(.ipynb) & manual(*.md) playbooks. It helps the security analyst who works in a BeSLab instance to carry out routine tasks in a consistent way. These playbooks are automated and are executed using the BeSman utility.
- Each playbook would contain the following lifecycle functions
  - **init**: Initializes variables and other configuraitons to perform the activity and publish the report.
  - **execute**: Performs the intended activity.
  - **prepare**: Filters data from detailed report to generate OSAR.
  - **publish**: Publishes the detailed report as well as OSAR.
  - **cleanup**: Does clean up of variables and files created during run time.
  - **launch**: Trigger function which calls all the above functions.
- The BeS Playbooks are stored and maintained under [besecure-playbooks-store](https://github.com/Be-Secure/besecure-playbooks-store).

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
