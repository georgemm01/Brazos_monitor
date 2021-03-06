#!/bin/bash

# initialize some needed variables
stagger_writes=15
writevar=''
itrctr=1

# get all needed info for parsing and put in array
squeue -A hepx -r -h -t R,S,CA,CF,CG,CD,F,TO,NF,SE,BF,PR -o '%i %u %y %t %P %V %S %e %V %m %M %N@%c %u(%U) %l %D:ppn=%c %C' > squeue_info_parse.txt
squeue -A hepx -h -t PD -o '%i %u %y %t %P %V %S %e %V %m %M %N@%c %u(%U) %l %D:ppn=%c %C' > squeue_pending.txt

# let's write all info for pending jobs to file in correct format
while IFS= read -r line; do

# put all info for this specific job into an array - DON'T want to just loop over it
  IFS=$' ' read -r -d '' -a lineentry <<< "$line"

# parse jobid, get/set start stop
  num=$(grep -oF "[" <<< "${lineentry[0]}" | wc -l)
  if [ $num -eq 0 ] ; then
    splitbase=$(grep -oF "_" <<< "${lineentry[0]}" | wc -l)
    if [ $splitbase -eq 0 ] ; then
      base=${lineentry[0]}
    else
      base=$(echo ${lineentry[0]} | cut -f1 -d_)
      job=$(echo ${lineentry[0]} | cut -f2 -d_)
      base=$((base + job))
    fi
    startindex=0
    stopindex=0
  else
    base=$(echo ${lineentry[0]} | cut -f1 -d_)
    stopindex=$(echo ${lineentry[0]} | cut -f2 -d[)
    stopindex=$(echo $stopindex | cut -f1 -d])
    startindex=$(echo $stopindex | cut -f1 -d-)
    stopindex=$(echo $stopindex | cut -f2 -d-)
  fi

# for each line, we iterate over all pending jobs (either only one or certain number from array
  for job in `seq $startindex $stopindex`
  do

    #if [ $itrctr -gt 25 ] ; then break; fi; # for debugging only!
    itrctr=$((itrctr+1));

# all pre-formatting that needs to be done first
    jobid=$(( base + job )) # JOBID
    jobstate='PD'

    for((itr=0, itrarr=5; itr<=3; itr++, itrarr++ ))
    do
      year[$itr]=$(echo ${lineentry[$itrarr]} | cut -f1 -d-)
      month[$itr]=$(echo ${lineentry[$itrarr]} | cut -f2 -d-)
      case "${month[$itr]}" in
         01 ) month[$itr]="Jan" ;; 02 ) month[$itr]="Feb" ;; 03 ) month[$itr]="Mar" ;; 04 ) month[$itr]="Apr" ;;
         05 ) month[$itr]="May" ;; 06 ) month[$itr]="Jun" ;; 07 ) month[$itr]="Jul" ;; 08 ) month[$itr]="Aug" ;;
         09 ) month[$itr]="Sep" ;; 10 ) month[$itr]="Oct" ;; 11 ) month[$itr]="Nov" ;; 12 ) month[$itr]="Dec" ;;
      esac
      day[$itr]=$(echo ${lineentry[$itrarr]} | cut -f3 -d-)
      day[$itr]=$(echo ${day[$itr]} | cut -f1 -dT)
      ttime[$itr]=$(echo ${lineentry[$itrarr]} | cut -f2 -dT)
    done # Q/M/C/E TIME
 
    if [ "${lineentry[9]: -1}" == "M" ] ; then
       mem=${lineentry[9]%M}
       mem=$(( mem * 1000000 )) # MEMORY (in B)
    elif [ "${lineentry[9]: -1}" == "G" ] ; then
       mem=${lineentry[9]%G}
       mem=$(bc <<< "scale=0; $mem*1000000000") # MEMORY (in B)
    else
       echo ERROR: memory not in expected format, look into this!
       exit -1
    fi

    for(( itr=0; itr<=1; itr++ ))
    do
      if [ $itr -eq 0 ] ; then
        entry=${lineentry[10]}
      else
        entry=${lineentry[13]}
      fi
 
      hours[$itr]="10#"0
      case "$entry" in
         *-* )
            daystohours=$(echo $entry | cut -f1 -d-)
            daystohours="10#"$daystohours
            hours[$itr]=$((daystohours * 24))
            hours[$itr]="10#"$hours
            entry=$(echo $entry | cut -f2 -d-)
      esac
      num=$(grep -oF ":" <<< "$entry" | wc -l)
      if [ $num -eq 2 ] ; then
         hourstoadd=$(echo $entry | cut -f1 -d:)
         hourstoadd="10#"$hourstoadd
         hours[$itr]=$(( ${hours[$itr]} + hourstoadd))
         minutes[$itr]=$(echo $entry | cut -f2 -d:)
         seconds[$itr]=$(echo $entry | cut -f3 -d:)
      elif [ $num -eq 1 ] ; then
         minutes[$itr]=$(echo $entry | cut -f1 -d:)
         seconds[$itr]=$(echo $entry | cut -f2 -d:)
      elif [ $num -eq 0 ] ; then
         seconds[$itr]=$(echo $entry | cut -f2 -d:)
      fi
      if [ $((${hours[$itr]})) -eq 0 ] ; then
         hours[$itr]="00"
      fi
      if [ ${minutes[$itr]} -eq 0 ] ; then
         minutes[$itr]="00"
      fi
      if [ ${seconds[$itr]} -eq 0 ] ; then
         seconds[$itr]="00"
      fi
    done # CPU/WALL-TIME

# print job info in proper format:
    if [ $((itrctr%stagger_writes)) -eq 0 ] ; then
      #echo $itrctr $(date)
      echo -n "${writevar}"
      writevar=''
    fi
    writevar=$writevar"Job Id: "$jobid$'\n'
    writevar=$writevar"        Job_Name = dummy"$'\n' # doesn't matter ...
    writevar=$writevar"        Job_Owner = "${lineentry[1]}"@login02"$'\n' # don't think the submission node matters ...
    writevar=$writevar"        GroupID = 2015"$'\n' # only hepx users being probed here
    writevar=$writevar"        Nice = "${lineentry[2]}$'\n'
    writevar=$writevar"        job_state = "$jobstate$'\n'
    writevar=$writevar"        queue = "${lineentry[4]}$'\n'
    writevar=$writevar"        Account = hepx"$'\n' # only hepx users being probed here
    writevar=$writevar"        qtime = Thu "${month[0]}" "${day[0]}" "${ttime[0]}" "${year[0]}$'\n' #day of week ? is it needed?
    writevar=$writevar"        mtime = Thu "${month[1]}" "${day[1]}" "${ttime[1]}" "${year[1]}$'\n' #day of week ? is it needed?
    writevar=$writevar"        ctime = Thu "${month[2]}" "${day[2]}" "${ttime[2]}" "${year[2]}$'\n' #day of week ? is it needed?
    writevar=$writevar"        etime = Thu "${month[3]}" "${day[3]}" "${ttime[3]}" "${year[3]}$'\n' #day of week ? is it needed?
    writevar=$writevar"        reque = 1"$'\n' # probably doesn't matter ...
    writevar=$writevar"        resources_used.mem = "$mem$'\n'
    writevar=$writevar"        resources_used.cput = "${hours[0]}":"${minutes[0]}":"${seconds[0]}$'\n'
    writevar=$writevar"        Account_Name = hepx"$'\n' # only hepx users being probed here
    writevar=$writevar"        Priority = 0"$'\n' # probably doesn't matter ...
    writevar=$writevar"        euser = "${lineentry[12]}$'\n'
    writevar=$writevar"        egroup = hepx(2015)"$'\n' # only hepx users being probed here
    writevar=$writevar"        resources_used.walltime = "${hours[1]}":"${minutes[1]}":"${seconds[1]}$'\n'
    writevar=$writevar"        Resource_List.nodes = "${lineentry[14]}$'\n'
    writevar=$writevar"        Resource_List.ncpus = "${lineentry[15]} # last in array already includes a newline
    writevar=$writevar"        command = dummy"$'\n' # doesn't matter
    writevar=$writevar"        stderr = "$'\n'$'\n' # doesn't matter
  done
done < "squeue_pending.txt"

echo -n "${writevar}"
#echo last $(date)
writevar=''
itrctr=1
rm -f squeue_pending.txt

# now loop over all non-pending jobs and write info in correct format to raw file
while IFS= read -r line; do

  #if [ $itrctr -gt 25 ] ; then break; fi; # for debugging only!
  itrctr=$((itrctr+1));

# put all info for this specific job into an array - DON'T want to just loop over it
  IFS=$' ' read -r -d '' -a lineentry <<< "$line"

# all pre-formatting that needs to be done:
  base=$(echo ${lineentry[0]} | cut -f1 -d_)
  index=$(echo ${lineentry[0]} | cut -f2 -d_)
  jobid=$(( base + index )) # JOBID

  case ${lineentry[3]} in
    PD ) jobstate='Q' ;;   #pending/queued
    R ) jobstate='R' ;;    #running
    CD ) jobstate='C' ;;   #completed
    CG ) jobstate='E' ;;   #completing/exiting
    PR ) jobstate='S' ;;   #preempted/suspend (?)
    S ) jobstate='H' ;;    #suspended/held
    CF ) jobstate='W' ;;   #configuring/waiting (?)
    * ) jobstate='T' ;;    #special exit/transfer (?)
  esac # JOBSTATE

  for((itr=0, itrarr=5; itr<=3; itr++, itrarr++ ))
  do
    year[$itr]=$(echo ${lineentry[$itrarr]} | cut -f1 -d-)
    month[$itr]=$(echo ${lineentry[$itrarr]} | cut -f2 -d-)
    case "${month[$itr]}" in
       01 ) month[$itr]="Jan" ;; 02 ) month[$itr]="Feb" ;; 03 ) month[$itr]="Mar" ;; 04 ) month[$itr]="Apr" ;;
       05 ) month[$itr]="May" ;; 06 ) month[$itr]="Jun" ;; 07 ) month[$itr]="Jul" ;; 08 ) month[$itr]="Aug" ;;
       09 ) month[$itr]="Sep" ;; 10 ) month[$itr]="Oct" ;; 11 ) month[$itr]="Nov" ;; 12 ) month[$itr]="Dec" ;;
    esac
    day[$itr]=$(echo ${lineentry[$itrarr]} | cut -f3 -d-)
    day[$itr]=$(echo ${day[$itr]} | cut -f1 -dT)
    ttime[$itr]=$(echo ${lineentry[$itrarr]} | cut -f2 -dT)
  done # Q/M/C/E TIME

  if [ "${lineentry[9]: -1}" == "M" ] ; then
     mem=${lineentry[9]%M}
     mem=$(( mem * 1000000 )) # MEMORY (in B)
  elif [ "${lineentry[9]: -1}" == "G" ] ; then
     mem=${lineentry[9]%G}
     mem=$(bc <<< "scale=0; $mem*1000000000") # MEMORY (in B)
  else
     echo ERROR: memory not in expected format, look into this!
     exit -1
  fi

  node=$(echo ${lineentry[11]} | cut -f1 -d@)
# aren't look at pending jobs in this loop, this if conditional probably
# isn't necessary, but just in case I guess...
  if [ "$node" != "" ] ; then
     hostentry=""
     ppn=$(echo ${lineentry[11]} | cut -f2 -d@)
     IFS=$',' read -r -d '' -a separatenodes <<< "$node"
     nodeitr=0
     for nodes in "${separatenodes[@]}"
     do
        nodeitr=$((nodeitr + 1))
        bracket=$(grep -oF "[" <<< "$nodes" | wc -l)
        if [ "$bracket" == "1" ] ; then
           nodebase=$(echo $nodes | cut -f1 -d[)
           for((nodeitr=1; nodeitr<=2; ++nodeitr))
           do
              for((itr=0; itr<$((ppn - 1)); ++itr))
              do
                 hostentry=$hostentry$nodebase$nodeitr/$itr+
              done
              hostentry=$hostentry$nodebase$nodeitr/$((ppn-1))
              if [ "$nodeitr" != "${#separatenodes[@]}" ] ; then
                 hostentry=$hostentry+
              fi
           done
        else
# whitespace at end of var we need to get rid of
           nodes="$(echo -e "$nodes" | tr -d '[[:space:]]')"
           for((itr=0; itr<$((ppn - 1)); ++itr))
           do
              hostentry=$hostentry$nodes/$itr+
           done
           hostentry=$hostentry$nodes/$((ppn-1))
           if [ "$nodeitr" != "${#separatenodes[@]}" ] ; then
              hostentry=$hostentry+
           fi
        fi
     done
  fi # NODE/CPU LIST

  for(( itr=0; itr<=1; itr++ ))
  do
    if [ $itr -eq 0 ] ; then
      entry=${lineentry[10]}
    else
      entry=${lineentry[13]}
    fi

    hours[$itr]="10#"0
    case "$entry" in
       *-* )
          daystohours=$(echo $entry | cut -f1 -d-)
          daystohours="10#"$daystohours
          hours[$itr]=$((daystohours * 24))
          hours[$itr]="10#"$hours
          entry=$(echo $entry | cut -f2 -d-)
    esac
    num=$(grep -oF ":" <<< "$entry" | wc -l)
    if [ $num -eq 2 ] ; then
       hourstoadd=$(echo $entry | cut -f1 -d:)
       hourstoadd="10#"$hourstoadd
       hours[$itr]=$(( ${hours[$itr]} + hourstoadd))
       minutes[$itr]=$(echo $entry | cut -f2 -d:)
       seconds[$itr]=$(echo $entry | cut -f3 -d:)
    elif [ $num -eq 1 ] ; then
       minutes[$itr]=$(echo $entry | cut -f1 -d:)
       seconds[$itr]=$(echo $entry | cut -f2 -d:)
    elif [ $num -eq 0 ] ; then
       seconds[$itr]=$(echo $entry | cut -f2 -d:)
    fi
    if [ $((${hours[$itr]})) -eq 0 ] ; then
       hours[$itr]="00"
    fi
    if [ ${minutes[$itr]} -eq 0 ] ; then
       minutes[$itr]="00"
    fi
    if [ ${seconds[$itr]} -eq 0 ] ; then
       seconds[$itr]="00"
    fi
  done # CPU/WALL-TIME

# print job info in proper format:
  if [ $((itrctr%stagger_writes)) -eq 0 ] ; then
    echo -n "${writevar}"
    #echo $itrctr $(date)
    writevar=''
  fi
  writevar=$writevar"Job Id: "$jobid$'\n'
  writevar=$writevar"        Job_Name = dummy"$'\n' # doesn't matter ...
  writevar=$writevar"        Job_Owner = "${lineentry[1]}"@login02"$'\n' # don't think the submission node matters ...
  writevar=$writevar"        GroupID = 2015"$'\n' # only hepx users being probed here
  writevar=$writevar"        Nice = "${lineentry[2]}$'\n'
  writevar=$writevar"        job_state = "$jobstate$'\n'
  writevar=$writevar"        queue = "${lineentry[4]}$'\n'
  writevar=$writevar"        Account = hepx"$'\n' # only hepx users being probed here
  writevar=$writevar"        qtime = Thu "${month[0]}" "${day[0]}" "${ttime[0]}" "${year[0]}$'\n' #day of week ? is it needed?
  writevar=$writevar"        mtime = Thu "${month[1]}" "${day[1]}" "${ttime[1]}" "${year[1]}$'\n' #day of week ? is it needed?
  writevar=$writevar"        ctime = Thu "${month[2]}" "${day[2]}" "${ttime[2]}" "${year[2]}$'\n' #day of week ? is it needed?
  writevar=$writevar"        etime = Thu "${month[3]}" "${day[3]}" "${ttime[3]}" "${year[3]}$'\n' #day of week ? is it needed?
  writevar=$writevar"        reque = 1"$'\n' # probably doesn't matter ...
  writevar=$writevar"        resources_used.mem = "$mem$'\n'
  writevar=$writevar"        resources_used.cput = "${hours[0]}":"${minutes[0]}":"${seconds[0]}$'\n'
  writevar=$writevar"        Account_Name = hepx"$'\n' # only hepx users being probed here
  if [ "$node" != "" ] ; then
    writevar=$writevar"        exec_host = "$hostentry$'\n'
  fi
  writevar=$writevar"        Priority = 0"$'\n' # probably doesn't matter ...
  writevar=$writevar"        euser = "${lineentry[12]}$'\n'
  writevar=$writevar"        egroup = hepx(2015)"$'\n' # only hepx users being probed here
  writevar=$writevar"        resources_used.walltime = "${hours[1]}":"${minutes[1]}":"${seconds[1]}$'\n'
  writevar=$writevar"        Resource_List.nodes = "${lineentry[14]}$'\n'
  writevar=$writevar"        Resource_List.ncpus = "${lineentry[15]} # last in array already includes a newline
  writevar=$writevar"        command = dummy"$'\n' # doesn't matter
  writevar=$writevar"        stderr = "$'\n'$'\n' # doesn't matter
done < "squeue_info_parse.txt"

echo -n "${writevar}"
#echo last $(date)

rm -f squeue_info_parse.txt

exit
