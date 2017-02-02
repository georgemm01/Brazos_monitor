#!/bin/bash

echo "<!QUEUE_TIME!>"
#TimeStamp

date +%s 2> /dev/null

echo "<!QUEUE_UTILIZATION!>"
#Queue	MaxRun	Running	Queued	Other

${1:+"ssh ${1}${2:+" -p ${2}"}"} ${3:-"qstat"} -Q ${4} 2> /dev/null | grep -vP "Queue|---" 2> /dev/null | perl -ne \
	'chomp; print +( join "\t", map {(@$_[0,1,6,5],($$_[2]-$$_[5]-$$_[6]))} [ split /\s+/ ])."\n";'

echo "<!NULL!>"

exit 0

