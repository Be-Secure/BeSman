#!/usr/bin/env bash

function __besman_source_env_parameters
{

  local environment=$1

  local env_config="$HOME/besman-$environment.yml"

  local local_vars_flag env_vars_flag key value line tmp_var_file

  tmp_var_file=$HOME/tmp_var_file.sh

  sed -i '/^[[:space:]]*$/d' $env_config

  local_vars_flag=false
  env_vars_flag=false
  [[ -f $tmp_var_file ]] && rm $tmp_var_file
  while read line;
  do
    key=""
    value=""
    if echo $line | grep -qw "local_vars:"
    then
 
        local_vars_flag=true
        continue
    
    elif echo $line | grep -qw "env_vars:"
    then
        local_vars_flag=false
        env_vars_flag=true
        continue

    elif echo $line | grep -qw "\-\-\-"
    then   
        continue
    
    fi

    key=$(echo $line | sed "s/ //g" | cut -d ":" -f 1 | cut -d "-" -f 2)
    value=$(echo $line | sed "s/ //g" | cut -d ":" -f 2)
    
    if [[ $local_vars_flag == true ]]; then

        echo "$key=$value" >> $tmp_var_file
    
    elif [[ $env_vars_flag == true ]]; then

        echo "export $key=$value" >> $tmp_var_file

    elif [[ (( $local_vars_flag == false )) && (( $env_vars_flag == false )) ]]; then

        echo "error"
        return 1

    fi

  done < $env_config

  source $tmp_var_file  

  
}

function __besman_unset_env_parameters
{
  
  local tmp_var_file=$HOME/tmp_var_file.sh

  sed -i "s/export//g" $tmp_var_file

  unset $(awk -F'=' '{print $1}' $tmp_var_file)

  [[ -f $tmp_var_file ]] && rm $tmp_var_file

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