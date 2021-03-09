#!/usr/bin/env bash


function __besman_check_parameter_present
{

  local environment=$1
  local version=$2

  if [[ $environment == "all" ]]; then
    return 0
  fi

  if [[ ! -d $BESMAN_DIR/envs/besman-$environment ]]; then
    __besman_echo_red "$environment is not installed in your local system"
    return 1
  fi
  
  if [[ ! -d $BESMAN_DIR/envs/besman-$environment/$version ]]; then
    __besman_echo_red "Version $version for $environment is not installed in your system."
    return 1
  fi
  
}


function __besman_interactive_uninstall
{
  if [[ $BESMAN_INTERACTIVE_USER_MODE = "true" ]]; then
    read -p "Would you like to proceed?(y/n):" c
    if [[ $c == "n" ]]; then
      __besman_echo_no_colour "Exiting!!!"
      return 1
    else
      return 0
    fi
  else
    return 0
  fi
}

function __besman_check_ssh_key
{
  if [[ ! -f $HOME/besman_ssh || ! -f $HOME/besman_ssh.pub ]]; then
    __besman_echo_no_colour "No ssh key found."
    __besman_echo_no_colour ""
    __besman_echo_no_colour "Follow the instructions in the below link to generate an ssh key and link it with your remote"
    __besman_echo_no_colour ""
    __besman_echo_yellow "https://github.com/Be-Secure/BeSman/docs/Generating%20and%20adding%20ssh%20key.md"
    __besman_echo_no_colour ""
    __besman_echo_no_colour "Please try again after generating the ssh key."
    return 1
  else
    return 0
  fi
}

function __besman_create_fork
{
  local environment=$1
  if [[ -z $BESMAN_USER_NAMESPACE ]]; then
    __besman_echo_no_colour "Please run the below command by substituing <namespace> with your GitHub id"
    __besman_echo_no_colour ""
    __besman_echo_white "$ export BESMAN_USER_NAMESPACE=<namespace>"
    __besman_echo_no_colour ""
    __besman_echo_no_colour "Eg: export BESMAN_USER_NAMESPACE=abc123"
    __besman_echo_no_colour ""
    __besman_echo_no_colour "Please run the install command after exporting your Github id"
    __besman_echo_no_colour ""
    __besman_error_rollback "$environment"
    return 1
  fi
  if [[ -z $(which hub) ]]; then
    __besman_echo_no_colour "Installing hub..."
    sudo snap install hub --classic 
  fi
  curl -s https://api.github.com/repos/$BESMAN_USER_NAMESPACE/$environment | grep -q "Not Found"
  if [[ "$?" == "0" ]]; then
    __besman_echo_white "Creating a fork of https://github.com/$BESMAN_NAMESPACE/$environment under your namespace $BESMAN_USER_NAMESPACE"
    git clone -q https://github.com/$BESMAN_NAMESPACE/$environment $BESMAN_NAMESPACE/$environment
    cd $BESMAN_NAMESPACE/$environment
    hub fork
    cd $HOME
    if [[ -d $BESMAN_NAMESPACE/$environment ]]; then
      rm -rf $BESMAN_NAMESPACE/$environment
    fi
    # curl -s https://api.github.com/repos/$BESMAN_USER_NAMESPACE/$environment | grep -q "Not Found"
    # if [[ "$?" == "0" ]]; then
    #   __besman_echo_red "Could not create fork"
    #   __besman_echo_red "Please try again"
    #   __besman_echo_no_colour "Make sure you have given the correct environment name"
    #   __besman_error_rollback "$environment"
    #   return 1
    # fi
  else
    
    return 0
  fi
}

function __besman_download_envs_from_repo
{
  # __besman_echo_white "Downloading environments from external repos"
  local namespace=$1
  local repo_name=$2
  local environment_files namespace repo_name zip_stage_folder remote_zip_url
  zip_stage_folder=$HOME/zip_stage_folder
  mkdir -p $zip_stage_folder
  remote_zip_url="https://github.com/$namespace/$repo_name/archive/master.zip"
  __besman_secure_curl "$remote_zip_url" >> $HOME/$repo_name.zip
  unzip -q $HOME/$repo_name.zip -d $zip_stage_folder
  environment_files=$(find $zip_stage_folder/$repo_name-master -type f -name "besman-*.sh")
  if [[ -z ${environment_files[@]} ]]; then
     rm $HOME/$repo_name.zip
    [[ -d $zip_stage_folder ]] && rm -rf $zip_stage_folder
    unset environment_files namespace repo_name zip_stage_folder remote_zip_url
    return 1
  fi
  for j in ${environment_files[@]}; do
    mv $j $BESMAN_DIR/envs/
  done
  rm $HOME/$repo_name.zip
  [[ -d $zip_stage_folder ]] && rm -rf $zip_stage_folder
  unset environment_files namespace repo_name zip_stage_folder remote_zip_url
  
}
function __besman_validate_environment
{
	local environment_name=$1
	echo ${environment_name} > $BESMAN_DIR/var/current
	cat $BESMAN_DIR/var/list.txt | grep -w "$environment_name" > /dev/null	
	if [ "$?" != "0" ]; then

		__besman_echo_debug "Environment $environment_name does not exist"
		return 1
	fi
}

function __besman_validate_version_format
{	
	local version=$1
	if ! echo "$version" | grep -qE '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
	then
		__besman_echo_debug "Version format you have entered is incorrect"
		__besman_echo_green "Correct format -> 0.0.0 [eg: 0.0.2]"
		return 1
	fi
}

function __besman_check_if_version_exists
{
	local environment_name=$1
	local version=$2
	cat $BESMAN_DIR/var/list.txt | grep -w "${environment_name}" | grep -q ${version}
	if [ "$?" != "0" ]; then

		__besman_echo_debug "${environment_name} $version does not exist"
		return 1
	fi
}
function __besman_error_rollback
{
  local environment=$1
  if [[ -d $BESMAN_DIR/envs/besman-$environment ]]; then
    rm -rf $BESMAN_DIR/envs/besman-$environment
  fi

  if [[ -d $BESMAN_ENV_ROOT ]]; then
    rm -rf $BESMAN_ENV_ROOT
  fi

}
