#!/usr/bin/env bash
# convert tar.gz to zip
function __besman_post_installation_hook() {
	echo "POST: converting $binary_input to $zip_output"
	mkdir -p "$BESMAN_DIR/tmp/out"
	/usr/bin/env tar zxvf "$binary_input" -C "${BESMAN_DIR}/tmp/out"
	cd "${BESMAN_DIR}/tmp/out"
	/usr/bin/env zip -r "$zip_output" .
}
