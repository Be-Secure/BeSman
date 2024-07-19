#!/usr/bin/env bash

function __bes_verify {
	local environment_name env_repo environment_name version_id env_config

        opts=$1
        args=$2

        [[ "${opts[0]}" != "--file" ]] && [[ "${opts[0]}" != "--path" ]] && __besman_echo_red "Incorrect syntax" && __bes_help_"$command" && return 1

        [[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--file" ]] && filename="${args[1]}"
        [[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--path" ]] &&  __besman_echo_red "Incorrect syntax" && __bes_help_"$command" && return 1
        [[ ${#opts[@]} -eq 2 ]] && [[ "${opts[0]}" == "--path" ]] && filepath="${args[1]}" && filename="${args[2]}"
        [[ ${#opts[@]} -eq 2 ]] && [[ "${opts[1]}" == "--path" ]] && filepath="${args[2]}" && filename="${args[1]}"

        [[ ! -z $filepath ]] && [[ ! -d $filepath ]] && __besman_echo_red "filepath $filepath not found. Exit" && return 1
        [[ ! -z $filepath ]] && [[ ! -f $filepath/$filename ]] && __besman_echo_red "file $filename not found at $filepath. Exit" && return 1
        [[ -z $filepath ]] && [[ ! -f $filename ]] && __besman_echo_red "file $filename not found at $filepath. Exit" && return 1

	if [ ! -z $filepath ];then
          wd=$(pwd)
         cd $filepath 
        fi
        local cosignpub="cosign.pub"
	local sigfile="$filename.sig"
	local attestsigfile="$filename.attest.sig"
	local bundlefile="$filename.bundle"
	local attestbundlefile="$filename.attest.bundle"
	local predicatefile="$filename.predicate.json"
	local sigresult="sigresult"
	local attestresult="attestresult"

	if [[ -z $(which cosign) ]];then
	  # install COSIGN
          LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
          curl --silent -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb" 2>&1>/dev/null
          sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb 2>&1>/dev/null
	  rm -f  cosign_${LATEST_VERSION}_amd64.deb
        fi

	#check if the required files at present at current folder.
	if [ ! -f $filename ] || [ ! -f $cosignpub ] || [ ! -f $attestbundlefile ] || [ ! -f $bundlefile ];then
           __besman_echo_red "Required file/files not found"
           return 1
        fi

        #verify the signature
        cosign verify-blob $filename --key $cosignpub --bundle $bundlefile 2>&1 | tee $sigresult > /dev/null
	#verify the attestation
	cosign verify-blob-attestation $filename --key $cosignpub --bundle $attestbundlefile 2>&1 | tee $attestresult > /dev/null

        sigr=$(cat $sigresult)
	attr=$(cat $attestresult)

	if grep "Verified OK" $sigresult 2>&1>/dev/null &&  grep "Verified OK" $attestresult 2>&1>/dev/null ;then
           __besman_echo_green "$filename is Verified Sucessfully."
	else
	   __besman_echo_red "$filename is not verified."
	fi

	[[ -f $sigresult ]] && rm -f $sigresult
	[[ -f $attestresult ]] && rm -f $attestresult

	if [ ! -z $filepath ];then
           cd $wd
	fi
}

