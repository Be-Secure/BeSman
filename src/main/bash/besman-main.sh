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
		        __besman_echo_red "Wrong Command Format"
			__besman_echo_red "Could not find file besman-$environment.sh"
			__besman_echo_white "Make sure you have given the correct command name"		
			__besman_echo_white "If the issue persists, re-install BESman and try again"	
			return 1
		fi

	}

	opts=()
	args=()
	local command environment version assess_flag purpose type
	while [[ -n "$1" ]]; do
		case "$1" in 
			rm | remove)
				command=remove
				args=("${args[@]}" "$1")
			;;
			-env | -V | --environment | --version | --playbook | -P | -cve | -vuln | -ext | -assess)         opts=("${opts[@]}" "$1");; ## -env | -V 
        	*)          args=("${args[@]}" "$1");; ## command | env_name | version_tag
    	esac
    	shift
	done
	
	[[ ${#args[@]} -gt 6 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
	
	[[ ${#opts[@]} -gt 6 ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
	if [[ -z $command && ("${opts[0]}" == "-V" || "${opts[0]}" == "--version") ]]; then
		command=version
		environment="${args[0]}" 
		local opt_environment="${opts[1]}"
	fi
	# if [[ -z $command && ("${opts[0]}" == "-P" || "${opts[0]}" == "--playbook") ]]; then
	# command="${args[0]}"
	# environment="" 
	# local opt_environment="${opts[0]}"
	# fi
	[[ -z $command ]] && command="${args[0]}"
	if [[ ( ${opts[0]} != "--playbook" ) && ( ${opts[0]} != "-P" ) ]]; then
		[[ -z $environment ]] && environment="${args[1]}"
		[[ -z $version ]] && version="${args[2]}"
	fi
	__besman_check_for_command_file $command || return 1
	if [[ -n $environment && $environment != "all" ]]; then
		__besman_check_for_env_file $environment || return 1
	fi
	case $command in 
		install)
			
			[[ ( ${#opts[@]} -eq 0 || ${#opts[@]} -gt 2 ) ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			[[ ( ${#args[@]} -eq 0 || ${#args[@]} -gt 3 ) ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			if [[ -z $version && -n $BESMAN_VERSION ]]; then
				version=$BESMAN_VERSION
			fi
			[[ -z $version ]] && [[ -z $BESMAN_VERSION ]] && __besman_echo_red "Utility corrupted. Re-install BESman and try again" && return 1
			__besman_validate_environment $environment || return 1
			__besman_check_if_version_exists $environment $version || return 1
			__besman_validate_version_format $version || return 1
			__bes_$command $environment $version
			;;
		uninstall)
			[[ ( ${#opts[@]} -eq 0 || ${#opts[@]} -gt 2 ) ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			[[ ( ${#args[@]} -eq 0 || ${#args[@]} -gt 2 ) ]] && __besman_echo_red "Incorrect syntax" && __bes_help && return 1
			[[ $environment == "all" ]] && __bes_$command $environment && return 0
			if [[ -z $version && -f $BESMAN_DIR/envs/besman-$environment/current ]]; then
				version=($(cat $BESMAN_DIR/envs/besman-$environment/current))
			fi
			[[ -z $version ]] && [[ -d $BESMAN_DIR/envs/besman-$environment ]] && [[ ! -f $BESMAN_DIR/envs/besman-$environment/current ]] && __besman_echo_red "Utility corrupted. Re-install BESman and try again" && return 1
			__besman_check_parameter_present "$environment" "$version" || return 1
			__besman_validate_environment $environment || return 1
			__besman_check_if_version_exists $environment $version || return 1
			__besman_validate_version_format $version || return 1
			__bes_$command $environment $version
			;;
		help | status | upgrade | remove)
			[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
			[[ "${#opts[@]}" -ne 0 ]] && __besman_echo_red "Incorrect syntax" && return 1
			__bes_$command
			;;
		run)
			[[ "${#args[@]}" -ne 2 ]] && __besman_echo_red "Incorrect syntax" && return 1
			[[ "${#opts[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
			_bes_$command ${opts[0]}

			;;
		list)
			if [[ -z ${opts[0]} ]]; then
				
				[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
				[[ "${#opts[@]}" -ne 0 ]] && __besman_echo_red "Incorrect syntax" && return 1
				__bes_$command
			else
				[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
				[[ "${#opts[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
				__bes_$command ${opts[0]}
			fi
			;;
		update)
			if [[ -z $opt_environment ]]; then
				
				[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
				[[ "${#opts[@]}" -ne 0 ]] && __besman_echo_red "Incorrect syntax" && return 1
				__bes_$command
			else
				[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
				[[ "${#opts[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
				__bes_$command $opt_environment
			fi
			;;
		pull)
			[[ "${#args[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
			[[ "${#opts[@]}" -ne 1 ]] && __besman_echo_red "Incorrect syntax" && return 1
			if [[ ( ${opts[0]} == "--playbook" ) || ( ${opts[0]} == "-P" ) ]]; then
				type=playbook
			
			else
				type=environment
			fi
			__bes_$command $type
			unset type
			;;
		create)
			# bes create --playbook -cve <cve-details> -vuln <vulnerability> -env <env name> -ext <extension>
			# fun args[0]  opts[0] opts[1]  args[1]    opts[2]  args[2]     opts[3] args[3]  opts[4] args[4]
			local purpose vuln env ext
			type=${opts[0]}
			if [[ ( -n $type ) && ( $type == --playbook || $type == -P ) ]]; then
				[[ ${#args[@]} != ${#opts[@]} ]] && __besman_echo_red "Incorrect syntax" && return 1
				# type=playbook
				for (( i=0; i<${#opts[@]}; i++ ))
				do
					if [[ ( ${opts[i]} == "-P" ) || ( ${opts[i]} == "--playbook" ) ]]; then					
						continue
					elif [[ ${opts[i]} == "-cve" ]]; then
						[[ $assess_flag -eq 1 ]] && __besman_echo_red "Playbook can only be created for either exploiting or assessment" && return 1
						# cve_flag=1
						purpose=${args[i]}
						__besman_cve_format_check $purpose || return 1
					elif [[ ${opts[i]} == "-assess" ]]; then
						[[ -n $purpose ]] && __besman_echo_red "Playbook can only be created for either exploiting or assessment" && return 1
						assess_flag=1
						purpose=${args[i]}
						__besman_validate_assessment $purpose || return 1
					elif [[ ${opts[i]} == "-vuln" ]]; then
						vuln=${args[i]}
					elif [[ ${opts[i]} == "-env" ]]; then
						env=${args[i]}
					elif [[ ${opts[i]} == "-ext" ]]; then
						ext=${args[i]}
					fi				
				done
				# cve=${args[1]}
				# vuln=${args[2]}
				# env=${args[3]}
				# ext=${args[4]}

				if [[ $assess_flag -eq 1 ]]; then
					__bes_$command "$type" "$assess_flag" "$purpose" "$vuln" "$env" "$ext" 
				else
					__bes_$command "$type" "$assess_flag" "$purpose" "$vuln" "$env" "$ext" 
				fi

			fi
			unset type purpose vuln env ext
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
	unset environment version command args opts assess_flag purpose
	
}	
