#!/usr/bin/env bash

function __bes_mod() {
 local playbookdir="$HOME/$BESMAN_PLAYBOOK_REPO"
 local filename=$1

 if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then
         cd $playbookdir

         __besman_open_file $playbookdir || return 1
         __besman_git_stage $filename || return 1


         __besman_git_commit "Playbook $filename modified" || return 1
         __besman_git_push origin main
         __besman_echo_green "Edit success"

 else
         __besman_echo_red "Could not find repository/playbook"
 fi
 unset playbookdir filename
}


