#!/bin/bash

USAGE="Usage: -d DAYSTOPURGE -v VOLUMENAME -t TARGETDIR"

while getopts "v:t:d:" option; do
    case "${option}" in
	v)
	    VOLUMENAME=${OPTARG}
	    ;;
        t)
            TARGETDIR=${OPTARG}
            ;;
        d)
            DAYSTOPURGE=${OPTARG}
            ;;
        *)
            echo "Invalid parameter used !"
            echo "$USAGE"
            ;;
    esac
done
#shift $((OPTIND-1))

DATE=`date +%Y-%m-%d-%H-%M-%S`
TARGETFILE="docker_volume_$VOLUMENAME_$DATE.tar.gz"
LOG="/var/log/docker_backup.log"

if [ -z $VOLUMENAME ] ; then
        echo "Missing mandatory VOLUMENAME parameter !"
        echo $USAGE
	exit 1
fi

if [ -z $TARGETDIR ] ; then
        echo "Missing mandatory TARGETDIR parameter !"
        echo $USAGE
	exit 1
fi

if [ ! -d $TARGETDIR ]; then
        echo "Target directory $TARGETDIR missing"
        exit 1
fi

backup_purge()
{
	if [[ $DAYSTOPURGE -gt 0 ]]; then
		echo "Purge files older than $DAYSTOPURGE days" >> $LOG
		find $TARGETDIR -name "docker_volume_$VOLUMENAME_*.tar.gz" -mtime +$DAYSTOPURGE -exec rm {} \; >> $LOG
	fi
}

backup_volume()
{
	docker run --rm -v $VOLUMENAME:/var/www -v $TARGETDIR:/backups/ debian:jessie-slim bash -c "cd /var/www && tar cvzf /backups/docker_volume_$VOLUMENAME-$DATE.tar.gz ." >> $LOG
}

if [ -n "$DAYSTOPURGE" ]; then
	echo "Cleaning Volume Backup on $DATE" >> $LOG
	echo "Cleaning Volume Backup on $DATE"
	backup_purge
else
	echo "Running Volume Backup on $DATE" >> $LOG
	echo "Running Volume Backup on $DATE"
	backup_volume
fi