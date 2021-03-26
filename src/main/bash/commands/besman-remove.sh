#!/bin/bash

function __bes_remove
{
    __besman_echo_red "This operation would remove the BeSman utility and installed environments"
    __besman_interactive_uninstall || return 1 
     if [[ -d $BESMAN_ENV_ROOT ]]; then
         __besman_echo_no_colour "Removing dev environment"
         rm -rf $BESMAN_ENV_ROOT
     fi
    __besman_secure_curl "https://raw.githubusercontent.com/$BESMAN_NAMESPACE/BeSman/master/dist/environments" >> $HOME/tmp_env_names.txt
    sed -i 's/,/ /g' $HOME/tmp_env_names.txt
    local environment=$(cat $HOME/tmp_env_names.txt)
    for i in $environment; do
        if [[ -d $BESMAN_DIR/envs/besman-$i ]]; then
        __besman_uninstall_$i "$i"
        fi
    done
    [ -f $HOME/tmp_env_names.txt ] && rm $HOME/tmp_env_names.txt
    if [[ -d $BESMAN_DIR ]]; then
        __besman_echo_no_colour "Removing utility..."
        rm -rf $BESMAN_DIR
    fi
    __besman_echo_no_colour "Removing environment variables..."
    unset BESMAN_DIR BESMAN_VERSION BESMAN_NAMESPACE BESMAN_USER_NAMESPACE BESMAN_INTERACTIVE_USER_MODE
    __besman_echo_green "BeSman utility removed successfully."
    sed -i '/.besman/d' $HOME/.bashrc
    exec bash

    

}
