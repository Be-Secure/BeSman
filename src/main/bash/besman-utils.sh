#!/usr/bin/env bash

#
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

function __besman_echo_debug {
	if [[ "${besman_debug_mode}" == 'true' ]]; then
		echo "$1"
	fi
}

function __besman_secure_curl {
	if [[ "${besman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}

function __besman_secure_curl_download {
	local curl_params="--progress-bar --location"
	if [[ "${besman_insecure_ssl}" == 'true' ]]; then
		curl_params="$curl_params --insecure"
	fi

	if [[ ! -z "${besman_curl_retry}" ]]; then
		curl_params="--retry ${besman_curl_retry} ${curl_params}"
	fi

	if [[ ! -z "${besman_curl_retry_max_time}" ]]; then
		curl_params="--retry-max-time ${besman_curl_retry_max_time} ${curl_params}"
	fi

	if [[ "${besman_curl_continue}" == 'true' ]]; then
		curl_params="-C - ${curl_params}"
	fi

	if [[ "${besman_debug_mode}" == 'true' ]]; then
		curl_params="--verbose ${curl_params}"
	fi

	if [[ "$zsh_shell" == 'true' ]]; then
		curl ${=curl_params} "$@"
	else
		curl ${curl_params} "$@"
	fi
}

function __besman_secure_curl_with_timeouts {
	if [[ "${besman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location --connect-timeout ${besman_curl_connect_timeout} --max-time ${besman_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${besman_curl_connect_timeout} --max-time ${besman_curl_max_time} "$1"
	fi
}

function __besman_page {
	if [[ -n "$PAGER" ]]; then
		"$@" | eval $PAGER
	elif command -v less >& /dev/null; then
		"$@" | less
	else
		"$@"
	fi
}

function __besman_echo {
	if [[ "$besman_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}

function __besman_highlight_echo
{
	if [[ "$besman_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[$1$2\033[0m"
	fi
}

function __besman_echo_red {
	__besman_echo "31m" "$1"
}

function __besman_echo_no_colour {
	echo "$1"
}

function __besman_echo_yellow {
	__besman_echo "33m" "$1"
}

function __besman_echo_green {
	__besman_echo "32m" "$1"
}

function __besman_echo_cyan {
	__besman_echo "36m" "$1"
}

function __besman_echo_white {
	__besman_echo "1m" "$1"
}

function __besman_echo_blue {
	__besman_echo "34m" "$1"
}

function __besman_echo_violet {
	__besman_echo "35m" "$1"
}

function __besman_echo_black_highlight
{
	__besman_highlight_echo "40m" "$1"
}

function __besman_echo_red_highlight
{
	__besman_highlight_echo "41m" "$1"
}

function __besman_echo_green_highlight
{
	__besman_highlight_echo "42m" "$1"
}

function __besman_echo_yellow_highlight
{
	__besman_highlight_echo "43m" "$1"
}

function __besman_echo_blue_highlight
{
	__besman_highlight_echo "44m" "$1"
}

function __besman_echo_purple_highlight
{
	__besman_highlight_echo "45m" "$1"
}

function __besman_echo_cyan_highlight
{
	__besman_highlight_echo "46m" "$1"
}

function __besman_echo_white_highlight
{
	__besman_highlight_echo "47m" "$1"
}

function __besman_echo_confirm {
	if [[ "$besman_colour_enable" == 'false' ]]; then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}

function __besman_legacy_bash_message {
	__besman_echo_red "An outdated version of bash was detected on your system!"
	echo ""
	__besman_echo_red "We recommend upgrading to bash 4.x, you have:"
	echo ""
	__besman_echo_yellow "  $BASH_VERSION"
	echo ""
	__besman_echo_yellow "Need to use brute force to replace candidates..."
}
