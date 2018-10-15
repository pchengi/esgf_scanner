#!/bin/bash

cvelist=$1
report=$2

while read cve; do
    if ! grep $cve $report >/dev/null; then
        echo "Did not find reference to $cve in report";
    fi
done <$cvelist
