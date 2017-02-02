#!/bin/bash

echo "<!CONDORQ_TIME!>"

date +%s 2> /dev/null

echo "<!CONDORQ!>"

${1:+"ssh ${1}${2:+" -p ${2}"}"} ${3:-"condor_q"} \
	-format '%-1u\\t' ClusterId \
	-format '%-1u\\t' ProcId \
	-format '%-1s\\t' Owner \
	-format '%-1u\\t' JobUniverse \
	-format '%-1u\\t' JobStatus \
	-format '%-1u\\t' RequestCpus \
	-format '%-1u\\t' ImageSize \
	-format '%-1.0f\\t' RemoteUserCpu \
	-format '%-1.0f\\t' RemoteSysCpu \
	-format '%-1.0f\\t' RemoteWallClockTime \
	-format '%-1.0f\\t' CumulativeSuspensionTime \
	-format '%-1u\\t' QDate \
	-format '%-1u\\n' CompletionDate \
	2> /dev/null | perl -ne \
	's/\\n/\n/g; s/\\t/\t/g; print'

echo "<!NULL!>"

exit 0

