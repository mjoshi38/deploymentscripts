#!/bin/bash

USERID=`whoami`
USER_HOME="/home/$USERID"
export USERID
export USER_HOME

#Taking user input for the dispatcher.
read -p "Enter the dispatcher number(1-4):" value

#Making sure user is typing integer only.
if ! [[ "$value" =~ ^[0-9]+$ ]]
then
echo "Sorry integers only"
exit 1
elif [ "$value" -eq 1 ]
then
IP=52.28.84.13
elif [ "$value" -eq 2 ]
then 
IP=35.158.0.223
elif [ "$value" -eq 3 ]
then
IP=35.156.179.251
elif [ "$value" -eq 4 ]
then
IP=52.58.220.26
else
echo "Please check and enter correct dispatcher number"
exit 1
fi

#Copying required files to the dispatcher.
scp "$USER_HOME"/63.1.18*/allianz-emea-prd-dispatcher-"$value".adobecqms.net/httpd-63.1.18*.tar  mojoshi@"$IP":/home/mojoshi/
scp "$USER_HOME"/63.1.18*/errorpages-63.1.18*.tar  mojoshi@"$IP":/home/mojoshi/

#Running dispatcher_change.sh script in dispatcher.
ssh "$IP" 'bash -s' < "$USER_HOME"/dispatcher-script/dispatcher_change.sh
