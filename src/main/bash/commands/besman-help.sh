#!/usr/bin/env bash

function __bes_help {
cat << EOF
BeSman - Help 
---------------------------------------------------------
$ bes <command> <qualifer> 

<qualifier>   : environment, version, namespace

<command> 
 ----------------------------------------------------------
install       : $ bes install –env [namespace]/[repo name]/[environment name] -V [version]
		The command is used to install the specified
		environment.

		Eg: $ bes install -env Be-Secure/besecure-ce-env-repo/BeSman-dev-env –V 0.0.1

uninstall     : $ bes uninstall --environment [env_name]

						OR

			$ bes uninstall –env [env_name] -V [version]
		
		The command is used to uninstall the specified
		environment.
		
		Eg: $ bes uninstall –env BeSman

status        : $ bes status

		The command displays the installed environments.

list          : $ bes list

		The command lists the various environment that
		can be installed.
				
				OR
			  
		  : $ bes list --playbook
		
		Used to list the playbooks

upgrade       : $ bes upgrade

		Upgrades BeSman to next version available.

update        : $ bes update

		Updates the list file with lastest changes.
				
				OR
			  
		  : $ bes update -env [environment name]
		
		Update the environment.
		
version       : Version of BeSman Utility
		-------------------------
		$ bes --version or bes –V
		This command displays the version of BeSman
		installed on the host.
		Version of an Environment
		-------------------------
		$ bes -V -env [env_name]
		The command displays the version of the specified
		environment.
		Eg: $ bes -V -env greenlight

help          : $ bes help

		Displays the BeSman manual

remove 	      : $ bes rm

		Removes BeSman utility and installed environments 
		from the local system

create        : To create a playbook. The playbook will be named 
		based on the options passed within the command.

		$ bes create --playbook <options> <arguments>

		Options:

			-cve : To pass CVE details. 
					$ bes create --playbook -cve CVE-2018-2019
			-vuln : To pass the vulnerability category.
					$ bes create --playbook -vuln xss
			-env :	To pass the environment name.
					$ bes create --playbook -env drupal
			-ext : To pass the extension of the playbook.
					$ bes create --playbook -ext py

			NOTE: If any of the above values are not passed, default value "untitled" will be assigned in its place except for -ext. 
					If -ext is not passed, the default value will be "md".
		
		Eg: $ bes create --playbook -cve CVE-2018-2019 -vuln rce -env drupal -ext php

		
pull          : $ bes pull --playbook

		To pull down playbooks from Be-Secure playbook repository.

run 		  : $ bes run --playbook [playbook name] --input [input arguments]
		
		To run the playbook

EOF
}
