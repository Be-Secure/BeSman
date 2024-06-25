#!/bin/bash

function __bes_reset
{
    local environment version
	local roles_config_file=$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_NAME-roles-config.yml
    environment=$1
    env_config="besman-$environment-config.yaml"
    version=$(cat "${BESMAN_DIR}/envs/besman-${environment}/current")

    if [[ ! -d "$BESMAN_DIR/envs/besman-$environment" ]]; then
        __besman_echo_red "Please install the environment first"
    fi
    if [[ -f "$HOME/$env_config" ]]; then
        
        env_config_path="$HOME/$env_config"
    
    elif [[ -f $BESMAN_DIR/tmp/$env_config ]]; then

        env_config_path=$BESMAN_DIR/tmp/$env_config

    fi
    __besman_get_default_config_file "$environment" "$env_config_path"
    __besman_source_env_params "$environment" "$version"
    [[ -f "$roles_config_file" ]] && rm "$roles_config_file"
    __besman_create_roles_config_file
    __besman_echo_yellow "Resetting..."
    __besman_reset
   
    if [[ "$?" -eq 0 ]]; then
        __besman_echo_green "Reset Successful"
    else
        __besman_echo_red "Reset failed"
    fi

    unset environment version

    
}

function __besman_get_default_config_file()
{
    __besman_echo_yellow "Getting the default config file"
    local environment env_config_path env_repo_namespace env_repo version
    environment=$1
    env_config_path=$2
    env_repo_namespace=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 1)
	env_repo=$(echo "$BESMAN_ENV_REPOS" | cut -d "/" -f 2)
	env_type=$(echo "$environment" | rev | cut -d "-" -f 2 | rev)
	if  echo "$environment" | grep -qE 'RT|BT'
	then
		ossp=$(echo "$environment" | sed -E 's/-(RT|BT)-env//')
	else
		ossp=$(echo "$environment" | cut -d "-" -f 1)

	fi    
    version=$(cat "${BESMAN_DIR}/envs/besman-${environment}/current")
    config_url="https://raw.githubusercontent.com/${env_repo_namespace}/${env_repo}/$BESMAN_ENV_REPO_BRANCH/${ossp}/${version}/besman-${ossp}-${env_type}-env-config.yaml"

    [[ -f "$env_config_path" ]] && rm "$env_config_path"
    touch "$env_config_path"
    if ! __besman_secure_curl "$config_url" >> "$env_config_path";
    then
        __besman_echo_red "Failed while trying to get the besman-${ossp}-${env_type}-env-config.yaml" 
        return 1
    fi

}