#!/bin/bash

function __besman_install_BeSman
{
	local environment_name="$1"
	
	local version_id="$2"
	if [[ -z $BESMAN_ENV_ROOT ]]; then
		export BESMAN_ENV_ROOT="$HOME/BeSman_env"
	fi
	
	if [[ ! -d $BESMAN_ENV_ROOT ]]; then
		__besman_create_fork "${environment_name}" || return 1
 		__besman_create_dev_environment "$environment_name" "$version_id" || return 1
		__besman_echo_violet "Dev environment for ${environment_name} created successfully"
	else
 		__besman_echo_white "Removing existing version "
		rm -rf $BESMAN_ENV_ROOT
		__besman_create_dev_environment  "$environment_name" "$version_id" || return 1
		__besman_echo_violet "Dev environment for ${environment_name} created successfully"
	fi

	

}

function __besman_create_dev_environment 
{
	
	local environment_name=$1
	local version_id=$2
	__besman_echo_white "Creating Dev environment for ${environment_name} under $BESMAN_ENV_ROOT/$environment_name"
	__besman_echo_white "from https://github.com/${BESMAN_USER_NAMESPACE}/${environment_name}"
	__besman_echo_white "version :${version_id} "
	mkdir -p $BESMAN_ENV_ROOT
	git clone -q https://github.com/$BESMAN_USER_NAMESPACE/${environment_name} $BESMAN_ENV_ROOT/$environment_name
	if [[ ! -d $BESMAN_ENV_ROOT || ! -d $BESMAN_ENV_ROOT/$environment_name ]]; then
		__besman_error_rollback $environment_name
		return 1
	fi
	# export BESMAN_ROOT_DIR="$HOME/${BESMAN_ENV_ROOT}"
	mkdir -p ${BESMAN_ENV_ROOT}/dependency
}

function __besman_uninstall_BeSman
{
	local environment=$1
	if [[ ! -d $BESMAN_ENV_ROOT/$environment ]]; then
		__besman_echo_no_colour "Could not find $BESMAN_ENV_ROOT/$environment"
		return 1
	fi
	__besman_echo_white "Removing dev environment for BeSman"
	# cd $BESMAN_ENV_ROOT/$environment
	git --git-dir=$BESMAN_ENV_ROOT/$environment/.git --work-tree=$BESMAN_ENV_ROOT/$environment status | grep -e "modified" -e "untracked"
	if [[ "$?" == "0" ]]; then
		__besman_echo_red "You have unsaved works"
		__besman_echo_red "Uninstalling will remove all of the work done"
		__besman_interactive_uninstall || return 1
		rm -rf $BESMAN_ENV_ROOT
	else
		rm -rf $BESMAN_ENV_ROOT
	fi
	unset BESMAN_ENV_ROOT

}

function __besman_validate_BeSman
{
	local environment=$1
	if [[ ! -d $BESMAN_ENV_ROOT/$environment ]]; then
		__besman_echo_no_colour "Could not find $BESMAN_ENV_ROOT/$environment"
		return 1
	fi

	[[ ! -d $BESMAN_ENV_ROOT/dependency ]] && __besman_echo_no_colour "Could not find $BESMAN_ENV_ROOT/dependency" && return 1

	

}

# function __besman_update_BeSman
# {
# 	##TODO:- add the code for updating BESman dev
# }

# function __besman_upgrade_BeSman
# {
# 	##TODO:- add the code for upgradation 
# }

# function __besman_start_BeSman
# {
# 	##Not Applicable
# }

# function __besman_stop_BeSman
# {
# 	##Not Applicable
# }
