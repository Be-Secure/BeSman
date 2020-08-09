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

function __bes_default() {
	local candidate version

	candidate="$1"
	version="$2"

	__besman_check_candidate_present "$candidate" || return 1
	__besman_determine_version "$candidate" "$version" || return 1

	if [ ! -d "${BESMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]; then
		echo ""
		__besman_echo_red "Stop! ${candidate} ${VERSION} is not installed."
		return 1
	fi

	__besman_link_candidate_version "$candidate" "$VERSION"

	echo ""
	__besman_echo_green "Default ${candidate} version set to ${VERSION}"
}
