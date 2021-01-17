#!/bin/bash


function __bes_status {
file=($(find $BESMAN_DIR/envs/ -type d -name "besman-*" -print))
if [[ -z $file ]]; then
    
    __besman_echo_white "Please install an environment first"
    return 1
fi
for f in "${file[@]}"; do
    echo "${f##*/}" > $HOME/tmp1.txt
    n=$(sed 's/besman-//g' $HOME/tmp1.txt)
    if [[ ! -f $BESMAN_DIR/envs/besman-$n/current ]]; then
        __besman_echo_white "No current file found for $n"
        return 1
    fi
    rm $HOME/tmp1.txt
done
__besman_echo_white "Installed environments and their version"
__besman_echo_white "---------------------------------------------"
for f in "${file[@]}"; do
    
    echo "${f##*/}" > $HOME/tmp1.txt
    n=$(sed 's/besman-//g' $HOME/tmp1.txt)
    if [[ $n == $(cat $BESMAN_DIR/var/current) ]]; then
        echo "~" $n $(ls $BESMAN_DIR/envs/besman-$n | grep -v $(cat $BESMAN_DIR/envs/besman-$n/current)) $(cat $BESMAN_DIR/envs/besman-$n/current)"*" > $BESMAN_DIR/envs/besman-$n/tmp.txt
        sed 's/current//g' $BESMAN_DIR/envs/besman-$n/tmp.txt
    else

        echo $n $(ls $BESMAN_DIR/envs/besman-$n | grep -v $(cat $BESMAN_DIR/envs/besman-$n/current)) $(cat $BESMAN_DIR/envs/besman-$n/current)"*" > $BESMAN_DIR/envs/besman-$n/tmp.txt
        sed 's/current//g' $BESMAN_DIR/envs/besman-$n/tmp.txt
    fi
    rm $BESMAN_DIR/envs/besman-$n/tmp.txt 
    rm $HOME/tmp1.txt
    
done

unset n file f 

}
