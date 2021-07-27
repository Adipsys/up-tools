#!/bin/bash

USAGE="Usage: -d DATABASEFILE -v VOLUMEFILE -t TARGETVOL -c CONTAINERNAME -p PASSWORD"

while getopts "d:v:t:c:p:" option; do
    case "${option}" in
	d)
	    DATABASEFILE=${OPTARG}
	    ;;
	v)
	    VOLUMEFILE=${OPTARG}
	    ;;
	t)
	    TARGETVOL=${OPTARG}
	    ;;
        c)
            CONTAINERNAME=${OPTARG}
            ;;
        p)
            PASSWORD=${OPTARG}
            ;;
        *)
            echo "Invalid parameter used !"
            echo "$USAGE"
            ;;
    esac
done
#shift $((OPTIND-1))

DATE=`date +%Y-%m-%d-%H-%M-%S`


if [ ! -f $DATABASEFILE ] ; then
        echo "Missing mandatory $DATABASEFILE !"
        echo $USAGE
	exit 1
fi

if [ ! -f $VOLUMEFILE ] ; then
        echo "Missing mandatory VOLUMEFILE !"
        echo $USAGE
	exit 1
fi

if [ -z $TARGETVOL ] ; then
        echo "Missing mandatory $TARGETVOL parameter !"
        echo $USAGE
	exit 1
fi

if [ -z $CONTAINERNAME ] ; then
        echo "Missing mandatory CONTAINERNAME parameter !"
        echo $USAGE
	exit 1
fi

if [ -z $PASSWORD ]; then
        echo "Missing mandatory PASSWORD parameter !"
        exit 1
fi

restore_database()
{
	CONTAINERFULLNAME=$(docker ps --format "{{.Names}}" | grep "$CONTAINERNAME")
	echo "Restoring database to $CONTAINERFULLNAME"
	gunzip < $DATABASEFILE | docker exec -i $CONTAINERFULLNAME mysql -h hm-db -u root -p$PASSWORD
}

restore_volume()
{
	echo "Restoring $VOLUMEFILE to $TARGETVOL"
	docker run --rm -v $TARGETVOL:/var/www -v $VOLUMEFILE:/backups/volume.tar.gz debian:jessie-slim bash -c "cd /var/www && tar xzf /backups/volume.tar.gz ."
	echo -e "\n Please restart the main container"
}

restore_database
restore_volume
