#!/usr/bin/env bash


function __bes_install {
	local input_environment_name=$1 # The format of the input environment_name: <env_namespace>/<env_repo_name>/<env_name>
	local version_id=$2
	local return_val ossp env_repo_namespace env_repo environment_name
	

	environment_name=$(echo "$input_environment_name" | cut -d "/" -f 3) 


	# Checks if environment script is available in the local.
	if [[ ! -f "${BESMAN_DIR}/envs/besman-${environment_name}.sh" ]]; then

		if ! echo "$input_environment_name" | grep -q "/"
		then
			__besman_echo_red "Please provide the environment name as <namespace>/<repo_name>/<env_name>"
			return 1
		fi
		__besman_get_remote_env "$input_environment_name" "$environment_name"
		
	fi


	mkdir -p ${BESMAN_DIR}/envs/besman-"${environment_name}"
	touch ${BESMAN_DIR}/envs/besman-${environment_name}/current
	current="${BESMAN_DIR}/envs/besman-${environment_name}/current"
	
	# If environmnet not installed.
	if [[ ! -d "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id" ]];
	then
		
		mkdir -p ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id

		__besman_echo_no_colour "$version_id" > "$current"

		cp "${BESMAN_DIR}/envs/besman-${environment_name}.sh" ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id/
		source "${BESMAN_DIR}/envs/besman-${environment_name}/${version_id}/besman-${environment_name}.sh"

		__besman_install_"${environment_name}" "${environment_name}" "${version_id}"

		return_val="$?"

		__besman_manage_install_out "$return_val" "$environment_name"

	# if environmnet installed, but user wants to install a different version of the same environment.
	elif [[ -d ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id && $(cat ${BESMAN_DIR}/envs/besman-${environment_name}/current) != "$version_id" ]];
	then

		__besman_echo_white "Please remove the existing installation for $environment_name with version $version_id and try again."
		return 1

	else
		
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
	
	unset input_environment_name environment_name env_repo_namespace env_repo ossp_dir env_url
 
		
}