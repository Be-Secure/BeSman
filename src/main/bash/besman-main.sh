#!/usr/bin/env bash

function bes {
	[[ -z "$1" ]] && __bes_help && return 0

	function __besman_check_for_env_file
	{
		local environment=$1
		if [[ ! -f $BESMAN_DIR/envs/besman-$environment.sh ]]; then
			__besman_echo_red "Wrong Command Format"
			__besman_echo_red "Could not find file besman-$environment.sh"
			__besman_echo_white "Make sure you have given the correct environment name"
			__besman_echo_white "If the issue persists, re-install BESman and try again"
			return 1
		fi
	}

	function __besman_check_for_command_file
	{
		local command=$1
		if [[ ! -f $BESMAN_DIR/src/besman-$command.sh ]]; then
			__besman_echo_red "Could not find file besman-$environment.sh"
			__besman_echo_white "Make sure you have given the correct command name"		
			__besman_echo_white "If the issue persists, re-install BESman and try again"	
			return 1
		fi

	}

	opts=()
	args=()
	local command environment version
	while [[ -n "$1" ]]; do
		case "$1" in 
			rm | remove)
				command=remove
				args=("${args[@]}" "$1")
			;;
			-env | -V | --environment | --version)         opts=("${opts[@]}" "$1");; ## -env | -V 
        	*)          args=("${args[@]}" "$1");; ## command | env_name | version_tag
    	esac
    	shift
	done
	
	[[ ${#args[@]} -gt 3 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
	
	[[ ${#opts[@]} -gt 2 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
	if [[ -z $command && ("${opts[0]}" == "-V" || "${opts[0]}" == "--version") ]]; then
		command=version
		environment="${args[0]}" 
		local opt_environment="${opts[1]}"
	fi
	[[ -z $command ]] && command="${args[0]}"
	[[ -z $environment ]] && environment="${args[1]}"
	[[ -z $version ]] && version="${args[2]}"
	__besman_check_for_command_file $command || return 1
	if [[ -n $environment && $environment != "all" ]]; then
		__besman_check_for_env_file $environment || return 1
	fi
	case $command in 
		install)
			
			[[ ${#opts[@]} -eq 0 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			[[ ${#args[@]} -eq 0 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			if [[ -z $version && -n $BESMAN_VERSION ]]; then
				version=$BESMAN_VERSION
			fi
			[[ -z $version ]] && [[ -z $BESMAN_VERSION ]] && __besman_echo_red "Utility corrupted. Re-install BESman and try again" && return 1
			__besman_validate_environment $environment || return 1
			__besman_check_if_version_exists $environment $version || return 1
			__bes_$command $environment $version
			;;
		uninstall)
			[[ ${#opts[@]} -eq 0 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			[[ ${#args[@]} -eq 0 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			[[ $environment == "all" ]] && __bes_$command $environment && return 0
			if [[ -z $version && -f $BESMAN_DIR/envs/besman-$environment/current ]]; then
				version=($(cat $BESMAN_DIR/envs/besman-$environment/current))
			fi
			[[ -z $version ]] && [[ -d $BESMAN_DIR/envs/besman-$environment ]] && [[ ! -f $BESMAN_DIR/envs/besman-$environment/current ]] && __besman_echo_red "Utility corrupted. Re-install BESman and try again" && return 1
			__besman_check_parameter_present "$environment" "$version" || return 1
			__besman_validate_environment $environment || return 1
			__besman_check_if_version_exists $environment $version || return 1
			__bes_$command $environment $version
			;;
		help | list | status | update | upgrade | remove)
			[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
			[[ "${#opts[@]}" -ne 0 ]] && __besman_echo_red "Incorrect syntax" && return 1
			__bes_$command
			;;
		version)
			[[ ${#opts[@]} -eq 0 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			if [[ -n $opt_environment ]]; then
				__besman_validate_environment $environment || return 1
				__bes_$command $opt_environment $environment
			elif [[ -z $environment ]]; then
				__bes_$command
			fi
			;;
		*)
			__besman_echo_red "Unrecognized command: $command" && return 1
			;;
	esac
	unset environment version command args opts
	
}	
