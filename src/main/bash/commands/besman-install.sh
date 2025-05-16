#!/usr/bin/env bash

function __bes_install {

	local environment_name env_repo environment_name version_id env_config
	environment_name=$1
	version_id=$2
	if [[ -z $version_id ]]
	then
		version_id=$(__besman_get_latest_env_version "$environment_name" || return 1)

		__besman_echo_yellow "No version specified. Using latest version $version_id"
	fi
	trap "__besman_echo_red ''; __besman_echo_red 'User interrupted'; __besman_echo_red ''; __besman_error_rollback $environment_name || return 1" SIGINT

	# If environmnet not installed.
	if [[ ! -d "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id" ]]; then


		if [[ (-n $BESMAN_LOCAL_ENV) && ($BESMAN_LOCAL_ENV == "true") ]]; then
			__besman_get_local_env "$environment_name" "$version_id" || return 1
		fi
		if [[ (-n $BESMAN_LOCAL_ENV) && ($BESMAN_LOCAL_ENV == "false") ]]; then
			__besman_get_remote_env "$environment_name" || return 1
		fi
		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}"
		touch "${BESMAN_DIR}/envs/besman-${environment_name}/current"
		current="${BESMAN_DIR}/envs/besman-${environment_name}/current"
		echo "${environment_name}" >"$BESMAN_DIR/var/current"

		mkdir -p "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id"

		__besman_echo_no_colour "$version_id" >"$current"


		mv "${BESMAN_DIR}/envs/besman-${environment_name}.sh" "${BESMAN_DIR}/envs/besman-${environment_name}/$version_id/"
		__besman_source_env_params "$environment_name" "$version_id"
		if [[ $? -eq 1 ]]; then
			__besman_error_rollback "$environment_name"
			__besman_manage_install_out "$return_val" "$environment_name"
			return 1
		fi

		__besman_show_lab_association_prompt "$environment_name" "$version_id"
		if [[ $? -eq 1 ]]; then

			__besman_error_rollback "$environment_name"
			return 1

		fi
		source "${BESMAN_DIR}/envs/besman-${environment_name}/${version_id}/besman-${environment_name}.sh"
		__besman_install "${environment_name}" "${version_id}"

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
	trap - SIGINT
}

function __besman_get_local_env() {
	local environment version default_config_path

	environment=$1
	version=$2

	if echo "$environment_name" | grep -qE 'RT|BT'; then

		ossp=$(echo "$environment_name" | sed -E 's/-(RT|BT)-env//')
	else
		ossp=$(echo "$environment_name" | cut -d "-" -f 1)

	fi
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
		__besman_error_rollback "$environment" || return 1

	fi

}

function __besman_get_remote_env {

	# This code fetches the environment and its config file from env repo
	local environment_name ossp env_url default_config_path
	environment_name=$1
	env_type=$(echo "$environment_name" | rev | cut -d "-" -f 2 | rev)

	if echo "$environment_name" | grep -qE 'RT|BT'; then

		ossp=$(echo "$environment_name" | sed -E 's/-(RT|BT)-env//')
	else
		ossp=$(echo "$environment_name" | cut -d "-" -f 1)

	fi
	env_url=$(__besman_construct_raw_url "$BESMAN_ENV_REPO" "$BESMAN_ENV_REPO_BRANCH" "${ossp}/${version_id}/besman-${environment_name}.sh")
	# env_url="$raw_url/${ossp}/${version_id}/besman-${environment_name}.sh"
	default_config_path=$BESMAN_DIR/tmp/besman-$environment_name-config.yaml
	__besman_check_url_valid "$env_url" || return 1
	__besman_secure_curl "$env_url" >>"${BESMAN_DIR}/envs/besman-${environment_name}.sh"


}

function __besman_show_lab_association_prompt() {
	local environment_name version user_input
	environment_name=$1
	version=$2

	if echo "$environment_name" | grep -qE 'RT|BT'; then

		ossp=$(echo "$environment_name" | sed -E 's/-(RT|BT)-env//')
	else
		ossp=$(echo "$environment_name" | cut -d "-" -f 1)

	fi
	# if [[ -z "$BESMAN_LAB_NAME" ]]; then
	# 	__besman_echo_red "Lab name is missing."
	# 	__besman_echo_yellow "Please use the below command to export it."
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_white "$ export BESMAN_LAB_NAME=<Name of the lab>"
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_yellow "OR"
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_no_colour "1. Check if the file $HOME/besman-$environment_name-config.yaml exists in $HOME"
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_no_colour "2. If the file does not exist, run the below command to download the file"
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_yellow "		wget -P \$HOME https://raw.githubusercontent.com/$BESMAN_NAMESPACE/besecure-ce-env-repo/master/$ossp/$version/besman-$environment_name-config.yaml"
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_no_colour "3. Open the file $HOME/besman-$environment_name-config.yaml in an editor"
	# 	__besman_echo_no_colour ""
	# 	__besman_echo_white "	 4. Edit the variables - BESMAN_LAB_NAME and BESMAN_LAB_TYPE"
	# 	__besman_echo_no_colour ""
	# 	return 1
	# fi
	if [[ $BESMAN_LAB_NAME == "Be-Secure" && ! -f $HOME/besman-$environment-config.yaml ]]; then
		__besman_echo_yellow "Going with default lab association - Be-Secure Commuinity Lab"
		read -rp "Do you wish to change the lab association (y/n)?:" user_input
		if [[ $user_input == "y" ]]; then
			__besman_echo_white "\Use the below command to download the configuration file"

			__besman_echo_yellow "$ bes config -env $environment_name -V $version\n"
			__besman_echo_white "Open the file in your editor and change the value for $(__besman_echo_yellow "BESMAN_LAB_NAME") and $(__besman_echo_yellow "BESMAN_LAB_TYPE")\n"
			return 1
		fi
	elif  [[ $BESMAN_LAB_NAME == "Be-Secure" && -f $HOME/besman-$environment-config.yaml ]] 
	then
		
		__besman_echo_yellow "Going with default lab association - Be-Secure Commuinity Lab"
		read -rp "Do you wish to change the lab association (y/n)?:" user_input
		if [[ $user_input == "y" ]]; then
			__besman_echo_white "\nOpen the below file in your editor and change the value for $(__besman_echo_yellow "BESMAN_LAB_NAME") and $(__besman_echo_yellow "BESMAN_LAB_TYPE")\n"
			__besman_echo_yellow "$HOME/besman-$environment-config.yaml \n"
			return 1
		fi
	fi
}

function __besman_download_env_repo() {
	local env_zip_dir="$1"
	local env_zip="$env_zip_dir/env.zip"
	local repo_url env_repo_name
	if [[ "$BESMAN_CODE_COLLAB_PLATFORM" == "github" ]]
	then
		
		repo_url="$BESMAN_CODE_COLLAB_URL/$BESMAN_ENV_REPO/archive/refs/heads/$BESMAN_ENV_REPO_BRANCH.zip"
	elif [[ "$BESMAN_CODE_COLLAB_PLATFORM" == "gitlab" ]]
	then
		env_repo_name=$(echo "$BESMAN_ENV_REPO" | cut -d "/" -f 2)
		repo_url="$BESMAN_CODE_COLLAB_URL/$BESMAN_ENV_REPO/-/archive/$BESMAN_ENV_REPO_BRANCH/$env_repo_name-$BESMAN_ENV_REPO_BRANCH.zip"
	fi
	local env_repo_name="$2"
	[[ -f "$env_zip" ]] && rm -f "$env_zip"
	[[ -d "$env_zip_dir/$env_repo_name-$BESMAN_ENV_REPO_BRANCH" ]] && rm -rf "$env_zip_dir/$env_repo_name-$BESMAN_ENV_REPO_BRANCH"
	__besman_secure_curl "$repo_url" >> "$env_zip" || {
		__besman_echo_red "Failed to download ZIP file."
		return 1
	}
	unzip -q "$env_zip" -d "$env_zip_dir" || {
		__besman_echo_red "Failed to extract ZIP file."
		return 1
	}
	rm -f "$env_zip"
}

function __besman_get_latest_env_version()
{
	local environment_name env_zip_dir latest_version env_repo_name ossp
	environment_name=$1
	env_zip_dir="$BESMAN_DIR/tmp"
	env_repo_name=$(echo "$BESMAN_ENV_REPO" | cut -d "/" -f 2)
	ossp=$(echo "$environment_name" | rev | cut -d "-" -f 3- | rev)
	__besman_download_env_repo "$env_zip_dir" "$env_repo_name" || return 1

	latest_version=$(find "$env_zip_dir/$env_repo_name-$BESMAN_ENV_REPO_BRANCH/$ossp" -maxdepth 1 -type d | sort -V | tail -n1 | xargs basename)

	echo "$latest_version"
}