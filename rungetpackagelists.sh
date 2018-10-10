#!/bin/bash
echo -n >packagelists.tgz
if [ $# -lt 1 ]; then 
    echo "need hostname of ESGF node on which you can perform a passwordless-ssh";
    exit -1
fi
esgfhost=$1

scp getpackagelists.sh root@${esgfhost}:
ssh -l root ${esgfhost} bash /root/getpackagelists.sh
scp root@${esgfhost}:/root/packagelists.tgz .

if [ ! -s packagelists.tgz ]; then
    echo "Problem retrieving packagelists";
    exit -1;
fi
tar -xzf packagelists.tgz
