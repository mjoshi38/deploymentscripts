#!/bin/bash

#########################################################################################################
#This script will clear the dispatcher cache for all the paths specifed. Kindly use the same cautiously.
#########################################################################################################

DATE_TIME=`date "+%Y%m%d-%H%M"`
FILEPATH="/usr/jail/home/jailed-user/pathlist"
OUTPUT_LOG="/mnt/var/log/httpd/dispatcherflushcron.log"

if [ -f "$FILEPATH" ]
	then
	dos2unix "$FILEPATH"	
	LINE=`wc -l "$FILEPATH" | awk -F ' ' '{print $1}'`
		if [[ "$LINE" == 0 ]]
		then
		printf "File is empty. Skipping..\n" | tee -a "$OUTPUT_LOG"
		exit 1
		else
		while read -r path || [ -n "$path" ]
		do	
		STARTING=`echo "$path" | sed 's/\(html\).*/\1/g'`
			if [ "$STARTING" == '/mnt/var/www/html' ]
				then
				FROMHTML=`echo "$path" | sed 's/.*\(html\)/\1/g'`
				HTMLANDNEXTWO=`echo "$FROMHTML" | cut -d'/' -f-3`
				FROMCONTENT=`echo "$path" | sed 's/.*\(content\)/\1/g'`
				CONTENTANDNEXTHREE=`echo "$FROMCONTENT" | cut -d'/' -f-4`
				if [[ "$HTMLANDNEXTWO" == *[*]* ]]
				#if [[ "$HTMLANDNEXTWO" == *[@#\$%^\&*()_+]* ]]
					then
					printf "Contains wildcard therfore skipping, Cache can't be cleared for the path '$path' Skipping..\n" | tee -a "$OUTPUT_LOG"	
					else
					if [[ "$CONTENTANDNEXTHREE" == *[*]* ]]
						then
						printf "Inside Content.... Contains wildcard therfore skipping, Cache can't be cleared for the path '$path' Skipping..\n" | tee -a "$OUTPUT_LOG"
						else
						for i in $path
						do
						printf "Clearing cache for the path '$i'\n" | tee -a "$OUTPUT_LOG"
						#rm -vf "$i" 2>&1 | tee -a "$OUTPUT_LOG"
						done
					fi
				fi
			else
			printf "Not starting with /mnt/var/www/html, therefore Cache can't be cleared for the path '$path' Skipping..\n" | tee -a "$OUTPUT_LOG"
			fi
		done < "$FILEPATH"
		printf "Marking dispatcher flush as completed.\n" | tee -a "$OUTPUT_LOG"
		#mv "$FILEPATH" "$FILEPATH"."$DATE_TIME"
		#touch "$FILEPATH"
		exit 0
		fi
	else
	printf "File is not present. Skipping..\n" | tee -a "$OUTPUT_LOG"
	exit 1
fi
