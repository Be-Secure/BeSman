#!/usr/bin/env bash

function __bes_publish() 
{

 local playbookdir="$HOME/$BESMAN_PLAYBOOK_REPO"
 local patchdir="$HOME/$BESMAN_PATCH_REPO"
 local env_dir="$HOME/$BESMAN_ENV_REPO"
 local filename=$1


 if [[ -d "$playbookdir" ]]; then

         cd $playbookdir

         __besman_gh_issue_create $filename
         if [[ ! -z $issue_id  ]]; then
                 __besman_gh_pr_create $filename  $issue_id

         fi
 else
         __besman_echo_red "Could not find repository/playbook"
 fi

 unset playbookdir patchdir env_dir filename
}

