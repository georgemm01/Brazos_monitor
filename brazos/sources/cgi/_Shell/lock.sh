#!/bin/bash

LOCK_TYPE=${1}
FILE_HANDLE=${2}
NAP_TIME=${3}
RETRY_COUNT=${4}
LOCK_FILE=${PWD}/${5}
GOODSLEEP_TIME=${6}

[[ "${LOCK_TYPE}" == "xn" ]] || [[ "${LOCK_TYPE}" == "sn" ]] || [[ "${LOCK_TYPE}" == "x" ]] || [[ "${LOCK_TYPE}" == "s" ]] && : || { echo "WRONG LOCK TYPE: use only {xn,sn,x,n}, from flock manual."; flock -h; exit 0;}

for ((i = 1; i <= RETRY_COUNT; i++))
do
	(
  	if flock -${LOCK_TYPE} ${FILE_HANDLE} ; then 
 		echo "File handle: "${2}"     File: "${LOCK_FILE}"       On success will sleep for: "${GOODSLEEP_TIME}
  		echo "Running and locking..."
  		${LOCK_FILE}
		STAT=$?
		[[ "$STAT" -eq 101 ]] && { echo "ALARM TRIGGERED, email sent. Good-sleeping..."; sleep ${GOODSLEEP_TIME}; }
  		echo "Done... Lock Released"
		exit 100;
	else 
		echo "Try $i"; 
		[[ "$i" -eq RETRY_COUNT ]] && exit 200;
		echo "cannot acquire lock, will try again... sleeping"
	   	sleep ${NAP_TIME}
	fi
	){FILE_HANDLE}<${LOCK_FILE}
	STAT=$?
        [[ "$STAT" -eq 100 ]] && break
        [[ "$STAT" -eq 200 ]] && echo "Couldn't acquire lock... Probably still busy with prior process. Exit"
done

exit 0
