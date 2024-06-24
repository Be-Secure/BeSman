#!/bin/bash

function quick_install() {
	local force
	force=$1
	if [[ (-n $force) && (($force == "--force") || ($force == "-F")) ]]; then
		rm -rf "$HOME/.besman"
	elif [[ (-n $force) && (($force != "--force") || ($force != "-F")) ]]; then
		echo "Usage: ./quick_install [--force|-F]"
		echo "--force | -F : Removes the existing installation of BeSman"
		return
	fi
	BESMAN_PLATFORM=$(uname)
	export BESMAN_SERVICE="https://raw.githubusercontent.com"

	# BESMAN_DIST_BRANCH=${BESMAN_DIST_BRANCH:-REL-${BESMAN_VERSION}}

	BESMAN_NAMESPACE="Be-Secure"
	BESMAN_VERSION="$(git branch --show-current)"
	BESMAN_ENV_REPOS="$BESMAN_NAMESPACE/besecure-ce-env-repo"

	if [ -z "$BESMAN_DIR" ]; then
		export BESMAN_DIR="$HOME/.besman"
	fi

	if [[ -z "$BESMAN_CODE_COLLAB_URL" ]]; then
		export BESMAN_CODE_COLLAB_URL="https://github.com"
	fi

	if [[ -z "$BESMAN_VCS" ]]; then
		export BESMAN_VCS="git"
	fi

	# variables
	besman_bin_folder="${BESMAN_DIR}/bin"
	besman_src_folder="${BESMAN_DIR}/src"
	besman_tmp_folder="${BESMAN_DIR}/tmp"
	besman_stage_folder="${besman_tmp_folder}/stage"
	besman_zip_file="${besman_tmp_folder}/besman-${BESMAN_VERSION}.zip"
	besman_env_folder="${BESMAN_DIR}/envs"
	besman_stage_folder="${besman_tmp_folder}/stage"
	besman_etc_folder="${BESMAN_DIR}/etc"
	besman_var_folder="${BESMAN_DIR}/var"
	besman_config_file="${besman_etc_folder}/config"
	besman_user_config_file="${besman_etc_folder}/user-config.cfg"
	besman_bash_profile="${HOME}/.bash_profile"
	besman_profile="${HOME}/.profile"
	besman_bashrc="${HOME}/.bashrc"
	besman_zshrc="${HOME}/.zshrc"
	besman_scripts_folder="$BESMAN_DIR/scripts"
	besman_playbook_dir="$BESMAN_DIR/playbooks"

	besman_init_snippet=$(
		cat <<EOF
#THIS MUST BE AT THE END OF THE FILE FOR BESMAN TO WORK!!!
export BESMAN_DIR="$BESMAN_DIR"
[[ -s "${BESMAN_DIR}/bin/besman-init.sh" ]] && source "${BESMAN_DIR}/bin/besman-init.sh"
EOF
	)

	# OS specific support (must be 'true' or 'false').
	cygwin=false
	darwin=false
	solaris=false
	freebsd=false
	case "$(uname)" in
	CYGWIN*)
		cygwin=true
		;;
	Darwin*)
		darwin=true
		;;
	SunOS*)
		solaris=true
		;;
	FreeBSD*)
		freebsd=true
		;;
	esac

	# Sanity checks

	echo "Looking for a previous installation of BeSman..."
	if [ -d "$BESMAN_DIR/bin" ]; then
		echo "BeSman found."
		echo ""
		echo "======================================================================================================"
		echo " You already have BeSman installed."
		echo " BeSman was found at:"
		echo ""
		echo "    ${BESMAN_DIR}"
		echo ""
		echo " Please consider running the following if you need to upgrade."
		echo ""
		echo "    $ bes selfupdate force"
		echo ""
		echo "======================================================================================================"
		echo ""
		exit 0
	fi
	echo ' BBBBBBBBBBBBBBBBB                         SSSSSSSSSSSSSSS                                                             '
	echo ' B::::::::::::::::B                      SS:::::::::::::::S                                                            '
	echo ' B::::::BBBBBB:::::B                    S:::::SSSSSS::::::S                                                            '
	echo ' BB:::::B     B:::::B                   S:::::S     SSSSSSS                                                            '
	echo '   B::::B     B:::::B    eeeeeeeeeeee   S:::::S               mmmmmmm    mmmmmmm     aaaaaaaaaaaaa  nnnn  nnnnnnnn     '
	echo '   B::::B     B:::::B  ee::::::::::::ee S:::::S             mm:::::::m  m:::::::mm   a::::::::::::a n:::nn::::::::nn   '
	echo '   B::::BBBBBB:::::B  e::::::eeeee:::::eeS::::SSSS         m::::::::::mm::::::::::m  aaaaaaaaa:::::an::::::::::::::nn  '
	echo '   B:::::::::::::BB  e::::::e     e:::::e SS::::::SSSSS    m::::::::::::::::::::::m           a::::ann:::::::::::::::n '
	echo '   B::::BBBBBB:::::B e:::::::eeeee::::::e   SSS::::::::SS  m:::::mmm::::::mmm:::::m    aaaaaaa:::::a  n:::::nnnn:::::n '
	echo '   B::::B     B:::::Be:::::::::::::::::e       SSSSSS::::S m::::m   m::::m   m::::m  aa::::::::::::a  n::::n    n::::n '
	echo '   B::::B     B:::::Be::::::eeeeeeeeeee             S:::::Sm::::m   m::::m   m::::m a::::aaaa::::::a  n::::n    n::::n '
	echo '   B::::B     B:::::Be:::::::e                      S:::::Sm::::m   m::::m   m::::ma::::a    a:::::a  n::::n    n::::n '
	echo ' BB:::::BBBBBB::::::Be::::::::e         SSSSSSS     S:::::Sm::::m   m::::m   m::::ma::::a    a:::::a  n::::n    n::::n '
	echo ' B:::::::::::::::::B  e::::::::eeeeeeee S::::::SSSSSS:::::Sm::::m   m::::m   m::::ma:::::aaaa::::::a  n::::n    n::::n '
	echo ' B::::::::::::::::B    ee:::::::::::::e S:::::::::::::::SS m::::m   m::::m   m::::m a::::::::::aa:::a n::::n    n::::n '
	echo ' BBBBBBBBBBBBBBBBB       eeeeeeeeeeeeee  SSSSSSSSSSSSSSS   mmmmmm   mmmmmm   mmmmmm  aaaaaaaaaa  aaaa nnnnnn    nnnnnn '

	if [[ "$solaris" == true ]]; then
		echo "Looking for gsed..."
		if [ -z "$(which gsed)" ]; then
			echo "Not found."
			echo ""
			echo "======================================================================================================"
			echo " Please install gsed on your solaris system."
			echo ""
			echo " BeSman uses gsed extensively."
			echo ""
			echo " Restart after installing gsed."
			echo "======================================================================================================"
			echo ""
			exit 1
		fi
	else
		echo "Looking for sed..."
		if [ -z "$(which sed)" ]; then
			echo "Not found."
			echo ""
			echo "======================================================================================================"
			echo " Please install sed on your system using your favourite package manager."
			echo ""
			echo " Restart after installing sed."
			echo "======================================================================================================"
			echo ""
			exit 1
		fi
	fi

	if [[ -z $(which ansible) ]]; then
		echo "Installing ansible"
		sudo apt-add-repository -y ppa:ansible/ansible
		sudo apt update
		sudo apt install ansible -y
	fi

	if [[ -z $(which gh) ]]; then
		echo "Installing GitHub Cli"
		type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
		curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
		sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
		sudo apt update
		sudo apt install gh -y

	fi

	if [[ -z $(command -v jq) ]]; then
		echo "Installing jq"
		sudo apt update && sudo apt install jq -y
	fi

	if [[ -z $(command -v pip) ]]; then
		echo "Installing pip"
		sudo apt install python3-pip -y
	fi

	if [[ -z $(command -v jupyter) ]]; then
		echo "Installing jupyter notebook"
		python3 -m pip install notebook
	fi

	if ! pip list | grep PyYAML; then
		echo "Installing pyYAML"
		python3 -m pip install pyYAML
	fi

	echo "Installing BeSMAN scripts..."

	# Create directory structure

	echo "Create distribution directories..."
	mkdir -p "$besman_bin_folder"
	mkdir -p "$besman_src_folder"
	mkdir -p "$besman_tmp_folder"
	mkdir -p "$besman_stage_folder"
	mkdir -p "$besman_env_folder"
	mkdir -p "$besman_etc_folder"
	mkdir -p "$besman_var_folder"
	mkdir -p "$besman_scripts_folder"
	mkdir -p "$besman_playbook_dir"

	echo "Prime the config file..."
	echo "config selfupdate/debug_mode = true"

	touch "$besman_config_file"
	{
		echo "besman_auto_answer=false"
		echo "besman_auto_selfupdate=false"
		echo "besman_insecure_ssl=false"
		echo "besman_curl_connect_timeout=7"
		echo "besman_curl_max_time=10"
		echo "besman_beta_channel=false"
		echo "besman_debug_mode=true"
		echo "besman_colour_enable=true"
	} >>"$besman_config_file"

	echo "Setting up user configs"
	touch "$besman_user_config_file"
	{
		echo "BESMAN_VERSION=$BESMAN_VERSION"
		echo "BESMAN_USER_NAMESPACE="
		echo "BESMAN_CODE_COLLAB_URL=$BESMAN_CODE_COLLAB_URL"
		echo "BESMAN_VCS=$BESMAN_VCS"
		echo "BESMAN_ENV_ROOT=$HOME/BeSman_env"
		echo "BESMAN_NAMESPACE=$BESMAN_NAMESPACE"
		echo "BESMAN_INTERACTIVE_USER_MODE=true"
		echo "BESMAN_DIR=$HOME/.besman"
		echo "BESMAN_ENV_REPOS=$BESMAN_ENV_REPOS"
		echo "BESMAN_ENV_REPO_BRANCH=master"
		echo "BESMAN_PLAYBOOK_REPO=$BESMAN_NAMESPACE/besecure-playbooks-store"
		echo "BESMAN_PLAYBOOK_REPO_BRANCH=main"
		echo "BESMAN_GH_TOKEN="
		echo "BESMAN_OFFLINE_MODE=true"
		echo "BESMAN_LOCAL_ENV=false"
		echo "BESMAN_LOCAL_ENV_DIR="
		echo "BESMAN_PLAYBOOK_DIR=$besman_playbook_dir"
	} >>"$besman_user_config_file"

	cp ./src/main/bash/besman-* "$besman_src_folder"
	cp ./src/main/bash/commands/besman-* "$besman_src_folder"
	cp ./src/main/bash/scripts/besman-* "$besman_scripts_folder"
	mv "$besman_src_folder/besman-init.sh" "$besman_bin_folder"

	touch "$besman_var_folder/list.txt"

	echo "Set version to $BESMAN_VERSION ..."
	echo "$BESMAN_VERSION" >"${BESMAN_DIR}/var/version.txt"

	if [[ $darwin == true ]]; then
		touch "$besman_bash_profile"
		echo "Attempt update of login bash profile on OSX..."
		if [[ -z $(grep 'besman-init.sh' "$besman_bash_profile") ]]; then
			echo -e "\n$besman_init_snippet" >>"$besman_bash_profile"
			echo "Added besman init snippet to $besman_bash_profile"
		fi
	else
		echo "Attempt update of interactive bash profile on regular UNIX..."
		touch "${besman_bashrc}"
		if [[ -z $(grep 'besman-init.sh' "$besman_bashrc") ]]; then
			echo -e "\n$besman_init_snippet" >>"$besman_bashrc"
			echo "Added besman init snippet to $besman_bashrc"
		fi
		if [ -f "${besman_profile}" ]; then
			if [[ -z $(grep 'oah-init.sh' "${besman_profile}") ]]; then
				echo -e "\n${besman_init_snippet}" >>"${besman_profile}"
				echo "Updated existing ${besman_profile}"
			fi
		fi
	fi
	echo "Attempt update of zsh profile..."
	touch "$besman_zshrc"
	if [[ -z $(grep 'besman-init.sh' "$besman_zshrc") ]]; then
		echo -e "\n$besman_init_snippet" >>"$besman_zshrc"
		echo "Updated existing ${besman_zshrc}"
	fi

	bash "$BESMAN_DIR/bin/besman-init.sh"

	if [[ "$?" != "0" ]]; then
		echo -e "\n\033[1;31mInstallation failed\033[0m\n"
	else
		echo -e "\n\033[0;32mSuccessfully installed BeSman from branch $BESMAN_VERSION\033[0m\n"
	fi
}
quick_install "$1"
