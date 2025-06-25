#!/usr/bin/env bash

# Logs informational messages
__besman_log_info() {
	echo "[INFO] $1" >>"$BESMAN_DIR/var/install.log"
}

# Logs error messages
__besman_log_error() {
	echo "[ERROR] $1" >>"$BESMAN_DIR/var/install.log"
}

function __bes_install {
	local environment_name="$1" version_id="$2"

	__besman_log_info "Starting installation for environment: $environment_name, version: ${version_id:-latest}"

	if [[ -z $version_id ]]; then
		version_id=$(__besman_get_latest_env_version "$environment_name" || return 1)

		__besman_echo_yellow "No version specified. Using latest version $version_id"
	fi

	version_id="$(__besman_get_latest_env_version "$environment_name")"

	trap "__besman_install_besman '$environment_name'" SIGINT

	if __besman_env_not_installed "$environment_name" "$version_id"; then
		__besman_log_info "Environment not found locally. Proceeding with installation."
		__besman_prepare_env_dir "$environment_name" "$version_id" || return 1
		__besman_fetch_env_script "$environment_name" "$version_id" || return 1
		__besman_finalize_env_setup "$environment_name" "$version_id" || return 1
	else
		__besman_handle_existing_env "$environment_name" "$version_id" || return 1
	fi

	__besman_log_info "Installation process completed for $environment_name $version_id"
	trap - SIGINT
}

function __besman_install_besman {
	local env="$1"
	__besman_echo_red ''
	__besman_echo_red 'User interrupted'
	__besman_echo_red ''
	__besman_log_error "Installation interrupted by user for environment: $env"
	__besman_error_rollback "$env" || __besman_log_error "Rollback failed for $env"
}

function __besman_env_not_installed {
	local env="$1" ver="$2"
	[[ ! -d "${BESMAN_DIR}/envs/besman-${env}/${ver}" ]]
}

function __besman_prepare_env_dir {
	local env="$1" ver="$2"
	__besman_check_current_env || {
		__besman_log_error "Current environment check failed for $env"
		return 1
	}

	mkdir -p "${BESMAN_DIR}/envs/besman-${env}" || {
		__besman_log_error "Failed to create environment directory for $env"
		return 1
	}
	touch "${BESMAN_DIR}/envs/besman-${env}/current"
	echo "$env" >"$BESMAN_DIR/var/current"
	mkdir -p "${BESMAN_DIR}/envs/besman-${env}/${ver}" || {
		__besman_log_error "Failed to create version subdirectory for $env $ver"
		return 1
	}
	return 0
}

function __besman_fetch_env_script {
	local env="$1" ver="$2"

	if [[ "$BESMAN_LOCAL_ENV" == "true" ]]; then
		__besman_get_local_env "$env" "$ver" || {
			__besman_log_error "Failed to get local environment for $env $ver"
			return 1
		}
	elif [[ "$BESMAN_LOCAL_ENV" == "false" ]]; then
		__besman_get_remote_env "$env" || {
			__besman_log_error "Failed to fetch remote environment script for $env"
			return 1
		}
	else
		__besman_log_error "Unknown BESMAN_LOCAL_ENV value: $BESMAN_LOCAL_ENV"
		return 1
	fi

	mv "${BESMAN_DIR}/envs/besman-${env}.sh" "${BESMAN_DIR}/envs/besman-${env}/${ver}/" || {
		__besman_log_error "Failed to move script into versioned directory for $env"
		return 1
	}
	return 0
}

function __besman_finalize_env_setup {
	local env="$1" ver="$2"
	local current="${BESMAN_DIR}/envs/besman-${env}/current"
	echo "$ver" >"$current"

	__besman_source_env_params "$env" "$ver"
	if [[ $? -ne 0 ]]; then
		__besman_log_error "Sourcing env params failed for $env $ver"
		__besman_manage_install_out "$?" "$env"
		return 1
	fi

	__besman_show_lab_association_prompt "$env" "$ver"

	source "${BESMAN_DIR}/envs/besman-${env}/${ver}/besman-${env}.sh"
	__besman_install "$env" "$ver"
	local return_val="$?"

	if [[ $return_val -ne 0 ]]; then
		__besman_log_error "Installation script failed for $env $ver"
	fi

	__besman_manage_install_out "$return_val" "$env"
	return "$return_val"
}

function __besman_handle_existing_env {
	local env="$1" ver="$2"
	local current_ver_file="${BESMAN_DIR}/envs/besman-${env}/current"

	if [[ -d "${BESMAN_DIR}/envs/besman-${env}/${ver}" && $(cat "$current_ver_file") != "$ver" ]]; then
		__besman_echo_white "Please remove the existing installation for $env with version $ver and try again."
		__besman_log_info "Install attempt for different version $ver while another is active for $env"
		return 1
	else
		__besman_echo_white "${env} $ver is currently installed in your system"
		__besman_log_info "$env $ver already installed. Skipping installation."
	fi
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
	if [[ $BESMAN_LAB_NAME == "Be-Secure" && ! -f $HOME/besman-$environment-config.yaml ]]; then
		__besman_echo_yellow "Going with default lab association - Be-Secure Commuinity Lab"
		read -rp "Do you wish to change the lab association (y/n)?:" user_input
		if [[ $user_input == "y" ]]; then
			__besman_echo_white "\Use the below command to download the configuration file"

			__besman_echo_yellow "$ bes config -env $environment_name -V $version\n"
			__besman_echo_white "Open the file in your editor and change the value for $(__besman_echo_yellow "BESMAN_LAB_NAME") and $(__besman_echo_yellow "BESMAN_LAB_TYPE")\n"
			return 1
		fi
	elif [[ $BESMAN_LAB_NAME == "Be-Secure" && -f $HOME/besman-$environment-config.yaml ]]; then

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
	if [[ "$BESMAN_CODE_COLLAB_PLATFORM" == "github" ]]; then

		repo_url="$BESMAN_CODE_COLLAB_URL/$BESMAN_ENV_REPO/archive/refs/heads/$BESMAN_ENV_REPO_BRANCH.zip"
	elif [[ "$BESMAN_CODE_COLLAB_PLATFORM" == "gitlab" ]]; then
		env_repo_name=$(echo "$BESMAN_ENV_REPO" | cut -d "/" -f 2)
		repo_url="$BESMAN_CODE_COLLAB_URL/$BESMAN_ENV_REPO/-/archive/$BESMAN_ENV_REPO_BRANCH/$env_repo_name-$BESMAN_ENV_REPO_BRANCH.zip"
	fi
	local env_repo_name="$2"
	[[ -f "$env_zip" ]] && rm -f "$env_zip"
	[[ -d "$env_zip_dir/$env_repo_name-$BESMAN_ENV_REPO_BRANCH" ]] && rm -rf "$env_zip_dir/$env_repo_name-$BESMAN_ENV_REPO_BRANCH"
	__besman_secure_curl "$repo_url" >>"$env_zip" || {
		__besman_echo_red "Failed to download ZIP file."
		return 1
	}
	unzip -q "$env_zip" -d "$env_zip_dir" || {
		__besman_echo_red "Failed to extract ZIP file."
		return 1
	}
	rm -f "$env_zip"
}

function __besman_get_latest_env_version() {
	local environment_name env_zip_dir latest_version env_repo_name ossp
	environment_name=$1
	env_zip_dir="$BESMAN_DIR/tmp"
	env_repo_name=$(echo "$BESMAN_ENV_REPO" | cut -d "/" -f 2)
	ossp=$(echo "$environment_name" | rev | cut -d "-" -f 3- | rev)
	__besman_download_env_repo "$env_zip_dir" "$env_repo_name" || return 1

	latest_version=$(find "$env_zip_dir/$env_repo_name-$BESMAN_ENV_REPO_BRANCH/$ossp" -maxdepth 1 -type d | sort -V | tail -n1 | xargs basename)

	echo "$latest_version"
}
