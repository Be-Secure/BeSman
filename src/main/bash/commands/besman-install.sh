#!/usr/bin/env bash


function __bes_install {
	local environment_name=$1
	local version_id=$2
	local return_val
	mkdir -p ${BESMAN_DIR}/envs/besman-"${environment_name}"
	touch ${BESMAN_DIR}/envs/besman-${environment_name}/current
	current="${BESMAN_DIR}/envs/besman-${environment_name}/current"

	if [[ ! -f ${BESMAN_DIR}/envs/besman-${environment_name}.sh ]]; then
		__besman_echo_debug "Could not find file besman-$environment_name.sh"
		return 1
	fi
	if [[ ! -d ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id ]];
	then
		mkdir -p ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id
		# cd $version_id                                          # Needs to be refactored identify the latest version
		__besman_echo_no_colour "$version_id" > "$current"
		cp "${BESMAN_DIR}/envs/besman-${environment_name}.sh" ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id/
		source "${BESMAN_DIR}/envs/besman-${environment_name}/${version_id}/besman-${environment_name}.sh"
		__besman_install_"${environment_name}" "${environment_name}" "${version_id}"
		return_val="$?"
		__besman_manage_install_out "$return_val" "$environment_name"

	elif [[ -d ${BESMAN_DIR}/envs/besman-${environment_name}/$version_id && $(cat ${BESMAN_DIR}/envs/besman-${environment_name}/current) != "$version_id" ]];
	then
		__besman_echo_no_colour "Re-installing ${environment_name} with version:${version_id} "
		__besman_echo_no_colour "$version_id" > "$current"
		__besman_install_"${environment_name}" "${environment_name}" "${version_id}"
		return_val="$?"
		__besman_manage_install_out "$return_val" "$environment_name"

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