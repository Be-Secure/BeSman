function __bes_install {
	local environment_name="$1" version_id="$2"

	__bes_handle_missing_version "$environment_name" "$version_id" || return 1
	version_id="$(__besman_get_latest_env_version "$environment_name")"

	trap "__bes_handle_interrupt '$environment_name'" SIGINT

	if __bes_env_not_installed "$environment_name" "$version_id"; then
		__bes_prepare_env_dir "$environment_name" "$version_id" || return 1
		__bes_fetch_env_script "$environment_name" "$version_id" || return 1
		__bes_finalize_env_setup "$environment_name" "$version_id" || return 1
	else
		__bes_handle_existing_env "$environment_name" "$version_id" || return 1
	fi

	trap - SIGINT
}


function __bes_handle_missing_version {
	local env="$1" ver="$2"
	if [[ -z "$ver" ]]; then
		ver="$(__besman_get_latest_env_version "$env" || return 1)"
		__besman_echo_yellow "No version specified. Using latest version $ver"
	fi
	return 0
}

function __bes_handle_interrupt {
	local env="$1"
	__besman_echo_red ''
	__besman_echo_red 'User interrupted'
	__besman_echo_red ''
	__besman_error_rollback "$env" || return 1
}

function __bes_env_not_installed {
	local env="$1" ver="$2"
	[[ ! -d "${BESMAN_DIR}/envs/besman-${env}/${ver}" ]]
}

function __bes_prepare_env_dir {
	local env="$1" ver="$2"
	__besman_check_current_env || return 1
	mkdir -p "${BESMAN_DIR}/envs/besman-${env}" || return 1
	touch "${BESMAN_DIR}/envs/besman-${env}/current"
	echo "$env" >"$BESMAN_DIR/var/current"
	mkdir -p "${BESMAN_DIR}/envs/besman-${env}/${ver}" || return 1
	return 0
}

function __bes_fetch_env_script {
	local env="$1" ver="$2"

	if [[ "$BESMAN_LOCAL_ENV" == "true" ]]; then
		__besman_get_local_env "$env" "$ver" || return 1
	elif [[ "$BESMAN_LOCAL_ENV" == "false" ]]; then
		__besman_get_remote_env "$env" || return 1
	fi

	mv "${BESMAN_DIR}/envs/besman-${env}.sh" "${BESMAN_DIR}/envs/besman-${env}/${ver}/" || return 1
	return 0
}

function __bes_finalize_env_setup {
	local env="$1" ver="$2"
	local current="${BESMAN_DIR}/envs/besman-${env}/current"
	echo "$ver" >"$current"

	__besman_source_env_params "$env" "$ver"
	if [[ $? -eq 1 ]]; then
		__besman_error_rollback "$env"
		__besman_manage_install_out "$?" "$env"
		return 1
	 fi

	__besman_show_lab_association_prompt "$env" "$ver"
	if [[ $? -eq 1 ]]; then
		__besman_error_rollback "$env"
		return 1
	fi

	source "${BESMAN_DIR}/envs/besman-${env}/${ver}/besman-${env}.sh"
	__besman_install "$env" "$ver"
	local return_val="$?"

	__besman_manage_install_out "$return_val" "$env"
	return "$return_val"
}

function __bes_handle_existing_env {
	local env="$1" ver="$2"
	local current_ver_file="${BESMAN_DIR}/envs/besman-${env}/current"

	if [[ -d "${BESMAN_DIR}/envs/besman-${env}/${ver}" && $(cat "$current_ver_file") != "$ver" ]]; then
		__besman_echo_white "Please remove the existing installation for $env with version $ver and try again."
		return 1
	else
		__besman_echo_white "${env} $ver is currently installed in your system"
	fi
}

