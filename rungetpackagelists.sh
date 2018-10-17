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
    ssh -l root ${esgfhost} rm -f /root/getpackagelists.sh /root/packagelists.tgz
fi

if [ ! -s packagelists.tgz ]; then
    echo "Problem retrieving packagelists";
    exit -1;
fi
tar -xzf packagelists.tgz
echo "# Tomcat Webapps" >manifest.md
echo "" >>manifest.md
cat jarlist >>manifest.md
echo "" >>manifest.md
echo "# Solr jars" >>manifest.md
echo "" >>manifest.md
cat solr_jars >>manifest.md
echo "" >>manifest.md
echo "# LAS jars" >>manifest.md
echo "" >>manifest.md
cat lasjars >>manifest.md
echo "" >>manifest.md
echo "# Cog Packages" >>manifest.md
echo "" >>manifest.md
cat cog_packages >>manifest.md
echo "" >>manifest.md
echo "# Publisher Packages" >>manifest.md
echo "" >>manifest.md
cat cog_packages >>manifest.md
echo "" >>manifest.md
