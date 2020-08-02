#!/bin/bash

#Usage Example
#echo IP 'bash -s' < script_name.sh"

USERID=`whoami`
USER_HOME="/home/$USERID"
export USERID
export USER_HOME

DATE_TIME=`date "+%Y%m%d-%H%M"`

## Check whether new tar files exists or not
if [ -e "$USER_HOME"/httpd*tar ] && [ -e "$USER_HOME"/errorpages*tar ]
then

##Backup Dispatcher Configurations and Error Pages
cd /etc/httpd
sudo tar cvf /mnt/Apache-Deployment-Archive/"$DATE_TIME".tar conf conf.d conf.modules.d -C /mnt/var/www/html/shorturlcache errorpages

## Extrating Error Pages and Configuration
cd $USER_HOME
tar xvf httpd*tar 
tar xvf errorpages*tar

##Removing existing configuration and adding new one
sudo cp -r "$USER_HOME"/conf /etc/httpd
sudo cp -r "$USER_HOME"/conf.d /etc/httpd
sudo cp -r "$USER_HOME"/conf.modules.d /etc/httpd

## Clearing Error pages from Dispatcher
sudo rm -rf /mnt/var/www/html/shorturlcache/*
sudo rm -rf /mnt/var/www/html/longurlcache/*

sudo cp -r "$USER_HOME"/errorpages /mnt/var/www/html/shorturlcache
sudo cp -r "$USER_HOME"/errorpages /mnt/var/www/html/longurlcache

sudo chown -R apache:apache /mnt/var/www/html/shorturlcache/
sudo chown -R apache:apache /mnt/var/www/html/longurlcache/

##Removing tar Files from User Home Directory
rm -rf "$USER_HOME"/httpd*tar
rm -rf "$USER_HOME"/errorpages*
rm -rf "$USER_HOME"/conf
rm -rf "$USER_HOME"/conf.d
rm -rf "$USER_HOME"/conf.modules.d
exit 0

else
echo "New tar files doesn't exist at "$USER_HOME". Please check and try again."
exit 1
fi
