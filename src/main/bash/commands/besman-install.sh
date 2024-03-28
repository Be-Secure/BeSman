#!/usr/bin/env bash

function __bes_install {
	local environment_name env_repo environment_name version_id env_config
	environment_name=$1
	version_id=$2

	# If environmnet not installed.
	if [[ ! -d "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id" ]]; then

		if [[ ( -n $BESMAN_LOCAL_ENV ) && ( $BESMAN_LOCAL_ENV == "true" ) ]]; then
			__besman_get_local_env "$environment_name" "$version_id" || return 1
		fi
		if [[ ( -n $BESMAN_LOCAL_ENV ) && ( $BESMAN_LOCAL_ENV == "false" ) ]]; then
			__besman_get_remote_env "$environment_name" || return 1
		fi
		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}"
		touch "${BESMAN_DIR}/envs/besman-${environment_name}/current"
		current="${BESMAN_DIR}/envs/besman-${environment_name}/current"
		echo "${environment_name}" > "$BESMAN_DIR/var/current"

		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id"

		__besman_echo_no_colour "$version_id" >"$current"
		
		mv "${BESMAN_DIR}/envs/besman-${environment_name}.sh" "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id/"
		__besman_source_env_params "$environment_name"
		if [[ $? -eq 1 ]]
		then
			__besman_error_rollback "$environment_name"
			__besman_manage_install_out "$return_val" "$environment_name"
			return 1
		fi


		__besman_show_lab_association_prompt "$environment_name" "$version_id"
		if [[ $? -eq 1 ]]
		then
			__besman_error_rollback "$environment_name"
			return 1

		fi
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
	[[ ! -d $BESMAN_LOCAL_ENV_DIR ]] && __besman_echo_red "Could not find dir $BESMAN_LOCAL_ENV_DIR" && return 1
	cp "$BESMAN_LOCAL_ENV_DIR/$ossp/$version/besman-$environment.sh" "$BESMAN_DIR/envs/"
	if [[ ! -f "$HOME/besman-$environment-config.yaml" ]]; then
		
			[[ -f $default_config_path ]] && rm "$default_config_path"
			touch "$default_config_path"
			[[ ! -f "$BESMAN_LOCAL_ENV_DIR/$ossp/$version/besman-$environment-config.yaml" ]] && __besman_echo_red "Could not find config file in the path $BESMAN_LOCAL_ENV_DIR/$ossp/$version/"
			[[ -f "$BESMAN_LOCAL_ENV_DIR/$ossp/$version/besman-$environment-config.yaml" ]] && cp "$BESMAN_LOCAL_ENV_DIR/$ossp/$version/besman-$environment-config.yaml" "$default_config_path"
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
	__besman_check_url_valid "$env_url" || return 1
	__besman_secure_curl "$env_url" >>"${BESMAN_DIR}/envs/besman-${environment_name}.sh"
	


}

function __besman_show_lab_association_prompt()
{
	local environment_name version user_input
	environment_name=$1
	version=$2
	ossp=$(echo "$environment_name" | cut -d "-" -f 1)

	[[ -z "$BESMAN_LAB_OWNER_NAME" ]] && return 1
	if [[ $BESMAN_LAB_OWNER_NAME == "Be-Secure" ]] 
	then
		__besman_echo_yellow "Going with default lab association - Be-Secure Commuinity Lab"
		read -rp "Do you wish to change the lab association (y/n)?:" user_input
		if [[ $user_input == "y" ]] 
		then	
		__besman_echo_no_colour ""
		__besman_echo_no_colour "1. Run the below command"
		__besman_echo_no_colour ""
		__besman_echo_yellow "		wget -P \$HOME https://raw.githubusercontent.com/$BESMAN_NAMESPACE/besecure-ce-env-repo/master/$ossp/$version/besman-$environment_name-config.yaml"
		__besman_echo_no_colour ""
		__besman_echo_no_colour "2. Open the file $HOME/besman-$environment_name-config.yaml in an editor"
		__besman_echo_no_colour ""
		__besman_echo_white "3. Edit the variables - BESMAN_LAB_OWNER_NAME and BESMAN_LAB_OWNER_TYPE"
		__besman_echo_no_colour ""
		return 1
		fi		
	fi
}