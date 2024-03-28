#!/usr/bin/env bash

function __besman_source_env_params
{
    local  key value line tmp_var_file environment env_config
    environment=$1
    env_config="besman-$environment-config.yaml"
    
    # checks whether user configuration exists
    if [[ -f $HOME/$env_config ]]; then
        
      export BESMAN_ENV_CONFIG_FILE_PATH=$HOME/$env_config
      __besman_echo_yellow "Sourcing user config parameters from $BESMAN_ENV_CONFIG_FILE_PATH"
    
    elif [[ -f $BESMAN_DIR/tmp/$env_config ]]; then
      export BESMAN_ENV_CONFIG_FILE_PATH=$BESMAN_DIR/tmp/$env_config
      __besman_echo_yellow "Sourcing default config parameters"
    else
		__besman_download_default_configations "$environment" || return 1
      export BESMAN_ENV_CONFIG_FILE_PATH=$BESMAN_DIR/tmp/$env_config
      __besman_echo_yellow "Sourcing default config parameters"
	fi
    

    # creating a temporary shell script file for exporting variables from config file.
    # Otherwise the '$' variables inside the config file wont be replaced with the actual value.
    tmp_var_file="$BESMAN_DIR/tmp/$environment-config.sh"
    touch "$tmp_var_file"
    echo "#!/bin/bash" >> "$tmp_var_file"
    while read -r line; 
    do
        [[ $line == "---" ]] && continue # To skip the --- from starting of yaml file
        if echo "$line" | grep -qe "^#" 
        then
          continue 
        fi
        if echo "$line" | grep -qe "^BESMAN_"; then # Check to export only environment variables starting with BESMAN_

            key=$(echo "$line" | cut -d ":" -f 1) # For getting the var name
            value=$(echo "$line" | cut -d ":" -f 2- | cut -d " " -f 2) # For getting the value.
            unset "$key"
            echo "export $key=$value" >> "$tmp_var_file"
        else
            continue
        fi
        
    done < "$BESMAN_ENV_CONFIG_FILE_PATH"
    
    source "$tmp_var_file"
    [[ -f $tmp_var_file ]] && rm "$tmp_var_file"

}

function __besman_unset_env_parameters_and_cleanup()
{
    local environment ossp 
    environment=$1
    ossp=$(echo "$environment" | cut -d "-" -f 1)
    while read -r line; 
    do
        # To skip comments
        if echo "$line" | grep -qe "^#" ; then

          continue
        fi

        [[ $line == "---" ]] && continue # To skip the --- from starting of yaml file
        if echo "$line" | grep -qe "^BESMAN_"; then # Check to export only environment variables starting with BESMAN_

            key=$(echo "$line" | cut -d ":" -f 1) # For getting the var name
            unset "$key"
        else
            continue
        fi
        
    done < "$BESMAN_ENV_CONFIG_FILE_PATH"

    [[ -f $BESMAN_DIR/tmp/besman-$environment-config.yaml ]] && rm "$BESMAN_ENV_CONFIG_FILE_PATH"
    [[ -d $BESMAN_DIR/tmp/$ossp ]] && rm -rf "$BESMAN_DIR/tmp/$ossp"
}

function __besman_check_environment_exists()
{
  local input_environment environment_name
  input_environment=$1
  environment_name=$(echo "$input_environment" | cut -d "/" -f 3)
  [[ ! -f $BESMAN_DIR/envs/besman-$environment_name.sh ]] && __besman_echo_red "Environment $environment_name does not exist" && return 1
}


function __besman_check_input_env_format
{
  local environment=$1

  if [[ $(echo $environment | sed  "s/\// /g" | wc -w) -eq 3 ]]; then
    
    __besman_echo_red "Incorrect format for environment name."
    return 1

  fi
  unset environment
}

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
    if [[ $c == "n" || $c == "no" || $c == "N" || $c == "NO" ]]; then
      __besman_echo_no_colour "Exiting!!!"
      return 1
    else
      return 0
    fi
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
    __besman_echo_no_colour "Please run the command again after exporting your Github id"
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

  else
    
    return 0
  fi
}

function __besman_open_file
{
    local file=$1

    if [[ -n $(which jupyter) ]]; then
        __besman_echo_yellow "Opening file in Jupyter notebook"
        jupyter notebook $file
    elif [[ -n $(which code) ]]; then
        __besman_echo_yellow "Opening file in VS Code"
        code $file
    fi
}   


function __besman_validate_environment
{
	local environment_name input_environment_name namespace repo
  environment_name=$1

	if ! grep -q "${environment_name}" "$BESMAN_DIR/var/list.txt"
  then

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

function __besman_download_default_configations()
{
	local environment_name env_repo_namespace env_repo ossp env_url default_config_path curl_flag config_url
	env_repo_namespace=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 1)
	env_repo=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 2)
	environment_name=$1
	ossp=$(echo "$environment_name" | cut -d "-" -f 1)
	config_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/master/${ossp}/${version_id}/besman-$environment_name-config.yaml"
	default_config_path=$BESMAN_DIR/tmp/besman-$environment_name-config.yaml

	[[ -f "$default_config_path" ]] && rm "$default_config_path"
	touch "$default_config_path"

	__besman_check_url_valid "$config_url" 
	if [[ $? -eq 1 ]]
	then
		return 1
	fi
	__besman_secure_curl "$config_url" >> "$default_config_path"

}