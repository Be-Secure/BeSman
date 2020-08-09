#!/usr/bin/env bash
# passthrough returns zero return code
function __besman_pre_installation_hook() {
	echo "PRE: returns with zero return code"
	return 0
}
