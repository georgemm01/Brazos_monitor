#!/bin/bash

jobthreshold=50
usethreshold=0.90
hepxmax=700
hepxthres=0.8

activenodes=$((sinfo -p background,background-4g -t ALLOC -o '%n|%C|%m|%O|%f' --noheader && sinfo -p background-4g -t ALLOC -o '%n|%C|%m|%O|%f' --noheader ) | wc -l);
idlenodes=$((sinfo -p background,background-4g -t IDLE -o '%n|%C|%m|%O|%f' --noheader && sinfo -p background-4g -t IDLE -o '%n|%C|%m|%O|%f' --noheader )| wc -l);
totalnodes=$((activenodes+idlenodes));
queuedjobs=$(squeue -t PD --array --noheader | wc -l);
ourquedjobs=$(squeue -t PD -A hepx,cms --array --noheader | wc -l);
queuecores=$(squeue -t PD --array -o '%c' | awk '$1<17' | awk '{ SUM += $1} END { print SUM }');
totalcores=$(sinfo -o '%C' --noheader | cut -d / -f 4);
hepxruncores=$(squeue -t R -p stakeholder,stakeholder-4g --array -o '%C' | awk '{ SUM += $1} END { print SUM }');
hepxquecores=$(squeue -t PD -p stakeholder,stakeholder-4g --array -o '%c' | awk '{ SUM += $1} END { print SUM }');

useratio=$(echo "scale=5; $activenodes/$totalnodes" | bc);
threscores=$(echo "scale=3; 0.05*$totalcores" | bc);
hepxloadratio=$(echo "scale=3; $hepxquecores/$queuecores" | bc);

echo "USAGERATIO: "$useratio" | QueuedJobs: "$queuedjobs" | QueuedCores: "$queuecores" | TotalCores: "$totalcores" | Alarm-Core-Threshold: "$threscores

# if many cores are requested, and the useratio is low, and jobs are queued
if (($(echo "$queuecores > $threscores" | bc -l) )) && (($(echo "$useratio < $usethreshold" | bc -l) )) && (($queuedjobs > $jobthreshold)) ; then 
         # keep in mind that big-core single-node jobs may be submitted, hence the core usage may be relatively low
    SUBJECT="Brazos Alert: Core Usage Low, Partitions Stuck"
    EMAIL="georgemm01@physics.tamu.edu"
    HEPXMAIL="hepx-monitor@brazos.tamu.edu"
    EMAILMESSAGE="/home/hepxmon/mon/backfillalarm.txt"
    echo "This is an automated message from the Brazos CMS Site Monitoring System" >$EMAILMESSAGE
    echo " " >>$EMAILMESSAGE
    if (($(echo "$hepxloadratio > $hepxthres" | bc -l) )) ; then 
        SUBJECT="Brazos Alert: Stakeholder queues are too loaded, users may move jobs to background queues (or perhaps backfill is stuck)."
	echo "Most jobs (core requests) are queued in stakeholder or stakeholder-4g, it is advisable to move some of the pending jobs to other queues. " $hepxruncores " cores are running in stakeholder and stakeholder-4g, " $hepxquecores " cores are queued in them, out of " $queuecores " total in the cluster." >>$EMAILMESSAGE
        echo " " >>$EMAILMESSAGE
    fi
    echo "Node Usage Ratio is " $useratio " and " $queuedjobs " jobs are queued requesting " $queuecores " cores (excluding FAT node requests)." >>$EMAILMESSAGE
    echo "Backfill could be stuck, or jobs are not submitted in the right queues.">>$EMAILMESSAGE
    echo " ">>$EMAILMESSAGE
    cat $EMAILMESSAGE | mail -r "$HEPXMAIL" -s "$SUBJECT" "$EMAIL" 
    exit 101
fi

echo "Alarm not triggered..."
