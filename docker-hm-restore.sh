#!/bin/bash

USAGE="Usage: -db DATABASEFILE -vol VOLUMEFILE -c CONTAINERNAME -p PASSWORD"

while getopts "db:vol:c:p:" option; do
    case "${option}" in
	db)
	    DATABASEFILE=${OPTARG}
	    ;;
	vol)
	    VOLUMEFILE=${OPTARG}
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

CONTAINERFULLNAME=$(docker ps --format "{{.Names}}" | grep "$CONTAINERNAME")
echo "Cantainer full name is $CONTAINERFULLNAME"

if [ -f $DATABASEFILE ] ; then
        echo "Missing mandatory DATABASEFILE !"
        echo $USAGE
	exit 1
fi

if [ -f $VOLUMEFILE ] ; then
        echo "Missing mandatory VOLUMEFILE !"
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
	docker exec $CONTAINERFULLNAME gunzip $DATABASEFILE | /usr/bin/mysql -u root -p$PASSWORD
}

restore_volume()
{
	docker run --rm -v $VOLUMENAME:/var/www -v $VOLUMEFILE:/backups/volume.tar.gz debian:jessie-slim bash -c "cd /var/www && tar xvzf /backups/$VOLUMEFILE ."
}
