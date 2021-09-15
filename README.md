 # Be-Secure
   
### A secure environment provider for your tech mission

BeSman or Be-Secure Manager is a commandline Utility for provision of customized security environments and this utility comes under the Be-Secure project which is an umbrella project of open source security projects, tools, sandbox environments to perform security assessments and secure open source technology stacks.
<br><br>

## Prerequisite

Please use OAH commands to create Bes installed virtual machine. Use oah-installer to get oah environments/commands. 
[OpenAppHack (OAH) is built on top of opensource DevOps tools. OAH is a vendor neutral environment provisioning approach that enables rapid development and prototyping of open source solution.]

For more details about oah-installar, please visit [github page](https://github.com/Be-Secure/oah-installer/blob/master/README.md) and for oah shell info, use [readme](https://github.com/Be-Secure/oah-shell/blob/master/README.md) for the same.

<br><br>
## Installation
Windows users should use Gitbash with mingw. 

i. Fetch and install the oah shell.
	
	curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash

ii. Install the VM using the oah command.
	
	oah install -v oah-bes-vm 
	
iii. Use VM which got created while installing oah-bes-vm to work with bes commands. 
<br><br>
## BeSman commands

Run the following commands on the terminal to manage respective environments.

### Install commands:

         bes install -env [environment_name] -V [version_tag]

        Example   :
            bes install -env bes-ansibledev-env -V 0.0.1


### Uninstall commands:

         bes uninstall -env [environment_name] -V [version]

        Example   :
            bes uninstall -env  bes-ansibledev-env -V 0.0.1

 
### Other useful commands:        

	bes --version
	bes --version -env [environment name]
	bes list
	bes status
	bes help
	bes list


oah-installer will help to install oah shell.  The oah shell will provide oah commands to spin up different oah virtual machines. The oah-bes-vm is one of the many virtual machine that can be spun up using oah shell. Both installer and shell comes under OAH initiatives. 
