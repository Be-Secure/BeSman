#!/usr/bin/env bash

function __besman_validate_playbook_type
{

 local filename=$1
 echo $filename | grep -qe "untitled"
 [[ $? -eq  0 ]] && __besman_echo_red "File name should not contain the term, untitled!!!" && return 1
 unset filename
}


function __bes_save() {
 local playbookdir="$HOME/besecure-ce-playbook-repo"
 local filename=$1

 if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then  
	 __besman_validate_playbook_type $filename || return 1

	 cd $playbookdir
	 git add $filename && git commit -m "Playbook - $filename created"
 	 git push origin main
 else
	 __besman_echo_red "Could not find repository/playbook"
 fi
 unset playbookdir filename
}

