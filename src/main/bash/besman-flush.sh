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

function __bes_flush() {
	local qualifier="$1"

	case "$qualifier" in
	broadcast)
		if [[ -f "${BESMAN_DIR}/var/broadcast_id" ]]; then
			rm "${BESMAN_DIR}/var/broadcast_id"
			rm "${BESMAN_DIR}/var/broadcast"
			__besman_echo_green "Broadcast has been flushed."
		else
			__besman_echo_no_colour "No prior broadcast found so not flushed."
		fi
		;;
	version)
		if [[ -f "${BESMAN_DIR}/var/version" ]]; then
			rm "${BESMAN_DIR}/var/version"
			__besman_echo_green "Version file has been flushed."
		fi
		;;
	archives)
		__besman_cleanup_folder "archives"
		;;
	temp)
		__besman_cleanup_folder "tmp"
		;;
	tmp)
		__besman_cleanup_folder "tmp"
		;;
	*)
		__besman_echo_red "Stop! Please specify what you want to flush."
		;;
	esac
}

function __besman_cleanup_folder() {
	local folder="$1"
	besman_cleanup_dir="${BESMAN_DIR}/${folder}"
	besman_cleanup_disk_usage=$(du -sh "$besman_cleanup_dir")
	besman_cleanup_count=$(ls -1 "$besman_cleanup_dir" | wc -l)

	rm -rf "${BESMAN_DIR}/${folder}"
	mkdir "${BESMAN_DIR}/${folder}"

	__besman_echo_green "${besman_cleanup_count} archive(s) flushed, freeing ${besman_cleanup_disk_usage}."
}
