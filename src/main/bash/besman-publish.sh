
#!/usr/bin/env bash

function __bes_publish()
{

 local playbookdir="$HOME/$BESMAN_PLAYBOOK_REPO"
 local patchdir="$HOME/$BESMAN_PATCH_REPO"
 local env_dir="$HOME/$BESMAN_ENV_REPO"
 local filename=$1


 if [[ ( -d "$playbookdir" ) && ( -f $playbookdir/$filename ) ]]; then

         cd $playbookdir
         __besman_gh_issue-pr $filename || return 1

         #if [[ ( ${opts[0]} == "-P" ) || ( ${opts[0]} == "--playbook" ) ]]; then
         #       __besman_gh_issue $filename || return 1
         #fi

 else
         __besman_echo_red "Could not find repository/playbook"
 fi


 unset playbookdir patchdir env_dir filename
}


