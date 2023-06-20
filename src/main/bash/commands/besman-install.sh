#!/usr/bin/env bash

function __bes_install {
	local input_environment_name=$1
	local namespace env_repo environment_name 
	if [[ ($(echo "$input_environment_name" | sed "s/\// /g" | wc -w) -eq 1) && ( ! -f $BESMAN_DIR/envs/besman-$input_environment_name.sh ) ]]; then
		echo "Defaulting to Be-Secure/besecure-ce-env-repo"
		namespace="$BESMAN_NAMESPACE"
		env_repo="besecure-ce-env-repo"
		environment_name="$input_environment_name"
	elif [[ ($(echo "$input_environment_name" | sed "s/\// /g" | wc -w) -eq 3) && ( ! -f $BESMAN_DIR/envs/besman-$(echo "$input_environment_name" | cut -d "/" -f 3).sh ) ]]; then
		OLD_IFS="$IFS"
		IFS="/"
		read -r namespace env_repo environment_name <<<"$input_environment_name"
		IFS="$OLD_IFS"
	elif [[ ($(echo "$input_environment_name" | sed "s/\// /g" | wc -w) -eq 1) && ( -f $BESMAN_DIR/envs/besman-$input_environment_name.sh ) ]]; then
		__besman_echo_yellow "Installing local environment $input_environment_name"
		environment_name="$input_environment_name"

	fi

	local version_id=$2
	local return_val ossp env_repo_namespace env_repo environment_name
	# If environmnet not installed.
	if [[ ! -d "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id" ]]; then

		[[ ( -n $namespace ) && ( -n $env_repo ) ]] && __besman_get_remote_env "$namespace" "$env_repo" "$environment_name" 

		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}"
		touch "${BESMAN_DIR}/envs/besman-${environment_name}/current"
		current="${BESMAN_DIR}/envs/besman-${environment_name}/current"

		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id"

		__besman_echo_no_colour "$version_id" >"$current"
		
		cp "${BESMAN_DIR}/envs/besman-${environment_name}.sh" "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id/"
		[[ ( -n $BESMAN_LIGHT_MODE ) && ( $BESMAN_LIGHT_MODE == "False" ) ]] && __besman_source_env_params "$environment_name"
		[[ ( -n $BESMAN_LIGHT_MODE ) && ( $BESMAN_LIGHT_MODE == "False" ) ]] && __besman_create_roles_config_file 
		source "${BESMAN_DIR}/envs/besman-${environment_name}/${version_id}/besman-${environment_name}.sh"

		__besman_install_"${environment_name}" "${environment_name}" "${version_id}"

		return_val="$?"

		__besman_manage_install_out "$return_val" "$environment_name"

	# if environmnet installed, but user wants to install a different version of the same environment.
	elif [[ -d ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id && $(cat "${BESMAN_DIR}/envs/besman-${environment_name}/current") != "$version_id" ]]; then

		__besman_echo_white "Please remove the existing installation for $environment_name with version $version_id and try again."
		return 1

	else
		# If user tries to install the already installed version of the environment
		__besman_echo_white "${environment_name} $version_id is currently installed in your system "

	fi

}

function __besman_manage_install_out {
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

function __besman_get_remote_env {

	# This code fetches the environment and its config file from env repo
	local input_environment_name environment_name env_repo_namespace env_repo ossp env_url default_config_path
	env_repo_namespace=$1
	env_repo=$2
	environment_name=$3
	env_type=$(echo "$environment_name" | cut -d "-" -f 2)
	ossp=$(echo "$environment_name" | cut -d "-" -f 1)
	env_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp}/${version_id}/besman-${environment_name}.sh"
	default_config_path=$BESMAN_DIR/tmp/besman-$environment_name-config.yaml
	__besman_secure_curl "$env_url" >>"${BESMAN_DIR}/envs/besman-${environment_name}.sh"
	[[ "$?" -ne 0 ]] && __besman_echo_red "Failed while trying to get the besman-${environment_name}.sh" && return 1
	if [[ ( -n $BESMAN_LIGHT_MODE ) && ( $BESMAN_LIGHT_MODE == "False" ) && ( ! -f "$HOME/besman-${ossp}-${env_type}-env-config.yaml" ) ]]; then
		config_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp}/${version_id}/besman-${ossp}-${env_type}-env-config.yaml"
		touch "$default_config_path"
		__besman_secure_curl "$config_url" >> "$default_config_path"
		[[ "$?" -ne 0 ]] && __besman_echo_red "Failed while trying to get the besman-${ossp}-${env_type}-env-config.yaml" && return 1
	fi


}