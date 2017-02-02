#!/bin/bash

. ~/.bashrc

echo "<!HEARTBEAT_TIME!>"
#TimeStamp

date +%s 2> /dev/null

echo "<!HEARTBEAT_SSH!>"
#Can SSH Across Cluster: 1

#tmp="${1:+"ssh ${1}${2:+" -p ${2}"} echo 1"}"; 
## Commented for Brazos only! (no ssh keys allowed)
## instead, just echo 1 faking the test...
tmp="echo 1"; $tmp 2> /dev/null

echo "<!HEARTBEAT_MOUNT!>"
#Can Access Filesystem Mount: 1

[[ -d ${3} ]] 2> /dev/null && echo "1"

echo "<!HEARTBEAT_DF!>"
#Size of Filesystem Partition

df -P ${3} 2> /dev/null | grep "${3}" 2> /dev/null | sed -ne 's/^[^ ]*[ ]*\([0-9]*\)[ ]*\([0-9]*\).*$/\2\n\1/p' 2> /dev/null

echo "<!HEARTBEAT_DF_QUERY!>"
#DF Query Directory

echo "df -P ${3}"

echo "<!HEARTBEAT_DU!>"
#Can Run DU on a Small Directory : 1 

stim=$( date 2> /dev/null ); /usr/bin/time \
	-f $( date -d "${stim}" +%s 2> /dev/null )"\t%E\t%P\t%F\t%W" \
	-o ${BRAZOS_BASE_PATH}${BRAZOS_MON_PATH}/DOWNLOAD/heartbeat_time.txt \
	du --max-depth=0 ${4} \
	2> ${BRAZOS_BASE_PATH}${BRAZOS_MON_PATH}/DOWNLOAD/heartbeat_errors.txt \
	| grep "${4}" 2> /dev/null | wc -l 2> /dev/null

echo "<!HEARTBEAT_DU_ERRORS!>"
#Number of Errors

cat ${BRAZOS_BASE_PATH}${BRAZOS_MON_PATH}/DOWNLOAD/heartbeat_errors.txt 2> /dev/null | perl -ne \
	'END { print +(0+$errs)."\n" } /Input\/output error/ && $errs++;';

echo "<!HEARTBEAT_DU_TIME!>"
#Stamp	Wall	%CPU	Faults	Swaps

cat ${BRAZOS_BASE_PATH}${BRAZOS_MON_PATH}/DOWNLOAD/heartbeat_time.txt 2> /dev/null

echo "<!HEARTBEAT_DU_QUERY!>"
#DU Query Directory

echo "du --max-depth=0 ${4}"

echo "<!NULL!>"

printf "%s\t%s\n" \
	"$( cat ${BRAZOS_BASE_PATH}${BRAZOS_MON_PATH}/DOWNLOAD/heartbeat_time.txt 2> /dev/null )" \
	"$( date -d "${stim}" +"%A, %d-%b-%Y %H:%M:%S %Z" 2> /dev/null )" \
	2> /dev/null >> ${BRAZOS_BASE_PATH}${BRAZOS_MON_PATH}/LOGS/HEARTBEAT_DATA/time_disk_usage.txt

exit 0

