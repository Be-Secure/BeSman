#!/bin/bash
function __bes_upgrade {
mkdir $BESMAN_DIR/bak
__besman_echo_white "Making backups..."
zip -r $BESMAN_DIR/bak/besman_bak.zip .besman
__besman_echo_white "Removing current version..."
find $BESMAN_DIR -mindepth 1 -name bak -prune -o -exec rm -rf {} +
__besman_echo_white "Fetching latest version..."
__besman_secure_curl https://raw.githubusercontent.com/$BESMAN_NAMESPACE/BeSman/dist/dist/get.besman.io | bash
unzip $BESMAN_DIR/bak/besman_bak.zip -d $BESMAN_DIR/bak
__besman_echo_white "Restoring user configs..."
dir=$(find  $BESMAN_DIR/bak/.besman/envs -type d -name besman-*)
for i in "${dir[@]}"; do
    n=${i##*/}
    mv $BESMAN_DIR/bak/.besman/envs/$n $BESMAN_DIR/envs
done
if [[ -f $BESMAN_DIR/bak/.besman/var/*.proc ]]; then
    mv $BESMAN_DIR/bak/.besman/var/*.proc $BESMAN_DIR/var
fi
if [[ -f $BESMAN_DIR/bak/.besman/var/current ]]; then
    mv $BESMAN_DIR/bak/.besman/var/current $BESMAN_DIR/var
fi
source $BESMAN_DIR/bin/besman-init.sh
__besman_echo_blue "Upgraded successfully"
__besman_echo_blue "Current version:$(cat $BESMAN_DIR/var/version.txt)"

unset n i dir
rm -rf $BESMAN_DIR/bak

##TODO:- validate whether the user configs are compatible with the current version
}



