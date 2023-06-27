#!/usr/bin/env bash

function __bes_install {
	local environment_name env_repo environment_name version_id
	environment_name=$1


	version_id=$2
	if [[ ( -n $BESMAN_LOCAL_ENV ) && ( $BESMAN_LOCAL_ENV == "True" ) ]]; then
		__besman_get_local_env "$environment_name" "$version_id" || return 1
	fi
	# If environmnet not installed.
	if [[ ! -d "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id" ]]; then

		if [[ ( -n $BESMAN_LOCAL_ENV ) && ( $BESMAN_LOCAL_ENV == "False" ) ]]; then
			__besman_get_remote_env "$environment_name" || return 1
		fi
		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}"
		touch "${BESMAN_DIR}/envs/besman-${environment_name}/current"
		current="${BESMAN_DIR}/envs/besman-${environment_name}/current"
		echo "${environment_name}" > "$BESMAN_DIR/var/current"

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
	unset return_val env_repo environment_name namespace version_id

}

function __besman_get_local_env()
{
	local environment version default_config_path

	environment=$1
	version=$2
	ossp=$(echo "$environment" | cut -d "-" -f 1)
	default_config_path=$BESMAN_DIR/tmp/besman-$environment_name-config.yaml
	[[ ! -d $BESMAN_ENV_REPOS ]] && __besman_echo_red "Could not find dir $BESMAN_ENV_REPOS" && return 1
	cp "$BESMAN_ENV_REPOS/$ossp/$version/besman-$environment.sh" "$BESMAN_DIR/envs/"
	if [[ ( -n $BESMAN_LIGHT_MODE ) && ( $BESMAN_LIGHT_MODE == "False" ) && ( ! -f "$HOME/besman-$environment-config.yaml" ) ]]; then
		
		if [[ -f $default_config_path ]]; then
			__besman_echo_yellow "A config file already exists"
			read -rp "Do you wish to replace it(y/n)?: " replace
		fi
		if [[ ( -z $replace ) || ( $replace == 'Y' ) || ( $replace == 'y' ) ]]; then
			rm "$default_config_path"
			touch "$default_config_path"
			[[ ! -f "$BESMAN_ENV_REPOS/$ossp/$version/besman-$environment-config.yaml" ]] && __besman_echo_red "Could not find config file in the path $BESMAN_ENV_REPOS/$ossp/$version/" && return 1
			cp "$BESMAN_ENV_REPOS/$ossp/$version/besman-$environment-config.yaml" "$default_config_path"
		fi
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
	local environment_name env_repo_namespace env_repo ossp env_url default_config_path replace curl_flag
	env_repo_namespace=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 1)
	env_repo=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 2)
	environment_name=$1
	env_type=$(echo "$environment_name" | cut -d "-" -f 2)
	ossp=$(echo "$environment_name" | cut -d "-" -f 1)
	env_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp}/${version_id}/besman-${environment_name}.sh"
	default_config_path=$BESMAN_DIR/tmp/besman-$environment_name-config.yaml
	curl_flag=true
	__besman_secure_curl "$env_url" >>"${BESMAN_DIR}/envs/besman-${environment_name}.sh"
	[[ "$?" -ne 0 ]] && __besman_echo_red "Failed while trying to get the besman-${environment_name}.sh" && return 1
	if [[ ( -n $BESMAN_LIGHT_MODE ) && ( $BESMAN_LIGHT_MODE == "False" ) && ( ! -f "$HOME/besman-${ossp}-${env_type}-env-config.yaml" ) ]]; then
		config_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp}/${version_id}/besman-${ossp}-${env_type}-env-config.yaml"
		if [[ -f $default_config_path ]]; then
			__besman_echo_yellow "A config file already exists"
			read -rp "Do you wish to replace it(y/n)?: " replace
			if [[ ( -z $replace ) || ( $replace == 'Y' ) || ( $replace == 'y' ) ]]; then
				rm "$default_config_path"
			else
				curl_flag=false
			fi
		fi
		if [[ $curl_flag == true ]]; then
			touch "$default_config_path"
			if ! __besman_secure_curl "$config_url" >> "$default_config_path";
			then
				__besman_echo_red "Failed while trying to get the besman-${ossp}-${env_type}-env-config.yaml" 
				return 1
			fi
		fi
	fi


}