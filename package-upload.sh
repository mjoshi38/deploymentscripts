#!/bin/bash

##Description: 
## This script will automatically push builds to the destination server. 
## curl -u admin:admin http://localhost:4505/etc/packages/export/name_of_package.zip > name of local package file
## $USERNAME - "admin" 
## $PASSWORD - admin password 
## $PUBLIC_IP - public ip of the server where build has to be propagated
## $PORT - port of the desination server 4502 or 4503
## $PACKAGE_FILE - FIle that needs to be pushed - All files have to be copied to $SCRIPTS_HOME/JENKINS/BUILDDIR directory
## $PACKAGE_NAME - Name with which the package has to be uploaded to the destination server

##Environment Variables
CL_PARAMS=$#

usage()
{
	clear
	printf "Usage:\n "
	printf "./package-upload.sh \$USERNAME \$PASSWORD \$PUBLIC_IP \$PORT \$PACKAGE_FILE\n"
	printf "WHERE:\n "
	printf "\$USERNAME=admin\n"
	printf "\$PASSWORD=copy admin password of Production from Production and pass it with Double Quotes example: \"hdhdfsg&*%i\" \n"
	printf "\$PUBLIC_IP=Destination Public IP, either that of Author or Publish\n"
	printf "\$PORT = Destination port , either that of author or Publish(4502/4503)\n"
	printf "\$PACKAGE_FILE = Please provide the full path of the package Example: /home/kasturir/panduit-prod-dam-0.0.1.4.zip\n"
	printf "\n"
	printf "\n"
}

if [ $CL_PARAMS -eq 5 ]
then
        USERNAME=$1
        PASSWORD=$2
        PUBLIC_IP=$3
        PORT=$4
        PACKAGE_FILE=$5
else
        printf "Please check what you have passed to the script"
        usage
        exit -1
fi

timeout 1 bash -c "</dev/tcp/${PUBLIC_IP}/${PORT}" && printf "Connection Fine" || printf "Connection Failed"

##Package_name to be stripped from Package_File

PACKAGE_NAME_ZIP="${PACKAGE_FILE##*/}"
PACKAGE_NAME=`basename ${PACKAGE_NAME_ZIP} .zip`


##########################################################
##Checking if We are able to connect to package Manager
##########################################################
## THIS CODE FOR CHECKING CONNECTIVITY TO PACKMGR IS STILL BUGGY
##########################################################
#rcode=$(curl --silent --output /dev/stderr --write-out "%{http_code}" -s -u $USERNAME:"${PASSWORD}"  http://$PUBLIC_IP:$PORT/crx/packmgr/service.jsp?cmd=ls) 

#echo $rcode
#if [ $rcode -ne 0 ]
#then
#	printf "check connectivity to package manager, Username & password \n"
#	exit -1
#fi
##########################################################

curl -v -s -u $USERNAME:"${PASSWORD}" -F file=@"${PACKAGE_FILE}" -F name="${PACKAGE_NAME}" -F force=true -F install=true -F recursive=true http://$PUBLIC_IP:$PORT/crx/packmgr/service.jsp
