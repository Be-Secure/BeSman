#!/usr/bin/env bash


function __bes_publish() {
 local playbookdir="$HOME/besecure-ce-playbook-repo"
 local filename=$1

 if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then

         cd $playbookdir
         gh pr  create --title "[Publish] Playbook name: $filename"
 else
         __besman_echo_red "Could not find repository/playbook"
 fi
 unset playbookdir filename
}

