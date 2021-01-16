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

function __besman_echo_debug() {
	if [[ "$besman_debug_mode" == 'true' ]]; then
		echo "$1"
	fi
}

function __besman_secure_curl() {
	if [[ "${besman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}

function __besman_secure_curl_download() {
	local curl_params
	curl_params=('--progress-bar' '--location')

	if [[ "${besman_debug_mode}" == 'true' ]]; then
		curl_params+=('--verbose')
	fi

	if [[ "${besman_curl_continue}" == 'true' ]]; then
		curl_params+=('-C' '-')
	fi

	if [[ -n "${besman_curl_retry_max_time}" ]]; then
		curl_params+=('--retry-max-time' "${besman_curl_retry_max_time}")
	fi

	if [[ -n "${besman_curl_retry}" ]]; then
		curl_params+=('--retry' "${besman_curl_retry}")
	fi

	if [[ "${besman_insecure_ssl}" == 'true' ]]; then
		curl_params+=('--insecure')
	fi

	curl "${curl_params[@]}" "${@}"
}

function __besman_secure_curl_with_timeouts() {
	if [[ "${besman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location --connect-timeout ${besman_curl_connect_timeout} --max-time ${besman_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${besman_curl_connect_timeout} --max-time ${besman_curl_max_time} "$1"
	fi
}

function __besman_page() {
	if [[ -n "$PAGER" ]]; then
		"$@" | eval $PAGER
	elif command -v less >& /dev/null; then
		"$@" | less
	else
		"$@"
	fi
}

function __besman_echo() {
	if [[ "$besman_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}

function __besman_echo_red() {
	__besman_echo "31m" "$1"
}

function __besman_echo_no_colour() {
	echo "$1"
}

function __besman_echo_yellow() {
	__besman_echo "33m" "$1"
}

function __besman_echo_green() {
	__besman_echo "32m" "$1"
}

function __besman_echo_cyan() {
	__besman_echo "36m" "$1"
}

function __besman_echo_confirm() {
	if [[ "$besman_colour_enable" == 'false' ]]; then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}
