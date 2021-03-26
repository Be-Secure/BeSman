#!/bin/bash

function __bes_version {

local environment_parameter=$1
local environment_value=$2

if [ -z "$environment_parameter" ]
then
	echo "BeSman utility version" "$(cat ${BESMAN_DIR}/var/version.txt)"
    	return 0
fi

if [[ ! -z $environment_value && -f "${BESMAN_DIR}/envs/besman-${environment_value}/current" ]]
then
	echo "${environment_value} version" "$(cat ${BESMAN_DIR}/envs/besman-${environment_value}/current)"
else
	#__besman_echo_red "$environment_value environment is not installed in the Local system !"
	__besman_echo_red "Wrong Command Format"
fi

}
