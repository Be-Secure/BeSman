#!/usr/bin/env bash

function __bes_verify {
	local environment_name env_repo environment_name version_id env_config
	file_name=$1

	#check if cosign installed
	cosign version
	if [ xx"$?" != xx"0" ];then
	  # install COSIGN
          LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
          curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
          sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb
        fi

	#check if the required files at present at current folder.
	if [ ! -f $file_name ] || [ ! -f $file_name.sig ] || [ ! -f cosign.pub ];then
           echo "Required files are not present"
           return 1
        fi

        #verify the signature
        cosign verify-blob $file_name --key cosign.pub --bundle $file_name.bundle

	#verify the attestation
	cosign verify-blob-attestation $file_name --key cosign.pub --bundle $file_name.attest.bundle
}

