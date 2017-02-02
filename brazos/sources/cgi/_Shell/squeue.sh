#!/bin/bash

echo "<!QUEUE_TIME!>"
#TimeStamp

date +%s 2> /dev/null

echo "<!QUEUE_UTILIZATION!>"
#Queue	MaxRun	Running	Queued	Other

rm -f tmp.txt

partitions=$(echo ${4} | tr "," "\n")
for partition in $partitions
do
   COREINFO=$(sinfo -p $partition --noheader -o '%C') # need to parse the 'A/I/O/T' info this gives
   squeue -t PD --array --noheader -p $partition -o '%C' > request.txt # need to sum them all together
   squeue -t R --array --noheader -p $partition -o '%C' > run.txt # need to sum them all together
   squeue --array --noheader -p $partition -o '%C' > other.txt # need to sum them all together
   squeue -A hepx -t PD --array --noheader -p $partition -o '%C' > requesthepx.txt # need to sum them all together
   squeue -A hepx -t R --array --noheader -p $partition -o '%C' > runhepx.txt # need to sum them all together
   squeue -A hepx --array --noheader -p $partition -o '%C' > otherhepx.txt # need to sum them all together

   idlecores=$(echo $COREINFO | cut -f2 -d/)
   totalcores=$(echo $COREINFO | cut -f4 -d/)
   coresrequested=$(cat request.txt | paste -sd+ - | bc)
   coresrunning=$(cat run.txt | paste -sd+ - | bc)
   othercores=$(cat other.txt | paste -sd+ - | bc)
   coresrequestedhepx=$(cat requesthepx.txt | paste -sd+ - | bc)
   coresrunninghepx=$(cat runhepx.txt | paste -sd+ - | bc)
   othercoreshepx=$(cat otherhepx.txt | paste -sd+ - | bc)
   if [ "$coresrequested" == "" ] ; then
      coresrequested=0
   fi
   if [ "$coresrunning" == "" ] ; then
      coresrunning=0
   fi
   if [ "$othercores" == "" ] ; then
      othercores=0
   fi
   if [ "$coresrequestedhepx" == "" ] ; then
      coresrequestedhepx=0
   fi
   if [ "$coresrunninghepx" == "" ] ; then
      coresrunninghepx=0
   fi
   if [ "$othercoreshepx" == "" ] ; then
      othercoreshepx=0
   fi
   othercores=$((othercores - coresrunning - coresrequested))
   othercoreshepx=$((othercoreshepx - coresrunninghepx - coresrequestedhepx))

   echo $partition' '$totalcores' '$coresrunninghepx' '$coresrunning' '$coresrequestedhepx' '$coresrequested' '$othercoreshepx' '$othercores >> tmp.txt
done

cat tmp.txt | perl -ne 'chomp; print +( join "\t", map {(@$_[0,1,2,3,4,5,6,7])} [ split /\s+/ ])."\n";'
# this could probably be done better, but this gives the correct formatting that the monitor reads to put the numbers in the table correctly

rm -f tmp.txt
rm -f request.txt
rm -f run.txt
rm -f other.txt
rm -f requesthepx.txt
rm -f runhepx.txt
rm -f otherhepx.txt

echo "<!NULL!>"

exit 0

