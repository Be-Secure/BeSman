#!/usr/bin/env bash

function __bes_help {
cat << EOF
BeSman - Help 
---------------------------------------------------------
$ bes <command> <qualifer> 
<qualifier>   : environment, version, namespace
<command> 
 ----------------------------------------------------------
install       : $ bes install –env [env_name] -V [version]
		The command is used to install the specified
		environment.
		Eg: $ bes install -env BeSman –V 0.0.2
uninstall     : $ bes uninstall --environment [env_name]
		or
		$ bes uninstall –env [env_name] -V [version]
		The command is used to uninstall the specified
		environment.
		Eg: $ bes uninstall –env BeSman
status        : $ bes status
		The command displays the installed environments.
list          : $ bes list
		The command lists the various environment that
		can be installed.
upgrade       : $ bes upgrade
		Upgrades BeSman to next version available.
update        : $ bes update
		Updates the list file with lastest changes.
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
EOF
}
