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
        BES_ARCHIVE_DOWNLOAD_REPO={BES_ARCHIVE_DOWNLOAD_REPO:-BESman}
fi

if [[ -z $BESMAN_NAMESPACE ]];
    then
        #BESMAN_NAMESPACE={BESMAN_NAMESPACE:-hyperledgerkochi}
	BESMAN_NAMESPACE={BESMAN_NAMESPACE:-senthilbk}
fi

# prepare branch
cd $HOME/BESman
git checkout master
#git checkout dev
git branch -D $branch
git checkout -b $branch


#copy the tmpl file to /scripts
cp $HOME/BESman/scripts/tmpl/*.tmpl $HOME/BESman/scripts/
# replacing @xxx@ variables with acutal values.
for file in $HOME/BESman/scripts/*.tmpl;
do
    sed -i "s/@BES_VERSION@/$bes_version/g" $file
    sed -i "s/@BES_ARCHIVE_DOWNLOAD_REPO@/$BES_ARCHIVE_DOWNLOAD_REPO/g" $file
    sed -i "s/@BES_NAMESPACE@/$BESMAN_NAMESPACE/g" $file
    # renaming to remove .tmpl extension
    mv "$file" "${file//.tmpl/}"
done

# committing the changes
git add $HOME/BESman/scripts/*.*
git commit -m "Update version of $branch to $bes_version"

#push release branch
git push -f -u origin $branch

#Push tag
git tag -a $bes_version -m "Releasing version $bes_version"
git push origin $bes_version

#checkout to master
git checkout master
#git checkout dev
