#!/bin/bash

reportfile=$1
if [ "$reportfile" = "" ]; then
    echo "Argument needed: report file";
    exit -1;
fi
bash cvechecker/getcvelist.sh $reportfile one-per-line >latestcves
while read cve; do
    if ! grep $cve ack >/dev/null; then
        echo "$cve";
    fi
done <latestcves
