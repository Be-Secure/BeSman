#!/usr/bin/env bash

#
#   Copyright 2020 the original author or authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# set env vars if not set
if [ -z "$BESMAN_VERSION" ]; then
	export BESMAN_VERSION="@BESMAN_VERSION@"
fi

if [ -z "$BESMAN_CANDIDATES_API" ]; then
	export BESMAN_CANDIDATES_API="@BESMAN_CANDIDATES_API@"
fi

if [ -z "$BESMAN_DIR" ]; then
	export BESMAN_DIR="$HOME/.besman"
fi

# infer platform
BESMAN_PLATFORM="$(uname)"
if [[ "$BESMAN_PLATFORM" == 'Linux' ]]; then
	if [[ "$(uname -m)" == 'i686' ]]; then
		BESMAN_PLATFORM+='32'
	elif [[ "$(uname -m)" == 'aarch64' ]]; then
		BESMAN_PLATFORM+='ARM64'
	else
		BESMAN_PLATFORM+='64'
	fi
fi
export BESMAN_PLATFORM

# OS specific support (must be 'true' or 'false').
cygwin=false
darwin=false
solaris=false
freebsd=false
case "${BESMAN_PLATFORM}" in
	CYGWIN*)
		cygwin=true
		;;
	Darwin*)
		darwin=true
		;;
	SunOS*)
		solaris=true
		;;
	FreeBSD*)
		freebsd=true
esac

# Determine shell
zsh_shell=false
bash_shell=false

if [[ -n "$ZSH_VERSION" ]]; then
	zsh_shell=true
else
	bash_shell=true
fi

# Source besman module scripts and extension files.
#
# Extension files are prefixed with 'besman-' and found in the ext/ folder.
# Use this if extensions are written with the functional approach and want
# to use functions in the main besman script. For more details, refer to
# <https://github.com/besman/besman-extensions>.
OLD_IFS="$IFS"
IFS=$'\n'
scripts=($(find "${BESMAN_DIR}/src" "${BESMAN_DIR}/ext" -type f -name 'besman-*'))
for f in "${scripts[@]}"; do
	source "$f"
done
IFS="$OLD_IFS"
unset OLD_IFS scripts f

# Load the besman config if it exists.
if [ -f "${BESMAN_DIR}/etc/config" ]; then
	source "${BESMAN_DIR}/etc/config"
fi

# Create upgrade delay file if it doesn't exist
if [[ ! -f "${BESMAN_DIR}/var/delay_upgrade" ]]; then
	touch "${BESMAN_DIR}/var/delay_upgrade"
fi

# set curl connect-timeout and max-time
if [[ -z "$besman_curl_connect_timeout" ]]; then besman_curl_connect_timeout=7; fi
if [[ -z "$besman_curl_max_time" ]]; then besman_curl_max_time=10; fi

# set curl retry
if [[ -z "${besman_curl_retry}" ]]; then besman_curl_retry=0; fi

# set curl retry max time in seconds
if [[ -z "${besman_curl_retry_max_time}" ]]; then besman_curl_retry_max_time=60; fi

# set curl to continue downloading automatically
if [[ -z "${besman_curl_continue}" ]]; then besman_curl_continue=true; fi

# Read list of candidates and set array
BESMAN_CANDIDATES_CACHE="${BESMAN_DIR}/var/candidates"
BESMAN_CANDIDATES_CSV=$(<"$BESMAN_CANDIDATES_CACHE")
__besman_echo_debug "Setting candidates csv: $BESMAN_CANDIDATES_CSV"
if [[ "$zsh_shell" == 'true' ]]; then
	BESMAN_CANDIDATES=(${(s:,:)BESMAN_CANDIDATES_CSV})
else
	IFS=',' read -a BESMAN_CANDIDATES <<< "${BESMAN_CANDIDATES_CSV}"
fi

export BESMAN_CANDIDATES_DIR="${BESMAN_DIR}/candidates"

for candidate_name in "${BESMAN_CANDIDATES[@]}"; do
	candidate_dir="${BESMAN_CANDIDATES_DIR}/${candidate_name}/current"
	if [[ -h "$candidate_dir" || -d "${candidate_dir}" ]]; then
		__besman_export_candidate_home "$candidate_name" "$candidate_dir"
		__besman_prepend_candidate_to_path "$candidate_dir"
	fi
done
unset candidate_name candidate_dir
export PATH

if [[ "$besman_auto_env" == "true" ]]; then
	if [[ "$zsh_shell" == "true" ]]; then
		function besman_auto_env() {
			 [[ -f ".besmanrc" ]] && bes env
		}

		chpwd_functions+=(besman_auto_env)
	else
		function besman_auto_env() {
			[[ "$BESMAN_OLD_PWD" != "$PWD" ]] && [[ -f ".besmanrc" ]] && bes env

			export BESMAN_OLD_PWD="$PWD"
		}

		[[ -z "$PROMPT_COMMAND" ]] && PROMPT_COMMAND="besman_auto_env" || PROMPT_COMMAND="${PROMPT_COMMAND%\;};besman_auto_env"
	fi

	besman_auto_env
fi
