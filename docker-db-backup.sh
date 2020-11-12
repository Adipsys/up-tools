#!/bin/bash

USAGE="Usage: -d DAYSTOPURGE -c CONTAINERNAME -p PASSWORD -t TARGETDIR"

while getopts "c:p:t:d:" option; do
    case "${option}" in
	c)
	    CONTAINERNAME=${OPTARG}
	    ;;
	p)
	    PASSWORD=${OPTARG}
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
TARGETFILE="docker_database_$CONTAINERNAME_$DATE.tar.gz"
LOG="/var/log/docker_backup.log"

if [ -z $CONTAINERNAME ] ; then
        echo "Missing mandatory CONTAINERNAME parameter !"
        echo $USAGE
	exit 1
else 
	CONTAINERFULLNAME=$(docker ps --format "{{.Names}}" | grep "$CONTAINERNAME")
	echo "Cantainer full name is $CONTAINERFULLNAME"
fi

if [ -z $PASSWORD ] ; then
        echo "Missing mandatory PASSWORD parameter !"
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
		find $TARGETDIR -name "docker_database_$CONTAINERNAME_*.tar.gz" -mtime +$DAYSTOPURGE -exec rm {} \; >> $LOG
	fi
}

backup_database()
{
	docker exec $CONTAINERFULLNAME /usr/bin/mysqldump -u root --password=$PASSWORD --all-databases | gzip -9 > $TARGETDIR/docker_database_$CONTAINERNAME-$DATE.sql.gz
}

if [ -n "$DAYSTOPURGE" ]; then
	echo "Cleaning Database Backup on $DATE" >> $LOG
	echo "Cleaning Database Backup on $DATE"
	backup_purge
else
	echo "Running Database Backup on $DATE" >> $LOG
	echo "Running Database Backup on $DATE"
	backup_database
fi
