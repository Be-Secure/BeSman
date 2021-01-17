#!/bin/bash

bes_rel_version=$1
branch="release"
dist_branch="dist"

#sanity
if [[ -z "$bes_rel_version" ]]; then
	echo "Usage: dopublish.sh <version>"
	exit 0
fi

#Checkout latest tag
# git checkout tags/$bes_rel_version -b $bes_rel_version
git checkout $branch

# temporary folder for storing tar files. folder also added in .gitignore
mkdir -p build/tmp

# making of zip files

zip -rj $HOME/BESman/build/tmp/besman-latest.zip $HOME/BESman/dist/list.txt $HOME/BESman/src/main/bash/besman-* $HOME/BESman/src/main/bash/envs/besman-* $HOME/BESman/src/main/bash/commands/besman-*
#zip -rj $HOME/BeSman/build/tmp/besman-latest.zip $HOME/BeSman/dist/list.txt $HOME/BeSman/src/main/bash/besman-* $HOME/BESman/src/main/bash/envs/besman-* $HOME/BESman/src/main/bash/commands/besman-*

#zip -r build/tmp/besman-latest.zip $HOME/BESman/src/
cp $HOME/BESman/build/tmp/besman-latest.zip $HOME/BESman/build/tmp/besman-$bes_rel_version.zip

# moving get.besman.io to tmp/
mv $HOME/BESman/scripts/get.besman.io $HOME/BESman/build/tmp/

# moving into dist branch
git checkout $dist_branch

# collecting files from Release branch tmp/ folder to dist branch
git checkout $branch -- $HOME/BESman/build/tmp/* &> /dev/null

mkdir dist &> /dev/null
# moving of latest files from tmp/ to dist/
mv $HOME/BESman/build/tmp/* $HOME/BESman/dist/

# ls -l $HOME/BESman/dist/
# saving changes and pushing
git add $HOME/BESman/dist/*
git commit -m "Released the version $bes_rel_version"
git push origin -f -u $dist_branch

#checkout back to master
#git checkout master
git checkout dev
