#!/bin/bash

function __bes_update {
	local environment=$1
	local roles_config_file=$BESMAN_ARTIFACT_TRIGGER_PLAYBOOK_PATH/$BESMAN_ARTIFACT_NAME-roles-config.yml

	if [[ -n $environment ]]; then
		if [[ ! -d "$BESMAN_DIR/envs/besman-$environment" ]]; then
			__besman_echo_red "Please install the environment first"
		fi
		[[ -f "$BESMAN_DIR/tmp/$environment-config.sh" ]] && rm "$BESMAN_DIR/tmp/$environment-config.sh"
		__besman_source_env_params "$environment"
		[[ -f "$roles_config_file" ]] && rm "$roles_config_file"
		__besman_create_roles_config_file
		__besman_update_"$environment"
		if [[ "$?" -ne 0 ]]; then
			__besman_echo_red "Update failed"
		else
			__besman_echo_green "Update successful"
		fi
	# else

	# 	if [[ ! -f $BESMAN_DIR/var/list.txt ]]; then
	# 		__besman_echo_red "Update failed"
	# 		__besman_echo_red "Could not find list file in your system."
	# 		__besman_echo_red "Please reinstall BeSman and try again"
	# 		return 1
	# 	fi

	# 	[[ -f $BESMAN_DIR/etc/user-config.cfg ]] && source "$BESMAN_DIR/bin/besman-init.sh"

	# 	check_value_for_repo_env_var || return 1

	# 	local env_repos namespace repo_name remote_list_url cached_list diff delta flag=0
	# 	cached_list=$BESMAN_DIR/var/list.txt
	# 	#sort -u $BESMAN_DIR/var/list.txt  >> $HOME/sorted_local_list.txt
	# 	env_repos=$(echo $BESMAN_ENV_REPOS | sed 's/,/ /g')

	# 	for i in ${env_repos[@]}; do
	# 		namespace=$(echo $i | cut -d "/" -f 1)
	# 		repo_name=$(echo $i | cut -d "/" -f 2)
	# 		sort -u $BESMAN_DIR/var/list.txt >>$HOME/sorted_local_list.txt

	# 		if [[ $namespace == $BESMAN_NAMESPACE && $repo_name == "besman-env-repo" ]]; then
	# 			continue
	# 		fi

	# 		if curl -s https://api.github.com/repos/$namespace/$repo_name | grep -q "Not Found"; then
	# 			continue
	# 		fi

	# 		remote_list_url="https://raw.githubusercontent.com/$namespace/$repo_name/master/list.txt"
	# 		__besman_secure_curl "$remote_list_url" >>$HOME/remote_list.txt
	# 		remote_list=$(cat $HOME/remote_list.txt)
	# 		if [[ -z $remote_list ]]; then
	# 			__besman_echo_red "Update failed"
	# 			__besman_echo_red "Remote list corrupeted!!!!"
	# 			[[ -f $HOME/remote_list.txt ]] && rm $HOME/remote_list.txt
	# 			[[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt
	# 			unset env_repos namespace repo_name remote_list_url cached_list diff delta flag
	# 			return 1
	# 		fi

	# 		sort -u $HOME/remote_list.txt >>$HOME/sorted_remote_list.txt
	# 		diff=$(comm -13 $HOME/sorted_local_list.txt $HOME/sorted_remote_list.txt)
	# 		if [[ -n $diff ]]; then
	# 			flag=1
	# 			__besman_echo_no_colour "" >>$cached_list
	# 			# cat $HOME/sorted_remote_list.txt >> $cached_list
	# 			for i in ${diff[@]}; do
	# 				echo $i >>$cached_list
	# 			done
	# 		else
	# 			#Condition where it check if there is any difference between remote repo and local repo==
	# 			diff_remote=$(comm -13 $HOME/sorted_remote_list.txt $HOME/sorted_local_list.txt | grep $repo_name)
	# 			if [[ -n $diff_remote ]]; then
	# 				__besman_echo_no_colour "" >>$cached_list
	# 				for i in ${diff_remote[@]}; do
	# 					environment_name=$(echo $i | cut -d "/" -f 3 | cut -d "," -f 1)
	# 					version_name=$(echo $i | cut -d "," -f 2)
	# 					#grep -v "$environment_name" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
	# 					#grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
	# 					#flag=2
	# 					# Since there is difference between remote repo and local repo, Respective envrioment files and foler will be uninstalled
	# 					# __bes_uninstall $environment_name $version_name
	# 					if [ -d $BESMAN_DIR/envs/besman-$environment_name ]; then
	# 						grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
	# 						rm -rf $BESMAN_DIR/envs/besman-$environment_name.sh
	# 						flag=2
	# 						__besman_echo_yellow "besman-$environment_name has been removed and is no longer available for installation"
	# 					fi
	# 					if [ ! -d $BESMAN_DIR/envs/besman-$environment_name ]; then
	# 						grep -v "$i" $cached_list >$HOME/tmpfile && mv $HOME/tmpfile $cached_list
	# 						rm -rf $BESMAN_DIR/envs/besman-$environment_name.sh
	# 						flag=2
	# 					fi
	# 				done

	# 			else

	# 				[[ -f $HOME/remote_list.txt ]] && rm $HOME/remote_list.txt
	# 				[[ -f $HOME/sorted_remote_list.txt ]] && rm $HOME/sorted_remote_list.txt
	# 				[[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt
	# 				continue
	# 			fi
	# 		fi
	# 		[[ -f $HOME/remote_list.txt ]] && rm $HOME/remote_list.txt
	# 		[[ -f $HOME/sorted_remote_list.txt ]] && rm $HOME/sorted_remote_list.txt
	# 		[[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt
	# 		#if [ -n "$flag" ]
	# 		# check_for_changes $flag
	# 		#fi

	# 	done

	# 	#[[ -f $HOME/sorted_local_list.txt ]] && rm $HOME/sorted_local_list.txt

	# 	check_for_changes $flag
	# 	# unset env_repos namespace repo_name remote_list_url cached_list diff delta flag environment_name version_name diff_remote

	fi
	unset env_repos namespace repo_name remote_list_url cached_list diff delta flag environment_name version_name diff_remote environment
}
##check this again
function check_value_for_repo_env_var {
	if [[ -z $BESMAN_ENV_REPOS ]]; then
		__besman_echo_no_colour "No user repos found"
		return 1
	fi
}

function check_for_changes {
	local flag=$1
	if [[ $flag -eq 1 ]]; then
		__besman_echo_white "Updated successfully."
		__besman_echo_no_colour ""
		__besman_echo_white "Please run the below command to see the updated list"
		__besman_echo_yellow "$ bes list"
	elif [[ $flag -eq 2 ]]; then
		__besman_echo_white "removed successfully."
		__besman_echo_no_colour ""
		__besman_echo_white "Please run the below command to see the updated list"
		__besman_echo_yellow "$ bes list"
	else
		__besman_echo_no_colour "No updates found"
	fi
}
