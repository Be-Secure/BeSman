#!/bin/bash

function __bes_update
{
        if [[ ( -n $1 ) && ( $1 == "--playbook" || $1 == "-P" ) ]]; then
                # perform_sanity_checks || return 1
                # update_playbook_list
                # download_playbook
                # return 
                file_name=playbook_list.txt
                list_file=$BESMAN_DIR/var/$file_name
                external_repo=$BESMAN_PLAYBOOK_REPOS
                playbook_flag=1
                # echo "hello"
           
        
        else
                playbook_flag=0
                file_name=list.txt
                list_file=$BESMAN_DIR/var/$file_name
                external_repo=$BESMAN_ENV_REPOS
        fi

        
        if [[ ! -f $list_file ]]; then
                __besman_echo_red "Update failed"
                __besman_echo_red "Could not find list file in your system."
                __besman_echo_red "Please reinstall BeSman and try again"
                return 1
        fi

        [[ -f $BESMAN_DIR/etc/user-config.cfg ]] && source "$BESMAN_DIR/bin/besman-init.sh"

        check_value_for_repo_env_var || return 1

        local env_repos namespace repo_name remote_list_url cached_list diff delta flag=0
        cached_list=$list_file
        cat $list_file | sort -u >> $HOME/sorted_local_list.txt
        # __besman_echo_red "sorted local list" 
        # cat $HOME/sorted_local_list.txt
        env_repos=$(echo $external_repo | sed 's/,/ /g')

        for i in ${env_repos[@]}; do
        namespace=$(echo $i | cut -d "/" -f 1)
        repo_name=$(echo $i | cut -d "/" -f 2)
        # cat $list_file | sort -u >> $HOME/sorted_local_list.txt
        # __besman_echo_red "sorted local list" 
        # cat $HOME/sorted_local_list.txt
                if [[ $namespace == $BESMAN_NAMESPACE && $repo_name == "besman-env-repo" ]]; then
                        continue
                fi


                if curl -s https://api.github.com/repos/$namespace/$repo_name | grep -q "Not Found"
        then
                continue
        fi

                remote_list_url="https://raw.githubusercontent.com/$namespace/$repo_name/master/$file_name"
                __besman_secure_curl "$remote_list_url" >> $HOME/remote_list.txt
                remote_list=$(cat $HOME/remote_list.txt)
                if [[ -z $remote_list ]]; then
                        __besman_echo_red "Update failed"
                        __besman_echo_red "Remote list corrupeted!!!!"
                        [[ -f $HOME/remote_list.txt ]] && rm $HOME/remote_list.txt
                        [[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt
                        unset env_repos namespace repo_name remote_list_url cached_list diff delta  flag
                        return 1
                fi

                sort -u $HOME/remote_list.txt >> $HOME/sorted_remote_list.txt
                # echo "sorted_remote list"
                # cat $HOME/sorted_remote_list.txt
                # echo "sorted local list"
                # cat $HOME/sorted_local_list.txt
                diff=$(comm -13 $HOME/sorted_local_list.txt $HOME/sorted_remote_list.txt)
                # __besman_echo_red "diff"
                # echo $diff
                if [[ -n $diff ]]; then
                        flag=1
                        __besman_echo_no_colour "" >> $cached_list
                        # cat $HOME/sorted_remote_list.txt >> $cached_list
                        for i in ${diff[@]}; do
                                echo $i >> $cached_list
                        done
                        __besman_download_envs_from_repo $namespace $repo_name $playbook_flag
                else
                        #Condition where it check if there is any difference between remote repo and local repo==
                        diff_remote=$(comm -13 $HOME/sorted_remote_list.txt $HOME/sorted_local_list.txt | grep $repo_name )
                        # __besman_echo_red "diff_remote"
                        # echo $diff_remote
                        if [[ -n $diff_remote ]];then
                                __besman_echo_no_colour "" >> $cached_list
                                for i in ${diff_remote[@]};do
                                        environment_name=$(echo $i | cut -d "/" -f 3 | cut -d "," -f 1)
                                        version_name=$(echo $i | cut -d "," -f 2)
                                        #grep -v "$environment_name" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
                                        #grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
                                        #flag=2
                                        # Since there is difference between remote repo and local repo, Respective envrioment files and foler will be uninstalled
                                       # __bes_uninstall $environment_name $version_name
                                       if [ -d $BESMAN_DIR/envs/besman-$environment_name ]
                                       then
                                         grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
                                         rm -rf $BESMAN_DIR/envs/besman-$environment_name.sh
                                         flag=2
                                         __besman_echo_yellow "besman-$environment_name has been removed and is no longer available for installation"
                                      fi
                                      if [ ! -d $BESMAN_DIR/envs/besman-$environment_name ]
                                      then
                                              grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
                                              rm -rf $BESMAN_DIR/envs/besman-$environment_name.sh
                                              flag=2
                                      fi

                                      if [[ ( $playbook_flag == 1 ) && ( -f $BESMAN_DIR/playbook/$i* ) ]]; then
                                                rm $BESMAN_DIR/playbook/$i*
                                                # __besman_echo_red "Removed playbook $i"
                                                grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
                                                flag=2
                                        fi
                                done


                        else

                                [[ -f $HOME/remote_list.txt ]] && rm $HOME/remote_list.txt
                                [[ -f $HOME/sorted_remote_list.txt ]] && rm $HOME/sorted_remote_list.txt
                               [[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt
                           continue
                        fi
                fi
                [[ -f $HOME/remote_list.txt ]] && rm $HOME/remote_list.txt
                [[ -f $HOME/sorted_remote_list.txt ]] && rm $HOME/sorted_remote_list.txt
                [[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt
                #if [ -n "$flag" ]
                # check_for_changes $flag
                #fi

        done

        #[[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt

        check_for_changes $flag
        unset env_repos namespace repo_name remote_list_url cached_list diff delta flag environment_name version_name diff_remote


}
##check this again
function check_value_for_repo_env_var
{
        if [[ -z $external_repo ]]; then
                __besman_echo_no_colour "No user repos found"
                return 1
        fi
}

function check_for_changes
{
        local flag=$1
        if [[ $flag -eq 1 ]]; then
                __besman_echo_white "Updated successfully."
                __besman_echo_no_colour ""
                __besman_echo_white "Please run the below command to see the updated list"
                if [[ $playbook_flag == 1 ]]; then
                        __besman_echo_yellow "$ bes list --playbook"
                else
                        __besman_echo_yellow "$ bes list"
                fi

        elif [[ $flag -eq 2 ]]; then
                __besman_echo_white "removed successfully."
                __besman_echo_no_colour ""
                __besman_echo_white "Please run the below command to see the updated list"
                if [[ $playbook_flag == 1 ]]; then
                        __besman_echo_yellow "$ bes list --playbook"
                else
                        __besman_echo_yellow "$ bes list"
                fi
                # __besman_echo_yellow "$ bes list"
        else
                __besman_echo_no_colour "No updates found"
        fi


        __besman_echo_no_colour ""

}


# function perform_sanity_checks
# {
#         if [[ -z $BESMAN_PLAYBOOK_REPOS ]]; then
#                 echo "No repository found"
#                 return 1
        
#         fi
# }