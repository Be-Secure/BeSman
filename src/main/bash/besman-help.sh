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

function __bes_help() {
	__besman_echo_no_colour ""
	__besman_echo_no_colour "Usage: bes <command> [candidate] [version]"
	__besman_echo_no_colour "       bes offline <enable|disable>"
	__besman_echo_no_colour ""
	__besman_echo_no_colour "   commands:"
	__besman_echo_no_colour "       install   or i    <candidate> [version] [local-path]"
	__besman_echo_no_colour "       uninstall or rm   <candidate> <version>"
	__besman_echo_no_colour "       list      or ls   [candidate]"
	__besman_echo_no_colour "       use       or u    <candidate> <version>"
	__besman_echo_no_colour "       default   or d    <candidate> [version]"
	__besman_echo_no_colour "       home      or h    <candidate> <version>"
	__besman_echo_no_colour "       env       or e    [init]"
	__besman_echo_no_colour "       current   or c    [candidate]"
	__besman_echo_no_colour "       upgrade   or ug   [candidate]"
	__besman_echo_no_colour "       version   or v"
	__besman_echo_no_colour "       broadcast or b"
	__besman_echo_no_colour "       help"
	__besman_echo_no_colour "       offline           [enable|disable]"
	__besman_echo_no_colour "       selfupdate        [force]"
	__besman_echo_no_colour "       update"
	__besman_echo_no_colour "       flush             <broadcast|archives|temp>"
	__besman_echo_no_colour ""
	__besman_echo_no_colour "   candidate  :  the SDK to install: groovy, scala, grails, gradle, kotlin, etc."
	__besman_echo_no_colour "                 use list command for comprehensive list of candidates"
	__besman_echo_no_colour "                 eg: \$ bes list"
	__besman_echo_no_colour "   version    :  where optional, defaults to latest stable if not provided"
	__besman_echo_no_colour "                 eg: \$ bes install groovy"
	__besman_echo_no_colour "   local-path :  optional path to an existing local installation"
	__besman_echo_no_colour "                 eg: \$ bes install groovy 2.4.13-local /opt/groovy-2.4.13"
	__besman_echo_no_colour ""
}
