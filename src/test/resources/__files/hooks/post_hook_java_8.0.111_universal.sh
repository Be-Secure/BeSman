#!/usr/bin/env bash
# passthrough used for zip binaries
function __besman_post_installation_hook() {
	echo "POST: passthrough $binary_input to $zip_output"
	mv "$binary_input" "$zip_output"
}
