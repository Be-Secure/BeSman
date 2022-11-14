## Overview

BeSman or Be-Secure Manager is a command line utility for provisioning customized security environments. This utility comes under the Be-Secure project which is an umbrella  of open source security projects, tools, sandbox environments to perform security assessments and secure open source technology stacks.
<br>

## Installing BeSman using oah-shell

We will be using [oah-installer](https://github.com/be-secure/oah-installer), a component of [**OpenAppHack(OAH)**](https://openapphack.github.io/OAH/), to install [oah-shell](https://github.com/be-secure/oah-shell) in the local system and using it to bring up [oah-bes-vm](https://github.com/be-secure/oah-bes-vm) with BeSman installed.<br> OpenAppHack (OAH) is built on top of opensource DevOps tools. Its a vendor neutral environment provisioning approach that enables rapid development and prototyping of open source solution. For more details about oah-installar, please visit [github page](https://github.com/Be-Secure/oah-installer/blob/master/README.md) and for oah shell info, use [readme](https://github.com/Be-Secure/oah-shell/blob/master/README.md) for the same.
<br>



## Install using OAH

### Pre-requisites 

- <a href="https://www.virtualbox.org/" target="_blank">Virtual Box</a>
- <a href="https://www.vagrantup.com/" target="_blank">Vagrant</a>
- <a href="https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html" target="_blank">Ansible</a>

`NOTE: Use Gitbash with mingw, if the base OS is Windows`

1. Open your terminal 

2. Execute the below command to set the correct namespace

        export BES_NAMESPACE=be-secure

3. Install oah-shell

       curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash

4. Confirm the installation oah-shell by executing the below command which would list various oah commands

        oah

5. Execute the below command to get the list of environments 

        oah list

    Note: Make sure **oah-bes-vm** is listed. If not, execute step 2 and run the below command

         source ${OAH_DIR}/bin/oah-init

6. Setup oah-bes-vm for BeSman by executing the below command.

        oah install -v oah-bes-vm

## Install from source

1. Get the latest binary
    
		curl -L https://raw.githubusercontent.com/Be-Secure/BeSman/dist/dist/get.besman.io | bash

2. Source the files into memory
   
		source $HOME/.besman/bin/besman-init.sh

3. Run the below command to confirm installation

		bes help

## BeSman commands

Run the following commands on the terminal to manage respective environments.

### Installing an environment:

         bes install -env [namespace]/[repo name]/[environment_name] -V [version_tag]

        Example   :
            bes install -env Be-Secure/besecure-ce-env-repo/fastjson-RT-env -V 0.0.1


### Uninstalling an environment:

         bes uninstall -env [environment_name] -V [version]

        Example   :
            bes uninstall -env  fastjson-RT-env -V 0.0.1

 
### Other useful commands:        

        bes --version
        bes --version -env [environment name]
        bes list
        bes status
        bes help
        bes list
        bes pull --playbook
        bes run
        bes update              
        bes validate



oah-installer will help to install oah shell.  The oah shell will provide oah commands to spin up different oah virtual machines. The oah-bes-vm is one of the many virtual machine that can be spun up using oah shell. Both installer and shell comes under OAH initiatives. 

### Demo

<a href="https://vimeo.com/570839886/50aeb9d751" target="_blank">BeSman execution Demo</a>