#!/bin/bash


## This script will automatically downloads builds from localhost to the current directory. 


usage(){
	clear
	printf "Usage: \n"
	printf "\n"
	printf "./package-download.sh \$USERNAME \$PASSWORD <PublicIP or localhost> <port:4502 or 4503> <full path of the package enclosed in double quotes: Example :\"/etc/packages/my_packages/stg-content-apr-2017.zip\" "
	printf "\n"
	printf "\n"
	}
CL_PARAMS=$#
if [ $CL_PARAMS -eq 5 ]
then
        USERNAME=$1
        PASSWORD=$2
	PUBLIC_IP=$3
	PORT=$4
        PACKAGE_PATH=$5
else
        printf "Please check what you have passed to the script"
        usage
        exit -1
fi

PACKAGE_NAME_ZIP="${PACKAGE_PATH##*/}"

printf "${PACKAGE_PATH} \n"
printf "${PACKAGE_NAME_ZIP} \n"

curl -v -s -k --insecure -u $USERNAME:"${PASSWORD}" https://$PUBLIC_IP:$PORT${PACKAGE_PATH} > $PACKAGE_NAME_ZIP
