#!/bin/sh

echo "Checking Parameters"

if [ "$#" -ne 4 ]; then

	echo "Wrong Paramters, skipping ..."
	exit 1

else 	
	echo "Right Parameters executing..."

	LOCAL_PATH=$1
	ENDECA_HOST=$2
	REMOTE_PATH=$3
	ENDECA_USER=$4

	echo "Moving files to $REMOTE_PATH"
	scp $LOCAL_PATH/* $ENDECA_USER@$ENDECA_HOST:$REMOTE_PATH
	
	echo "Invoking Endeca Record Store indexing"
	ssh $ENDECA_USER@$ENDECA_HOST 'sh /opt/endeca/CAS/11.1.0/bin/cas-cmd.sh startCrawl -id GTAApp1-WCS'

	echo "Running partial_update.sh"
	ssh $ENDECA_USER@$ENDECA_HOST 'sh /opt/endeca_apps/GTAApp1/control/partial_update.sh'

        echo "Cleanup local files"
        rm $LOCAL_PATH/*

fi

exit 0
