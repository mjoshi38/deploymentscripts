#!/bin/bash


## This script will automatically downloads builds from localhost to the current directory. 


usage(){
	clear
	printf "Usage: \n"
	printf "\n"
	printf "./package-list.sh \$USERNAME \$PASSWORD <PublicIP or localhost> <port:4502 or 4503> "
	printf "\n"
	printf "\n"
	}
CL_PARAMS=$#
if [ $CL_PARAMS -eq 4 ]
then
        USERNAME=$1
        PASSWORD=$2
	PUBLIC_IP=$3
	PORT=$4
else
        printf "Please check what you have passed to the script"
        usage
        exit -1
fi
#for 4502 port
curl -v -s -u $USERNAME:"${PASSWORD}" http://$PUBLIC_IP:$PORT/crx/packmgr/service.jsp?cmd=ls
#for 5433 port
#curl -v -s -k --insecure -u $USERNAME:"${PASSWORD}" https://$PUBLIC_IP:$PORT/crx/packmgr/service.jsp?cmd=ls
