#!/usr/bin/env bash

function __bes_attest {
	local environment_name env_repo environment_name version_id env_config
	opts=$1
        args=$2

        [[ "${opts[0]}" != "--file" ]] && [[ "${opts[0]}" != "--path" ]] && __besman_echo_red "Incorrect options passed." && __bes_help_"$command" && return 1

	[[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--file" ]] && filename="${args[1]}"
	[[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--path" ]] &&  __besman_echo_red "--file argument is must. Passed only --path" && __bes_help_"$command" && return 1
	[[ ${#opts[@]} -eq 2 ]] && [[ "${opts[0]}" == "--path" ]] && filepath="${args[1]}" && filename="${args[2]}"
	[[ ${#opts[@]} -eq 2 ]] && [[ "${opts[1]}" == "--path" ]] && filepath="${args[2]}" && filename="${args[1]}"

	[[ ! -z $filepath ]] && [[ ! -d $filepath ]] && __besman_echo_red "filepath $filepath not found. Exit" && return 1
        [[ ! -z $filepath ]] && [[ ! -f $filepath/$filename ]] && __besman_echo_red "file $filename not found at $filepath. Exit" && return 1
        [[ -z $filepath ]] && [[ ! -f $filename ]] && __besman_echo_red "file $filename not found at $filepath. Exit" && return 1

	if [ ! -z $filepath ];then
	  wd=$(pwd)
	  cd $filepath
	fi

	export COSIGN_PASSWORD=$(openssl rand -base64 32)
        export COSIGN_KEY_LOCATION=$(pwd)

        cosign version 2>&1>/dev/null

	if [ xx"$?" != xx"0" ];then
	  # install COSIGN
          LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
          curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
          sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb
	  [[ -f  cosign_${LATEST_VERSION}_amd64.deb ]] && rm -rf cosign_${LATEST_VERSION}_amd64.deb
        fi

	if [ ! -f cosign.key ];then
           cosign generate-key-pair 2>&1>/dev/null
	fi

         # Generate a predicate file
        create_predicate $filename

	if [ -f $filename ];then

	    cosign sign-blob --yes --key cosign.key --bundle $filename.bundle $filename 2>&1 | tee signlog > $filename.sig
            cosign attest-blob $filename --yes --key cosign.key --bundle $filename.attest.bundle --predicate $filename.predicate.json 2>&1 | tee attestlog > $filename.attest.sig

            tail -n 1 $filename.sig > $filename.sig.tmp
            mv $filename.sig.tmp $filename.sig

            tail -n 1 $filename.attest.sig > $filename.attest.sig.tmp
            mv $filename.sig.tmp $filename.attest.sig

	else
             __besman_echo_red "file $filename not found."
	     return 1
	fi

	#upload attestation files
	upload_attested $filename

	if [ ! -z $filepath ];then
	  cd $wd
	fi
}

function create_predicate {
    local file=$1
    local predicatefile=$1.predicate.json

    local PredicateType="https://besecure.github.com/predicatetype/v1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local shasum=$(sha256sum $file)

cat <<EOF >"$predicatefile"
{
    "predicateType": "$PredicateType",
    "subject": {
        "name" : "$file",
	"digest": {
           "sha256": "$shasum"
        }
    },
    "timestamp": "$timestamp"
}
EOF

return 0
}


function upload_attested {
	local file=$1
	local sigfile=$1.sig
	local predicatefile=$1.predicate.json
        
	[[ ! -f $sigfile ]] && echo "Error: Signature file not found." && return 1

	if [[ ! -f cosign.key ]] || [[ ! -f cosign.pub ]]; then
           echo "Key not generated properly." && return 1
        fi

	if git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
	  git add cosign.pub $sigfile $predicatefile $file.attest.sig $file.attest.sig $file.bundle $file.attest.bundle
	  git commit -a -m "Signed and attested the file  $file"
	  git push origin
	else
	  echo ""
	  [[ ! -z $filepath ]] && __besman_echo_yellow "Filepath provided is not git controlled."
	  [[ -z $filepath ]] && __besman_echo_yellow "Present working directory is not git controlled."
	  __besman_echo_yellow "Please upload the following files to the OSAR directory manually."
	  __besman_echo_yellow "     cosign.pub $sigfile $predicatefile $file.attest.sig $file.attest.sig $file.bundle $file.attest.bundle"
	  echo ""
	fi
}
