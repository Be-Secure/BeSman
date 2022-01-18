#!/usr/bin/env bash

function __bes_publish()
{

 local playbookdir="$HOME/$BESMAN_PLAYBOOK_REPO"
 local filename=$1

 if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then

         cd $playbookdir
         __besman_gh_pr $filename
 else
         __besman_echo_red "Could not find repository/playbook"
 fi
 unset playbookdir filename
}
