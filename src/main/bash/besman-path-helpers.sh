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

function __besman_path_contains() {
	local candidate exists

	candidate="$1"
	exists="$(echo "$PATH" | grep "$candidate")"
	if [[ -n "$exists" ]]; then
		echo 'true'
	else
		echo 'false'
	fi
}

function __besman_add_to_path() {
	local candidate present

	candidate="$1"

	present=$(__besman_path_contains "$candidate")
	if [[ "$present" == 'false' ]]; then
		PATH="$BESMAN_CANDIDATES_DIR/$candidate/current/bin:$PATH"
	fi
}

function __besman_set_candidate_home() {
	local candidate version upper_candidate

	candidate="$1"
	version="$2"

	upper_candidate=$(echo "$candidate" | tr '[:lower:]' '[:upper:]')
	export "${upper_candidate}_HOME"="${BESMAN_CANDIDATES_DIR}/${candidate}/${version}"
}

function __besman_export_candidate_home() {
	local candidate_name="$1"
	local candidate_dir="$2"
	local candidate_home_var="$(echo ${candidate_name} | tr '[:lower:]' '[:upper:]')_HOME"
	export $(echo "$candidate_home_var")="$candidate_dir"
}

function __besman_determine_candidate_bin_dir() {
	local candidate_dir="$1"
	if [[ -d "${candidate_dir}/bin" ]]; then
		echo "${candidate_dir}/bin"
	else
		echo "$candidate_dir"
	fi
}

function __besman_prepend_candidate_to_path() {
	local candidate_dir candidate_bin_dir

	candidate_dir="$1"
	candidate_bin_dir=$(__besman_determine_candidate_bin_dir "$candidate_dir")
	echo "$PATH" | grep -q "$candidate_dir" || PATH="${candidate_bin_dir}:${PATH}"
	unset CANDIDATE_BIN_DIR
}

function __besman_link_candidate_version() {
	local candidate version

	candidate="$1"
	version="$2"

	# Change the 'current' symlink for the candidate, hence affecting all shells.
	if [[ -L "${BESMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${BESMAN_CANDIDATES_DIR}/${candidate}/current" ]]; then
		rm -f "${BESMAN_CANDIDATES_DIR}/${candidate}/current"
	fi

	ln -s "${version}" "${BESMAN_CANDIDATES_DIR}/${candidate}/current"
}

function __besman_check_url_valid()
{
	local url response

	url="$1"
	response=$(curl --head --silent --output /dev/null --write-out "%{http_code}" "$url")

	if [[ $response -eq 200 ]]; then
		
		unset url response
		return 0

	else

    	__besman_echo_red "URL $url returned $response"
		unset url response
		return 1
	fi
	

}