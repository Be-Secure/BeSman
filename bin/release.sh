#!/bin/bash

bes_version="$1"

branch="release"

# sanity check
if [[ -z "$bes_version" ]];
    then
        echo "Usage: release.sh <version>"
        exit 0
fi

#setting up environment variables
if [[ -z $BES_ARCHIVE_DOWNLOAD_REPO ]];
    then
        BES_ARCHIVE_DOWNLOAD_REPO=${BES_ARCHIVE_DOWNLOAD_REPO:-"BeSman"}
fi

if [[ -z $BESMAN_NAMESPACE ]];
    then
        BESMAN_NAMESPACE=${BESMAN_NAMESPACE:-"Be-Secure"}        
fi

# prepare branch
cd $HOME/BeSman
git checkout issue#128
#git checkout dev
git branch -D $branch
git checkout -b $branch


#copy the tmpl file to /scripts
cp $HOME/BeSman/scripts/tmpl/*.tmpl $HOME/BeSman/scripts/
# replacing @xxx@ variables with acutal values.
for file in $HOME/BeSman/scripts/*.tmpl;
do
    sed -i "s/@BES_VERSION@/$bes_version/g" $file
    sed -i "s/@BES_ARCHIVE_DOWNLOAD_REPO@/$BES_ARCHIVE_DOWNLOAD_REPO/g" $file
    sed -i "s/@BES_NAMESPACE@/$BESMAN_NAMESPACE/g" $file
    # renaming to remove .tmpl extension
    mv "$file" "${file//.tmpl/}"
done

# committing the changes
git add $HOME/BeSman/scripts/*.*
git commit -m "Updating version of $branch to $bes_version"

#push release branch
git push -f -u origin $branch

#Push tag
git tag -a $bes_version -m "Releasing version $bes_version"
git push origin $bes_version

#checkout to issue#128
git checkout issue#128
#git checkout dev
