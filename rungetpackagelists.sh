#!/bin/bash
echo -n >packagelists.tgz
if [ $# -lt 1 ]; then 
    echo "need hostname of ESGF node on which you can perform a passwordless-ssh";
    exit -1
fi
esgfhost=$1
esgfuser=$2

if [ "$esgfuser" = "" ]; then
    esgfuser="root"
fi
scp getpackagelists.sh $esgfuser@${esgfhost}:
if [ "$esgfuser" != "root" ]; then
    ssh -l $esgfuser ${esgfhost} sudo bash /home/$esgfuser/getpackagelists.sh
    ssh -l $esgfuser ${esgfhost} sudo cp /root/packagelists.tgz /home/$esgfuser/
    scp ${esgfuser}@${esgfhost}:/home/$esgfuser/packagelists.tgz .
else
    ssh -l root ${esgfhost} bash /root/getpackagelists.sh
    scp root@${esgfhost}:/root/packagelists.tgz .
fi

if [ ! -s packagelists.tgz ]; then
    echo "Problem retrieving packagelists";
    exit -1;
fi
tar -xzf packagelists.tgz
