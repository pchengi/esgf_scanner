#!/bin/bash

dt=`date`
cd esgf_scanner || exit -1 # copy this script to outside the esgf_scanner directory, to run from a cron etc

if [ -f esgfscannerrun ]; then
    echo "Run skipped at $dt" >>runlog-esgf_scanner
    exit -1;
fi
if [ ! -s esgf_scanner.conf ]; then
    echo "Copy the esgf_scanner.conf.template file as esgf_scanner.conf, populate it with correct values and run again.";
    exit -1;
fi
touch esgfscannerrun
echo "Run initiated at $dt" >>runlog-esgf_scanner

recips=`grep alertmail_recipient esgf_scanner.conf|cut -d '=' -f2`
sender=`grep alertmail_sender esgf_scanner.conf|cut -d '=' -f2`
port=`grep mailserver_port esgf_scanner.conf|cut -d '=' -f2`
server=`grep mailserver_host esgf_scanner.conf|cut -d '=' -f2`

git pull >/dev/null && git submodule init >/dev/null && git submodule update >/dev/null
bash firstuse.sh
bash generate_esgfconf.sh
cp esgf.conf exportedmutes cvechecker
cd cvechecker
python3 cvechecker.py -u >>runlog-esgf_scanner
python3 cvechecker.py -i exportedmutes >muting_transcript
if [ -s muting_transcript ]; then
	cat muting_transcript|awk '{print $4}' >unmutable
fi
python3 cvechecker.py -r esgf.conf >esgfreport.txt
cd ..
bash check_for_new.sh cvechecker/esgfreport.txt >newcves
if [ -s cvechecker/unmutable ]; then
    firstoutdated='True';
    firstupdated='True';
    outdatedcves=''
	while read unm; do
		if ! grep -w $unm newcves >/dev/null; then
            if [ "$firstoutdated" = "True" ]; then
                firstoutdated = "False";
                outdatedcves=$unm;
            else
                outdatedcves=${outdatedcves},$unm;
            fi
        else
            if [ "$firstupdated" = "True" ]; then
                firstupdated = "False";
                updatedcves=$unm;
            else
                updatedcves=${updatedcves},$unm;
            fi
        fi
    done <cvechecker/unmutable
    if [ "$outdatedcves" != "" ]; then
        echo "We are asking to mute the following CVEs which are not showing up against any configured products. Perhaps these are candidates for removal from exported mutes?";
        echo "$outdatedcves";
    fi
    if [ "$updatedcves" != "" ]; then
        echo "We are asking to mute the following CVEs which are not showing up against any configured products. Perhaps these are candidates for removal from exported mutes?";
       echo "$updatedcves";
    fi
fi

               
			






