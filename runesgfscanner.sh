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

git pull >>runlog-esgf_scanner && git submodule init >>runlog-esgf_scanner && git submodule update >>runlog-esgf_scanner
bash firstuse.sh
bash generate_esgfconf.sh
cp esgf.conf exportedmutes cvechecker
cp ack cvechecker/pinned_cves
cd cvechecker
echo -n > unmutable
python3 cvechecker.py -u >> ../runlog-esgf_scanner
python3 cvechecker.py -d -m off
python3 cvechecker.py -i exportedmutes >muting_transcript
if [ -s muting_transcript ]; then
	cat muting_transcript|awk '{print $4}' >unmutable
fi
python3 cvechecker.py -r esgf.conf >esgfreport.txt
cd ..
bash cvechecker/getcvelist.sh cvechecker/esgfreport.txt one-per-line >currcves
bash check_for_new.sh cvechecker/esgfreport.txt >newcves
if [ -s cvechecker/unmutable ]; then
    firstoutdated='True';
    firstupdated='True';
    outdatedcves=''
	while read unm; do
		if ! grep -w $unm currcves >/dev/null; then
            if [ "$firstoutdated" = "True" ]; then
                firstoutdated="False";
                outdatedcves=$unm;
            else
                outdatedcves=${outdatedcves},$unm;
            fi
        else
            if [ "$firstupdated" = "True" ]; then
                firstupdated="False";
                updatedcves=$unm;
            else
                updatedcves=${updatedcves},$unm;
            fi
        fi
    done <cvechecker/unmutable
    if [ "$outdatedcves" != "" ]; then
        cd cvechecker 
        python3 cvechecker.py -c $outdatedcves >../outdatedcves_report.txt
        cd ..
        echo "We are asking to mute the following CVEs which are not showing up against any configured products. Perhaps these are candidates for removal from exported mutes?" >body;
        echo "$outdatedcves" >>body;
        cat outdatedcves_report.txt >>body
        echo "$outdatedcves" >outdatedcves_list.txt;
        subj='Remove from exportedmutes'
        python mailsend.py --sender "$sender" --recips "$recips" --server $server --subject "$subj" --port $port --body body --attachments outdatedcves_list.txt
    fi
    if [ "$updatedcves" != "" ]; then
        cd cvechecker
        python3 cvechecker.py -c $updatedcves >../updatedcves_report.txt
        cd ..
        echo "We are asking to mute the following CVEs which seem to have been updated" >body;
        echo "$updatedcves" >>body;
        cat updatedcves_report.txt >>body
        echo "$updatedcves" >updatedcves_list.txt;
        subj='Update muted CVEs'
        python mailsend.py --sender "$sender" --subject "$subj" --recips "$recips" --server $server --port $port --body body --attachments updatedcves_list.txt
    fi
fi
if [ -s newcves ]; then
    echo "We have new CVE hits against our packages." >body
    newcvelist=`cat newcves|paste -sd,`
    cd cvechecker
    python3 cvechecker.py -c $newcvelist >../newcves_report.txt
    cd ..
    echo $newcvelist >>body
    cat newcves_report.txt >>body
    echo $newcvelist >newcves_list.txt;
    subj='New CVEs against ESGF'
    python mailsend.py --sender "$sender" --subject "$subj" --recips "$recips" --server $server --port $port --body body --attachments newcves_list.txt
fi
cd cvechecker
rm muting_transcript unmutable
mv esgfreport.txt ..
cd ..
rm esgfscannerrun
