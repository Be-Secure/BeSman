#!/usr/bin/env bash

function __bes_open() 
{

 local playbookdir="$HOME/$BESMAN_PLAYBOOK_REPO"
 local patchdir="$HOME/$BESMAN_PATCH_REPO"
 local env_dir="$HOME/$BESMAN_ENV_REPO"
# local filename=$1

 
# if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then
 if [[ -d "$playbookdir" ]]; then
	__besman_open_file $playbookdir

 else
         __besman_echo_red "Could not find repository/playbook"
 fi

 unset playbookdir patchdir env_dir filename
}

