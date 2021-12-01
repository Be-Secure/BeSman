#!/usr/bin/env bash



function __besman_cve_format_check
{
  local cve=$1
  echo "$cve" | grep -qwE "CVE-[0-9]{4}-[0-9]{4,}"
  [[ "$?" != "0" ]] && __besman_echo_red "CVE format incorrect"  && __besman_echo_no_colour "Format: CVE-YYYY-NNNN..." && return 1
  unset cve
}

function __besman_validate_assessment
{
  local type=$1
  assessments=("active" "passive" "external" "internal" "host" "network" "application" "db" "wireless" "distributed" "credentialed" "non-credentialed")
  echo "${assessments[@]}" | grep -qw "$type"
  [[ "$?" != "0" ]] && __besman_echo_red "Could not find assessment type" &&  __besman_echo_no_colour "Select from the following:" && echo "${assessments[@]}" && return 1
  unset type assessments

}

function __besman_validate_playbook_type
{

 local filename=$1
 echo $1 | grep -e "untitled"
 [[ "$?" == "0" ]] && __besman_echo_red "Untitled file name !!!"

}


function __bes_save() {
 local playbookdir="$HOME/besecure-ce-playbook-repo"
 local filename=$1

 if [ -d "$playbookdir" && -f $playbookdir/$filename ]; then  
	 cd $HOME/besecure-ce-playbook-repo
	 git add $filename && git commit -m "Playbook - $filename created"
	 git push origin main
 else
	 __besman_echo_red "Could not find repository/playbook"
 fi

}

