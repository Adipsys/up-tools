#!/bin/bash

USAGE="Usage: -d DATABASEFILE -v VOLUMEDATAFILE -t TARGETVOL -c MAINCONTAINER -p DBPASSWORD"

while getopts "d:v:t:c:p:" option; do
    case "${option}" in
	d)
	    DATABASEFILE=${OPTARG}
	    ;;
	v)
	    VOLUMEDATAFILE=${OPTARG}
	    ;;
	t)
	    TARGETVOL=${OPTARG}
	    ;;
        c)
            MAINCONTAINER=${OPTARG}
            ;;
        p)
            DBPASSWORD=${OPTARG}
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

if [ ! -f $VOLUMEDATAFILE ] ; then
        echo "Missing mandatory VOLUMEDATAFILE !"
        echo $USAGE
	exit 1
fi

if [ -z $TARGETVOL ] ; then
        echo "Missing mandatory $TARGETVOL parameter !"
        echo $USAGE
	exit 1
fi

if [ -z $MAINCONTAINER ] ; then
        echo "Missing mandatory MAINCONTAINER parameter !"
        echo $USAGE
	exit 1
fi

if [ -z $DBPASSWORD ]; then
        echo "Missing mandatory DBPASSWORD parameter !"
        exit 1
fi

restore_database()
{
	CONTAINERFULLNAME=$(docker ps --format "{{.Names}}" | grep "$MAINCONTAINER")
	echo -e "- Restoring database to $CONTAINERFULLNAME\n"
	gunzip < $DATABASEFILE | docker exec -i $CONTAINERFULLNAME mysql -h hm-db -u root -p$DBPASSWORD
}

restore_volume()
{
	echo "- Restoring $VOLUMEDATAFILE to $TARGETVOL"
	docker run --rm -v $TARGETVOL:/var/www -v $VOLUMEDATAFILE:/backups/volume.tar.gz debian:jessie-slim bash -c "cd /var/www && tar xzf /backups/volume.tar.gz ."
	echo -e "\n Please restart the main container"
}

echo "WARNING : TARGET DATABASE on $MAINCONTAINER and VOLUME $TARGETVOL WILL BE OVERWRITTEN !!!!! (CTRL+C TO CANCEL)"
read

restore_database
restore_volume
