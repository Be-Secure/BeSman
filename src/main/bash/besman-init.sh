#!/usr/bin/env bash

function __besman_set_user_configs
{
	#if [[ -f $BESMAN_DIR/etc/user-config.cfg ]]; then
	#	source $BESMAN_DIR/etc/user-config.cfg
	#fi
# The functions sets all the user configs specified in the user-config.cfg file
	if [[ ! -f $HOME/.besman/etc/user-config.cfg ]]; then
		return 1
	else
		source $HOME/.besman/etc/user-config.cfg
	fi
	while read -r user_configs; do
		if echo $user_configs | grep -q "^#"
			then
				continue
		fi
		echo $user_configs > $HOME/tmp.txt
		local user_config_param=$(cut -d "=" -f 1 $HOME/tmp.txt)
		local user_config_values=$(cut -d "=" -f 2 $HOME/tmp.txt)
		unset $user_config_param
		export $user_config_param=$user_config_values
	done < $HOME/.besman/etc/user-config.cfg
}
__besman_set_user_configs || return 1
[ -f $HOME/tmp.txt ] && rm $HOME/tmp.txt 
unset user_config_param user_config_values user_configs
# set env vars if not set
if [ -z "$BESMAN_VERSION" ]; then
	export BESMAN_VERSION="0.0.1"
fi

# set besman namespace if not set
if [ -z "$BESMAN_NAMESPACE" ]; then
	export BESMAN_NAMESPACE="Be-Secure"
fi

if [ -z "$BESMAN_DIR" ]; then
	export BESMAN_DIR="$HOME/.besman"
fi

if [[ -z "$BESMAN_INTERACTIVE_USER_MODE" ]]; then
	export BESMAN_INTERACTIVE_USER_MODE="true"
fi


# infer platform
BESMAN_PLATFORM="$(uname)"
if [[ "$BESMAN_PLATFORM" == 'Linux' ]]; then
	if [[ "$(uname -m)" == 'i686' ]]; then
		BESMAN_PLATFORM+='32'
	else
		BESMAN_PLATFORM+='64'
	fi
fi
export BESMAN_PLATFORM

# OS specific support (must be 'true' or 'false').
cygwin=false
darwin=false
solaris=false
freebsd=false
case "${BESMAN_PLATFORM}" in
	CYGWIN*)
		cygwin=true
		;;
	Darwin*)
		darwin=true
		;;
	SunOS*)
		solaris=true
		;;
	FreeBSD*)
		freebsd=true
esac

# Determine shell
zsh_shell=false
bash_shell=false

if [[ -n "$ZSH_VERSION" ]]; then
	zsh_shell=true
else
	bash_shell=true
fi

# Source besman module scripts and environment files.
#
# Extension files are prefixed with 'besman-' and found in the env/ folder.
# Use this if environments are written with the functional approach and want
# to use functions in the main besman script. For more details, refer to
# <https://github.com/besman/besman-extensions>.
OLD_IFS="$IFS"
IFS=$'\n'
scripts=($(find "${BESMAN_DIR}/src" "${BESMAN_DIR}/envs" -type f -name 'besman-*'))
for f in "${scripts[@]}"; do
	source "$f"
done
IFS="$OLD_IFS"
unset scripts f
# Load the besman config if it exists.
if [ -f "${BESMAN_DIR}/etc/config" ]; then
	source "${BESMAN_DIR}/etc/config"
fi

unset OLD_IFS candidate_name candidate_dir
export PATH
