#!/usr/bin/env bash


function __bes_install {
	local input_environment_name=$1 # The format of the input environment name: <env_namespace>/<env_repo_name>/<env_name>
	
	# Syntax check for var input_environment_name. 
	# Format of input environment name = <namespace>/<repo name>/<environment name>
	# Word count of var input_environment_name, after replace '/' with ' ', will be 3
	[[ $(echo $input_environment_name | sed  "s/\// /g" | wc -w) -ne 3 ]] && __besman_echo_red "Please provide the environment name as <namespace>/<repo_name>/<env_name>" && return 1
	
	local version_id=$2
	local return_val ossp env_repo_namespace env_repo environment_name
	
	# To get the actual environment name, after removing <namespace> and <repo name>
	environment_name=$(echo "$input_environment_name" | cut -d "/" -f 3) 
	
	# If environmnet not installed.
	if [[ ! -d "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id" ]];
	then		


		__besman_get_remote_env "$input_environment_name" "$environment_name" || return 1

		mkdir -p ${BESMAN_DIR}/envs/besman-"${environment_name}"
		touch ${BESMAN_DIR}/envs/besman-${environment_name}/current
		current="${BESMAN_DIR}/envs/besman-${environment_name}/current"
		
		
		mkdir -p ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id

		__besman_echo_no_colour "$version_id" > "$current"

		__besman_echo_white "Sourcing env parameters"
		__besman_source_env_parameters "$environment_name"

		cp "${BESMAN_DIR}/envs/besman-${environment_name}.sh" ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id/
		source "${BESMAN_DIR}/envs/besman-${environment_name}/${version_id}/besman-${environment_name}.sh"

		__besman_install_"${environment_name}" "${environment_name}" "${version_id}"
		__besman_unset_env_parameters
		return_val="$?"

		__besman_manage_install_out "$return_val" "$environment_name"

	# if environmnet installed, but user wants to install a different version of the same environment.
	elif [[ -d ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id && $(cat ${BESMAN_DIR}/envs/besman-${environment_name}/current) != "$version_id" ]];
	then

		__besman_echo_white "Please remove the existing installation for $environment_name with version $version_id and try again."
		return 1

	else
		# If user tries to install the already installed version of the environment
		__besman_echo_white "${environment_name} $version_id is currently installed in your system "
		
	fi

}

function __besman_manage_install_out
{
	local return_val environment
	
	return_val=$1
	environment=$2

	if [[ $return_val == "0" ]]; then

		__besman_echo_green "Successfully installed $environment"
	
	else
	
		__besman_echo_red "Installation failed"
		__besman_error_rollback "$environment"
	
	fi

}

function __besman_get_remote_env
{

	local input_environment_name environment_name env_repo_namespace env_repo ossp_dir env_url
	
	input_environment_name=$1
	environment_name=$2
	env_repo_namespace=$(echo "$input_environment_name" | cut -d "/" -f 1)
	env_repo=$(echo "$input_environment_name" | cut -d "/" -f 2)
	ossp_dir=$(echo "$input_environment_name" | cut -d "/" -f 3 | cut -d "-" -f 1)
	env_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp_dir}/${version_id}/besman-${environment_name}.sh"
	
	__besman_secure_curl "$env_url" >> ${BESMAN_DIR}/envs/besman-${environment_name}.sh
	[[ "$?" -ne 0 ]] && __besman_echo_red "Failed while trying to get the besman-${environment_name}.sh" && return 1
	
	# Checks for user level config file for the env. If not found, download the default config file from remote repo.
	if [[ ! -f $HOME/besman-$environment_name.yml ]]; then

		__besman_echo_white "Using environment level configuration."

		env_config_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp_dir}/${version_id}/besman-${environment_name}.yml"
		__besman_secure_curl "$env_config_url" >> $HOME/besman-${environment_name}.yml

		[[ "$?" -ne "0" ]] && __besman_echo_red "Could not get the env level configuration" && return 1
	
	else

		__besman_echo_white "User level configuration found"
	
	fi

	
	unset input_environment_name environment_name env_repo_namespace env_repo ossp_dir env_url
 
		
}