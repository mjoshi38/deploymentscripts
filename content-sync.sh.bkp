#!/bin/bash

##The purpose of this script is to automate content backflow  task

#############################################################

export datavol
function findatavol()
	{
	aws ec2 describe-instance-attribute --instance-id "$1" --region "$2" --profile "$3" --attribute blockDeviceMapping --query 'BlockDeviceMappings[*].DeviceName' --output text > devicename.txt
	for name in `cat devicename.txt`
	do
	if [ "$name" == '/dev/xvdba' ]
	then
	found=1
	break
	else
	continue
	fi
	done
	if [ "$found" -eq "1" ]
	then
	datavol=`aws ec2 describe-instance-attribute --instance-id "$1" --region "$2" --profile "$3" --attribute blockDeviceMapping --query "BlockDeviceMappings[?DeviceName=='/dev/xvdba'].Ebs.VolumeId" --output text`
	else
	printf "\nData volume is not mounted as /dev/xvdba. Script will not work in this case. Sorry try manual steps\n"
	exit 1
	fi
	}

function attach_new()
	{
	printf "\nDetaching old volume\n"
	aws ec2 detach-volume --region "$dest_region" --profile "$bpbu" --volume-id "$dest_datavol" 
	printf "Waiting for 10 seconds"
	sleep 10
	printf "\nAttaching new volume\n"
	aws ec2 attach-volume --region "$dest_region" --profile "$bpbu" --volume-id "$new_vol_id" --instance-id "$dest_id" --device /dev/xvdba
	printf "Waiting for 10 seconds"
	sleep 10
	}

function health_check()
        {
        instance_state=`aws ec2 describe-instance-status --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id" --query "InstanceStatuses[*].InstanceState[].Name" --output text`
        if [ "$instance_state" == 'running' ]
	then
	printf "Server state is running.\nWaiting for health check to pass"
        instance_status=`aws ec2 describe-instance-status --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id" --query "InstanceStatuses[*].InstanceStatus[].Status" --output text`
        while [ "$instance_status" != 'ok' ]
        do
        printf "\nWaiting for 30 seconds to check again. This will continue unless server passes the health check (approx 4,5 minutes)"
        sleep 30
        instance_status=`aws ec2 describe-instance-status --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id" --query "InstanceStatuses[*].InstanceStatus[].Status" --output text`
        done
        system_status=`aws ec2 describe-instance-status --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id" --query "InstanceStatuses[*].SystemStatus[].Status" --output text`
        if [ "$system_status" != 'ok' ]
        then
        printf "\nServer is failing health check. Rebooting server again"
        aws ec2 reboot-instances --region "$dest_region" --profile "$bpbu" --instance-ids "$dest_id"
	sleep 15
	health_check
	else
        printf "\nServer is up and passing health check\n"
        fi
        else
	printf "\nServer state is pending.\nChecking again after 10 seconds\n"
	sleep 10
	health_check
        fi
        }

function trigger_snap()
        {
        read -p "Do you want to trigger new snapshot for this volume '$src_datavol' (Y/N)::" value
        if [ "$value" == 'Y' -o "$value" == 'y' -o "$value" == 'yes' -o "$value" == 'YES' ]
        then
        printf "\nSnapshot triggered. Kindly wait for some time until the snapshot completed and try again"
        aws ec2 create-snapshot --region "$source_region" --profile "$bpbu" --volume-id "$src_datavol" --description "This is the latest snapshot"
        exit 0
        else
        printf "\nKindly check and try again\n"
        exit 1
        fi
        }

function create_package_non_ssl()
	{
	curl -u "$Username":"$Password"  -X POST http://"$dest_ip":"$Port"/crx/packmgr/service/.json/etc/packages/my_packages/"$PackageName"?cmd=create -d packageName="$PackageName" -d groupName=my_packages
	curl -u "$Username":"$Password" -X POST http://"$dest_ip":"$Port"/crx/packmgr/update.jsp -F path=/etc/packages/my_packages/"$PackageName".zip -F groupName=my_packages -F packageName="$PackageName" -F filter="[{\"root\":\"/etc/replication\",\"rules\":[]}]"
	curl -u "$Username":"$Password" -X POST http://"$dest_ip":"$Port"/crx/packmgr/service/.json/etc/packages/my_packages/"$PackageName".zip?cmd=build
        printf "\nPackage is created.\nDownloading the same\n"
	curl -u "$Username":"$Password" http://"$dest_ip":"$Port"/etc/packages/my_packages/"$PackageName".zip > "$PackageName".zip
        printf "\nPackage Download completed\n"
	}

function create_package_ssl()
        {
        curl -u "$Username":"$Password" -k --insecure -X POST https://"$dest_ip":"$Port"/crx/packmgr/service/.json/etc/packages/my_packages/"$PackageName"?cmd=create -d packageName="$PackageName" -d groupName=my_packages
        curl -u "$Username":"$Password" -k --insecure -X POST https://"$dest_ip":"$Port"/crx/packmgr/update.jsp -F path=/etc/packages/my_packages/"$PackageName".zip -F groupName=my_packages -F packageName="$PackageName" -F filter="[{\"root\":\"/etc/replication\",\"rules\":[]}]"
        curl -u "$Username":"$Password" -k --insecure -X POST https://"$dest_ip":"$Port"/crx/packmgr/service/.json/etc/packages/my_packages/"$PackageName".zip?cmd=build
        printf "\nPackage is created.\nDownloading the same\n"
        curl -u "$Username":"$Password" -k --insecure https://"$dest_ip":"$Port"/etc/packages/my_packages/"$PackageName".zip > "$PackageName".zip
        printf "\nPackage Download completed\n"
	}

function create_rep()
        {
        dest_ip=`aws ec2 describe-instances --instance-id "$dest_id" --region "$dest_region" --profile "$bpbu" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicIp' --output text`
        printf "\nKindly provide below inputs to create replication package\n"
	read -p "Enter destination server username (Ex -> admin) ::" Username
        read -p "Enter destination server password (Ex -> 3d!ro%aw)::" Password
        read -p "Enter destination server port number (Ex -> 4502/4503) ::" Port
        read -p "Enter package name (Ex -> author-replication-package)::" PackageName
        if [ ! -z $Username ] && [ ! -z $Password ] &&  [ ! -z $Port ] &&  [ ! -z $PackageName ]
        then
        if [ "$Port" == '4502' -o "$Port" == '4503' ]
        then
        create_package_non_ssl
        elif [ "$Port" == '5433' ]
        then
        create_package_ssl
        else
        printf "\nPort number is not correct. Kindly verify and try again"
        exit 1
        fi
        else
        printf "\nAll fields are mandatory. Try again"
        exit 1
        fi
        }

function findsnap()
	{
	latest_snap=`aws ec2 describe-snapshots --region "$source_region" --profile "$bpbu" --filter 'Name=volume-id,Values='$src_datavol'' | jq '.[]|max_by(.StartTime)|.SnapshotId' | sed -e 's/"//g'`
        if [ "$latest_snap" == "null" ]
        then
        printf "\nThere is no snapshot found for this data volume\n"
        trigger_snap
        else
        snap_status=`aws ec2 describe-snapshots --region "$source_region" --profile "$bpbu" --snapshot-id "$latest_snap" --query "Snapshots[*].State" --output text`
        snap_time=`aws ec2 describe-snapshots --region "$source_region" --profile "$bpbu" --snapshot-id "$latest_snap" --query 'Snapshots[*].StartTime' --output text`
        epoch_snap_time=`date -d "$snap_time"`
        if [ "$snap_status" != "completed" ]
        then
        printf "\nLatest snapshot id is '$latest_snap' and is still in progress. Kindly wait for some time and try again\n"
        exit 1
        else
        printf "\nLatest snapshot id is '$latest_snap' and is taken at '$epoch_snap_time'\n"

	fi
	fi	
	}

function content_sync()
	{
	printf "\nSearching data volume (/mnt)"
	findatavol "$source_id" "$source_region" "$bpbu"
	src_datavol="$datavol"
	volsize=`aws ec2 describe-volumes --region "$source_region" --profile "$bpbu" --volume-ids "$src_datavol" --query 'Volumes[*].Size' --output text`
	printf "\nData volume is '$src_datavol' and is '$volsize' GB in size"
	
	##To find the latest snapshot
	printf "\nChecking for latest snapshot of the data volume. It may take some time"
	findsnap "$src_datavol"
	
	read -p "Do you want to continue with this snapshot (Y/N)::" option
	if [ "$option" == 'Y' -o "$option" == 'y' -o "$option" == 'YES' -o "$option" == 'yes' ]
	then
	printf "Checking destionation server details"

	##This file contain all the volume ids attached before any change
	aws ec2 describe-instance-attribute --instance-id "$dest_id" --region "$dest_region" --profile "$bpbu" --attribute blockDeviceMapping --query 'BlockDeviceMappings[*].Ebs.VolumeId' --output text > dest_ser_vol_id.txt
	printf "\nOld volume details of destination instance can be found in dest_ser_vol_id.txt"
	findatavol "$dest_id" "$dest_region" "$bpbu"
	dest_datavol="$datavol"
	old_vol_type=`aws ec2 describe-volumes --region "$dest_region" --profile "$bpbu" --volume-ids "$dest_datavol" --query 'Volumes[*].VolumeType' --output text`
	
	##Creating new volume from the snapshot
	new_vol_id=`aws ec2 create-volume --size "$volsize" --region "$dest_region" --profile "$bpbu" --availability-zone "$dest_az" --snapshot-id "$latest_snap" --volume-type "$old_vol_type" --query 'VolumeId' --output text`
	printf "\nThe new volume ID is '$new_vol_id'"
	printf "\nWaiting for 10 seconds for volume to become available"
	sleep 10
	
	##Checking server status and attaching new volume
	printf "\nChecking destination server status and attaching new volume to the same\n"
	current_state=`aws ec2 describe-instances --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id" --query "Reservations[*].Instances[*].State[].Name" --output text`
	if [ "$current_state" == 'running' ]
	then
	printf "Server state is running.\nStopping the server\n"
	aws ec2 stop-instances --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id"
	while [ "$current_state" != 'stopped' ]
	do
	printf "Waiting for 30 seconds to check again. This will continue unless server state changed to stopped (approx 2,3 minutes)\n"
	sleep 30
	current_state=`aws ec2 describe-instances --region "$dest_region" --profile "$bpbu" --instance-id "$dest_id" --query "Reservations[*].Instances[*].State[].Name" --output text`
	done
	printf "\nServer state changed from running to stopped"
	attach_new
	elif [ "$current_state" == 'stopped' ]
	then
	printf "\nServer is in stopped state"
	attach_new
	else
	printf "\nServer is in different state (neither stop/start). Kindly check and run again"
	printf "\nAlso delete newly created volume"
	exit 1
	fi
	
	##Starting server after attaching new volume
	printf "\nStarting server. Wait for  4,5 minutes for server to pass health check\n"
	aws ec2 start-instances --region "$dest_region" --profile "$bpbu" --instance-ids "$dest_id"
	sleep 10
	health_check
	else
	trigger_snap
	fi
	fi
	fi
	}

printf "\nThis script assumes that the data volume is attached as '/dev/xvdba'. If the data volume is not attached as '/dev/xvdba' do not proceed further. In case of any confusion kindly check and re-run the script. Waiting for 10 seconds.\n"
sleep 10
read -p "Enter source instance-id (Ex -> i-080b68c2077a6) ::" source_id
read -p "Enter destination instance-id (Ex -> i-080b68c20d9fe) ::" dest_id
read -p "Enter source AZ (Ex -> us-east-1a) ::" source_az
read -p "Enter destination AZ (Ex -> us-east-1a) ::" dest_az
read -p "Enter profile (cat 'user-home-directory'/.aws/config Ex -> default/bpbu12/bpbu13) ::" bpbu
if [ ! -z $source_id ] && [ ! -z $dest_id ] && [ ! -z $source_az ] && [ ! -z $dest_az ] && [ ! -z $bpbu ]
then
##To find source and destination Region
source_region=${source_az%?}
dest_region=${dest_az%?}
##Creating replication package
read -p "Do you want to create replication package (Y/N) ::" input
if [ "$input" == 'Y' -o "$input" == 'y' -o "$input" == 'YES' -o "$input" == 'yes' ]
then
create_rep
content_sync
else
content_sync
fi
else
printf "\nAll fields are mandatory"
exit 1
fi
