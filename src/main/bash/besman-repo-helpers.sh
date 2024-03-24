#!/bin/bash

function __besman_check_vcs_exist()
{
    if [[ "$BESMAN_VCS"="git" ]]
    then
        __besman_check_for_git || return 1
    elif [[ "$BESMAN_VCS"="gh" ]]
    then
        __besman_check_for_gh || return 1
    fi
}

function __besman_check_for_git()
{
    if [[ -z $(which git) ]]; then
        __besman_echo_red "git not found. Please install and try again"
        return 1
    else
        return 0
    fi

}

function __besman_check_for_gh
{
    if [[ -z $(which gh) ]]; then
        __besman_echo_red "GitHub CLI - gh not found. Please install and try again"
        return 1
    else
        return 0
    fi
}

function __besman_check_vcs_auth
{
    if [[ "$BESMAN_VCS"="git" ]]
    then
        __besman_git_auth || return 1
    elif [[ "$BESMAN_VCS"="gh" ]]
    then
        __besman_gh_auth || return 1
    fi
}

function __besman_git_auth()
{
    local username
    username=$(git config -l | grep "user.name" | cut -d "=" -f 2)

    if [[ -z "$username" ]]
    then
        __besman_echo_yellow "git user not configured"
        __besman_echo_no_colour "Please use the below command to configure git"
        __besman_echo_no_colour ""
        __besman_echo_yellow "git config --global user.name "Your Name""
        __besman_echo_yellow "git config --global user.email "you@example.com""
        return 1
    elif [[ ( -n "$username" ) && ( "$username" != "$BESMAN_USER_NAMESPACE" ) ]]
    then
        __besman_echo_red "git user not authenticated as $BESMAN_USER_NAMESPACE"
        return 1
    fi
}

function __besman_gh_auth
{
    local namespace 
    namespace=$1
    __besman_gh_auth_status "$namespace"
    [[ "$?" -eq 0 ]] && echo "gh user already authenticated" && return 0
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
        [[ -f $HOME/gh_auth_out.txt ]] && rm $HOME/gh_auth_out.txt
        return 0
    else
        [[ -f $HOME/gh_auth_out.txt ]] && rm $HOME/gh_auth_out.txt
        return 1
    fi
    
}


function __besman_git_pull
{   
    [[ ! -d .git ]] && __besman_echo_red "Not a git repo" && return 1
    local remote branch out_flag
    remote=$1
    branch=$2
    out_flag=1
    git pull $remote $branch >> $HOME/pull.out
    if cat $HOME/pull.out | grep -q "up to date"
    then
        [[ $out_flag -eq 1 ]] && rm $HOME/pull.out
        return 2
    elif cat $HOME/pull.out | grep -q "error"
    then 
        out_flag=0
        __besman_echo_white "Please check $HOME/pull.out for logs"
        return 1
    else
        [[ $out_flag -eq 1 ]] && rm $HOME/pull.out
        return 0
    fi

    unset remote branch out_flag
}

function __besman_repo_clone()
{
    local namespace repo path
    namespace=$1
    repo=$2
    path=$3
    if [[ "$BESMAN_VCS" == "git" ]]
    then
        __besman_git_clone "$namespace" "$repo" "$path" || return 1
    elif [[ "$BESMAN_VCS" == "gh" ]]
    then
        __besman_gh_clone "$namespace" "$repo" "$path" || return 1
    fi
    
}

function __besman_git_clone()
{
    local namespace repo path
    namespace=$1
    repo=$2
    path=$3
    git clone "$BESMAN_CODE_COLLAB_URL/$namespace/$repo" "$path"
}

function __besman_gh_clone
{
    local namespace=$1
    local repo=$2
    local clone_path=$3
    gh repo clone $namespace/$repo $clone_path -- -q
    [[ "$?" -eq 1 ]] && return 1
    unset namespace repo clone_path

}

function __besman_gh_quiet_clone
{
    local namespace=$1
    local repo=$2
    local clone_path=$3
    gh repo clone $namespace/$repo $clone_path -- --quiet
    [[ "$?" -eq 1 ]] && return 1
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
