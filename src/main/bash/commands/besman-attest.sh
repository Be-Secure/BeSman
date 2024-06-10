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

	local cosignpub="cosign.pub"
	local cosignkey="cosign.key"
	local predicatefile="$filename.predicate.json"
        local bundlefile="$filename.bundle"
	local attestbundlefile="$filename.attest.bundle"
	local sigfile="$filename.sig"
	local attestsigfile="$filename.attest.sig"

	if [ -f $filename ];then

	    if [ ! -f cosign.key ];then
              cosign generate-key-pair 2>&1>/dev/null
            fi

	    # Generate a predicate file
            create_predicate $filename

	    cosign sign-blob --yes --key $cosignkey --bundle $bundlefile $filename 2>&1 | tee signlog > $sigfile
            cosign attest-blob $filename --yes --key $cosignkey --bundle $attestbundlefile --predicate $predicatefile 2>&1 | tee attestlog > $attestsigfile

            tail -n 1 $sigfile > $sigfile.tmp
            [[ -f $sigfile.tmp ]] && mv -f $sigfile.tmp $sigfile


            tail -n 1 $attestsigfile > $attestsigfile.tmp
            [[ -f  $attestsigfile.tmp ]] && mv -f $attestsigfile.tmp $attestsigfile

	    [[ -f signlog ]] && rm -f signlog
	    [[ -f attestlog ]] && rm -f attestlog

	else
             __besman_echo_red "file $filename not found."
	     return 1
	fi

	#upload attestation files
	upload_attested $filename

        [[ -f cosign.key ]] && \
	[[ -f cosign.pub ]] && \
	[[ -f $sigfile ]] && \
	[[ -f $attestsigfile ]] && \
	[[ -f $bundlefile ]] && \
	[[ -f $attestbundlefile ]] && \
	[[ -f $predicatefile ]] && \
	__besman_echo_green "Attestation for $filename are generated successfully." && \
	COMPLETED="1"

	if [ ! -z $filepath ];then
          cd $wd
        fi

	[[ -z $COMPLETED ]] && __besman_echo_red "Attestation not successful." && return 1


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
	local attestsigfile=$1.attest.sig
	local bundlefile=$1.bundle
	local attestbundlefile=$1.attest.bundle
	local predicatefile=$1.predicate.json
	local cosignpub=cosign.pub
        
	[[ ! -f $sigfile ]] && echo "Error: Signature file not found." && return 1
	[[ ! -f $attestsigfile ]] && echo "Error: Attestation Signature file not found." && return 1
        [[ ! -f $attestbundlefile ]] && echo "Error: bundle file not found." && return 1 
        [[ ! -f $bundlefile ]] && echo "Error: Attestation bundle file not found." && return 1
        [[ ! -f $predicatefile ]] && echo "Error: Predicate file not found." && return 1
        [[ ! -f $cosignpub ]] && echo "Error: cosign public key file not found." && return 1

	if git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
          remoteUrl=$(git config --get remote.origin.url)
          __besman_echo_cyan "Pushing attestation file to $remoteUrl"

	  git add $cosignpub $sigfile $predicatefile $attestsigfile $bundlefile $attestbundlefile
	  git commit -a -m "Signed and attested the file  $file"
	  git push origin --quiet
	  [[ xx"$?" == xx"0" ]] && __besman_echo_green "Pushed attestation file at $remoteUrl successfully."
	  if [ xx"$?" != xx"0" ];then
            __besman_echo_red "Error: Not able to push the attestation file. Upload the files manually to $remoteUrl."
	    __besman_echo_yellow "- $cosignpub"
            __besman_echo_yellow "- $sigfile"
            __besman_echo_yellow "- $predicatefile"
            __besman_echo_yellow "- $attestsigfile"
            __besman_echo_yellow "- $bundlefile"
            __besman_echo_yellow "- $attestbundlefile"
	  fi

	else
	  echo ""
	  __besman_echo_cyan "Not a git controlled directory. Please upload the following files to the OSAR remote directory manually."
	  __besman_echo_yellow "- $cosignpub"
	  __besman_echo_yellow "- $sigfile"
	  __besman_echo_yellow "- $predicatefile"
	  __besman_echo_yellow "- $attestsigfile"
	  __besman_echo_yellow "- $bundlefile"
	  __besman_echo_yellow "- $attestbundlefile"
	  echo ""
	fi
}
