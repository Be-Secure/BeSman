#!/usr/bin/env bash

function __bes_modify
 {

 local playbookdir="$HOME/$BESMAN_PLAYBOOK_REPO"
 local filename=$1

 if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then
         cd $playbookdir

         __besman_open_file $playbookdir || return 1

 else
         __besman_echo_red "Could not find repository/playbook"
 fi

 unset playbookdir filename

}
