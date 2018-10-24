#!/bin/bash

cvelist=$1
if [ "$cvelist" = "" ]; then
    echo "Need argument: cvelist";
    exit -1;
fi
mys=`cat $cvelist|sed 's/,/\n/'g`
for cve in $mys; do 
    grep $cve exportedmutes;
done
