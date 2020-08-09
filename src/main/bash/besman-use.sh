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

function __bes_use() {
	local candidate version install

	candidate="$1"
	version="$2"
	__besman_check_version_present "$version" || return 1
	__besman_check_candidate_present "$candidate" || return 1

	if [[ ! -d "${BESMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
		echo ""
		__besman_echo_red "Stop! ${candidate} ${version} is not installed."
		return 1
	fi

	# Just update the *_HOME and PATH for this shell.
	__besman_set_candidate_home "$candidate" "$version"

	# Replace the current path for the candidate with the selected version.
	if [[ "$solaris" == true ]]; then
		export PATH=$(echo $PATH | gsed -r "s!${BESMAN_CANDIDATES_DIR}/${candidate}/([^/]+)!${BESMAN_CANDIDATES_DIR}/${candidate}/${version}!g")

	elif [[ "$darwin" == true ]]; then
		export PATH=$(echo $PATH | sed -E "s!${BESMAN_CANDIDATES_DIR}/${candidate}/([^/]+)!${BESMAN_CANDIDATES_DIR}/${candidate}/${version}!g")

	else
		export PATH=$(echo "$PATH" | sed -r "s!${BESMAN_CANDIDATES_DIR}/${candidate}/([^/]+)!${BESMAN_CANDIDATES_DIR}/${candidate}/${version}!g")
	fi

	if [[ ! (-L "${BESMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${BESMAN_CANDIDATES_DIR}/${candidate}/current") ]]; then
		__besman_echo_green "Setting ${candidate} version ${version} as default."
		__besman_link_candidate_version "$candidate" "$version"
	fi

	echo ""
	__besman_echo_green "Using ${candidate} version ${version} in this shell."
}
