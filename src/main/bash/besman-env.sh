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

function __bes_env() {
	local -r besmanrc=".besmanrc"
	local -r sub_command="$1"

	if [[ "$sub_command" == "init" ]]; then
		__besman_generate_besmanrc "$besmanrc"

		return 0
	fi

	if [[ ! -f "$besmanrc" ]]; then
		__besman_echo_red "Could not find $besmanrc in the current directory."
		echo ""
		__besman_echo_yellow "Run 'bes env init' to create it."

		return 1
	fi

	local normalised_line
	while IFS= read -r line || [[ -n "$line" ]]; do
		normalised_line="$(__besman_normalise "$line")"

		__besman_is_blank_line "$normalised_line" && continue

		if ! __besman_matches_candidate_format "$normalised_line"; then
			__besman_echo_red "Invalid candidate format!"
			echo ""
			__besman_echo_yellow "Expected 'candidate=version' but found '$normalised_line'"

			return 1
		fi

		__bes_use "${normalised_line%=*}" "${normalised_line#*=}"
	done < "$besmanrc"
}

function __besman_generate_besmanrc() {
	local -r besmanrc="$1"

	if [[ -f "$besmanrc" ]]; then
		__besman_echo_red "$besmanrc already exists!"

		return 1
	fi

	__besman_determine_current_version "java"

	local version
	[[ -n "$CURRENT" ]] && version="$CURRENT" || version="$(__besman_secure_curl "${BESMAN_CANDIDATES_API}/candidates/default/java")"

	echo "# Enable auto-env through the besman_auto_env config" > "$besmanrc"
	echo "# Add key=value pairs of SDKs to use below" >> "$besmanrc"
	echo "java=$version" >> "$besmanrc"

	__besman_echo_green "$besmanrc created."
}

function __besman_is_blank_line() {
	[[ -z "$1" ]]
}

function __besman_normalise() {
	local -r line_without_comments="${1/\#*/}"

	echo "${line_without_comments//[[:space:]]/}"
}

function __besman_matches_candidate_format() {
	[[ "$1" =~ ^[[:lower:]]+\=.+$ ]]
}