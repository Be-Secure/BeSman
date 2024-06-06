#!/usr/bin/env bash

function __bes_attest {
	local environment_name env_repo environment_name version_id env_config
	file_name=$1
        COSIGN_PASSWORD=$(openssl rand -base64 32)
        export COSIGN_PASSWORD
	export COSIGN_KEY_LOCATION=$(pwd)

	# install COSIGN
        LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
        curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
        sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb

        cosign generate-key-pair

	if [ -f $file_name ];then
            cosign sign-blob --yes --key cosign.key --bundle $file_name.bundle $file_name > $file_name.sig
	    cosign attest $file_name --yes --key cosign.key --bundle $file_name.attest.bundle --predicate $file_name.predicate.json > $file_name.attest.sig
	else
             __besman_echo_red "file $file_name not found."
	     return 1
	fi


        # Generate a predicate file
	[[ create_predicate $file_name ]] && return 1

	#upload attestation files
	[[ upload_attested $file_name ]] && return 1
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
        "name" : "$file"
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

	git add cosign.pub $sigfile $predicatefile $file.attest.sig $file.attest.sig $file.bundle $file.attest.bundle

	git commit -a -m "Signed and attested the file  $file"

	git push origin 

	return 0
}
