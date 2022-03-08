#!/bin/bash

function __besman_gh_auth
{
    if [[ -z $BESMAN_GH_TOKEN ]]; then

        cat <<EOF

Missing personal access token. Please follow the below steps.
1. Open link https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
2. Create a personal access token with the following permissions:
    - repo
    - workflow
    - read:org
3. Copy the token.
4. In terminal, run the below command
EOF

        __besman_echo_yellow "$ export BESMAN_GH_TOKEN=<copied token>"
        return 1
    else
        echo $BESMAN_GH_TOKEN > $HOME/token.txt
        gh auth login --with-token < $HOME/token.txt
        [[ -f $HOME/token.txt ]] && rm $HOME/token.txt
    fi
   
}
function __besman_gh_auth_status 
{
    local namespace=$1
    gh auth status &>> $HOME/gh_auth_out.txt
    if cat $HOME/gh_auth_out.txt | grep -q "$namespace"
    then
        return 0
    else
        return 1
    fi
    [[ -f $HOME/gh_auth_out.txt ]] && rm $HOME/gh_auth_out.txt
}

function __besman_gh_clone
{
    local namespace=$1
    local repo=$2
    local clone_path=$3
    gh repo clone $namespace/$repo $clone_path -- -q
    unset namespace repo clone_path

}

function __besman_gh_quiet_clone
{
    local namespace=$1
    local repo=$2
    local clone_path=$3
    gh repo clone $namespace/$repo $clone_path -- --quiet

    unset namespace repo clone_path
}

function __besman_gh_fork
{
    local namespace=$1
    local repo=$2
    gh repo fork $namespace/$repo --clone=false
}

function __besman_check_github_id
{

    if [[ -z $BESMAN_USER_NAMESPACE ]]; then
        __besman_echo_no_colour "Please run the below command by substituing <namespace> with your GitHub id"
        __besman_echo_no_colour ""
        __besman_echo_white "$ export BESMAN_USER_NAMESPACE=<namespace>"
        __besman_echo_no_colour ""
        __besman_echo_no_colour "Eg: export BESMAN_USER_NAMESPACE=abc123"
        __besman_echo_no_colour ""
        __besman_echo_no_colour "Please run the command again after exporting your Github id"
        __besman_echo_no_colour ""
        # __besman_error_rollback "$environment"
        return 1
    fi
}

