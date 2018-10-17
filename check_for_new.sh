#!/bin/bash

reportfile=$1
if [ "$reportfile" = "" ]; then
    echo "Argument needed: report file";
    exit -1;
fi
bash cvechecker/getcvelist.sh $reportfile one-per-line >latestcves
while read cve; do
    if ! grep -w $cve ack >/dev/null; then
            if ! grep -w $cve exportedmutes >/dev/null; then
                echo "$cve";
            fi
    fi
done <latestcves
