 <h2 align="center">Be-Secure[Community Edition]</h2>
   
<p> <center> <h4 align="center"> A secure environment provider for your tech mission </h4> </p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#BeSman">About The Project</a>     
    </li>
    <li>
      <a href="#Command-Line-Interface">Command Line Interface</a></li>
    <li><a href="#Prerequisite">Prerequisite</a></li>	  
    <li><a href="#Installation-and-commands">Installation and commands</a></li>
	       <ul>
        <li><a href="#Install-commands">Install commands</a></li>
	<li><a href="#Uninstall-commands">Uninstall commands</a></li>
        <li><a href="#Version-commands">Version commands</a></li>
       <li><a href="#Other-useful-commands">Other useful commands</a></li>	       
      </ul>
    <li><a href="#How-to-contribute">How to contribute</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT  -->
# About The Project 

BeSman or Be-Secure  Manager is a commandline Utility for provision of customized security environments and this utility comes under the Be-Secure project which is a an umbrella of open source security projects and utilities tracked by Wipro’s open source security team and its open source partner network.


<!-- GETTING STARTED -->
# Command Line Interface
BeSman, (Be-Secure manager) gives you the *bes* command on your shell. User can use these bes commands to automate the setting up of various development environments required for bes projects.
BeSman is a tool for providing secure environments for user. It provides a convenient command line interface for installing, removing and listing Environments. 
Please use bes help command to get bes commands
	
	bes help


# Prerequisite

Please use OAH commands to create Bes installed virtual machine. Use oah-installer to get oah environments/commands. 
[OpenAppHack (OAH) is built on top of opensource DevOps tools. OAH is a vendor neutral environment provisioning approach that enables rapid development and prototyping of open source solution.]

For more details about oah-installar, please visit [github page](https://github.com/Be-Secure/oah-installer/blob/master/README.md) and for oah shell info, use [readme](https://github.com/Be-Secure/oah-shell/blob/master/README.md) for the same.

oah-installer will help to install oah shell.  The oah shell will provide oah commands to spin up different oah virtual machines. The oah-bes-vm is one of the many virtual machine that can be spun up using oah shell. Both installer and shell comes under OAH initiatives. 


# Installation and commands  
Windows users should use Gitbash with mingw. 

i. Fetch and install the oah shell.
	curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash

ii. Install the VM using the oah command.
	oah install -v oah-bes-vm 
	
iii. Use VM which got created while installing oah-bes-vm to work with bes commands. 
 

### Local Installation

To install BeSman locally running against your local server, run the following commands:


	 source ~/.besman/bin/besman-init.sh


### Local environment commands

Run the following commands on the terminal to manage respective environments.

### Install commands:

         bes install -env [environment_name] -V [version_tag]

        Example   :
            bes install -env bes-ansibledev-env -V 0.0.1

Please run the following command to get the list of other environments and its versions.

	   	` bes list`



### Uninstall commands:

         bes uninstall -env [environment_name] -V [version]

        Example   :
            bes uninstall -env  bes-ansibledev-env -V 0.0.1


### Version commands:

     bes --version
     bes --version -env [environment_name]

 
### Other useful commands:        

         bes list
         bes status        
         bes help     


<!-- CONTRIBUTING -->
## How to contribute
Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch 
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request


