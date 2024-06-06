#!/usr/bin/env bash

function __bes_attest {
	local environment_name env_repo environment_name version_id env_config
	file_name=$1
        
        export COSIGN_PASSWORD=$(openssl rand -base64 32)
	export COSIGN_KEY_LOCATION=$(pwd)
        
	cosign version 2>&1>/dev/null

	if [ xx"$?" != xx"0" ];then
	  # install COSIGN
          LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
          curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
          sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb
	  rm -rf cosign_${LATEST_VERSION}_amd64.deb
        fi

	if [ ! -f cosign.key ];then
           cosign generate-key-pair 2>&1>/dev/null
	fi

         # Generate a predicate file
        create_predicate $file_name

	if [ -f $file_name ];then
            cosign sign-blob --yes --key cosign.key --bundle $file_name.bundle $file_name > $file_name.sig
	    cosign attest $file_name --yes --key cosign.key --bundle $file_name.attest.bundle --predicate $file_name.predicate.json > $file_name.attest.sig
	else
             __besman_echo_red "file $file_name not found."
	     return 1
	fi

	#upload attestation files
	upload_attested $file_name
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
          echo "Present directory is not git controlled."
	  echo "Please upload the following files to the OSAR directory manually."
	  echo "     cosign.pub $sigfile $predicatefile $file.attest.sig $file.attest.sig $file.bundle $file.attest.bundle"
	  echo ""
	fi
}
