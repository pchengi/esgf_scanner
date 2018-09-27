#!/bin/bash

if ! [ -s cog_packages  ] || ! [ -s pub_packages ] || ! [ -s jarlist ]; then 
    echo "Missing input files. Bailing out";
    exit -1;
fi
echo -n >esgf.conf
for i in cog_packages pub_packages jarlist; do
    echo -n >$i.out
    while read ln; do
        pkg=`basename $ln`;
        pkg_processed=`echo $pkg|cut -d '=' -f1|perl -pe 's|(.*?)-[0-9].*|\1|'`
        len=`echo $pkg_processed|wc -c`;
        if [ $len -le 3 ]; then
            continue;
        fi
        echo $pkg|cut -d '=' -f1|perl -pe 's|(.*?)-[0-9].*|\1|' >>$i.out
    done <$i
done
excludes=`cat esgf_excludes`
packages=`cat esgf_manual cog_packages.out jarlist.out pub_packages.out|sort -u|paste -sd,`
echo $packages >packages
while read ln; do
    sed -i "s/,$ln,/,/" packages
done <expungelist
packages=`cat packages`
rm packages
echo "packages=$packages" >>esgf.conf
echo "excludes=$excludes" >>esgf.conf
