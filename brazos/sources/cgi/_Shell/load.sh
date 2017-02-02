#!/bin/bash

echo "<!LOAD_TIME!>"
#TimeStamp

date +%s 2> /dev/null

#Active	Nodes	Active	Procs	Active	Cores	Active	PMem	Active	VMem
if [[ -n ${1} ]]; then echo "<!LOAD_CLUSTER!>"
	${2:+"ssh ${2}${3:+" -p ${3}"}"} ${4:-"qnodes"} 2> /dev/null | perl -ne \
		'END { print +( join "\t", @qndt )."\n" }
		/^c\d+[a-z]?$/ ? do { ($free,$proc,$jobs) = (); } :
		/^\s+state = (free$)?/ ? $free = !(!$1) :
		/^\s+np = (\d+)$/ ? $proc = 0+$1 :
		/^\s+jobs = (.*)$/ ? $jobs = 0+( grep { /^\d+\// } (split /,\s+/, $1)) :
		/^\s+status = (.*)$/ ? do { do {
			$qndt[0] += ((shift @$_) ne q(0)); $qndt[1]++; $qndt[2] += (($free) ? 0 : $jobs);
			$qndt[3] += $proc; $qndt[4] += (shift @$_); $qndt[5] += (shift @$_);
			s/kb$// for (@$_); $qndt[7] += $$_[0]; $qndt[9] += ($$_[1] - $$_[0]);
			do { $qndt[6] += $$_[0]; $qndt[8] += ($$_[1] - $$_[0]); } for [
				map {(( sort {$a <=> $b} @$_ )[0],$$_[1])} [$$_[0],$$_[1]-$$_[2]]]; } for [
			@{{ map {( /^([a-z]+)=(.*)$/ )} (split /\,/, $1) }}{ qw( nusers loadave ncpus physmem totmem availmem )}] } :
		undef ; '
fi

#Active	Tasks	UserCpu	SysCpu	Load Users	MemUse	MemTot	SwpUse	SwpTot
if [[ -n ${5} ]]; then echo "<!LOAD_HEAD_1!>"
	rm -f ~/.toprc 2> /dev/null && ${6:+"ssh ${6}${7:+" -p ${7}"}"} ${8:-"top"} -b -n1 2> /dev/null | head -5 2> /dev/null | perl -ne \
		'END { $mema = (( grep {(defined)} ($memu,$memb,$memc)) == 3) ? ($memu-$memb-$memc) : undef;
			print +( join "\t", ($actv,$tsks,$cpuu,$cpus,$load,$usrs,$mema,$memt,$swpu,$swpt))."\n" }
		/^top.*?(\d+)\s+users,.*?load\s+average:\s+\d+\.\d+,\s+(\d+\.\d+)/ ? ($usrs,$load) = ($1,$2) :
		/^Tasks:\s+(\d+)\s+total,\s+(\d+)\s+running,/ ? ($tsks,$actv) = ($1,$2) :
		/^Cpu\(s\):\s+(\d+\.\d+)%us,\s+(\d+\.\d+)%sy,/ ? ($cpuu,$cpus) = ($1,$2) :
		/^Mem:\s+(\d+)k\s+total,\s+(\d+)k\s+used,.*?(\d+)k\s+buffers$/ ? ($memt,$memu,$memb) = ($1,$2,$3) :
		/^Swap:\s+(\d+)k\s+total,\s+(\d+)k\s+used,.*?(\d+)k\s+cached$/ ? ($swpt,$swpu,$memc) = ($1,$2,$3) :
		undef ; '
fi

#Active	Tasks	UserCpu	SysCpu	Load Users	MemUse	MemTot	SwpUse	SwpTot
if [[ -n ${9} ]]; then echo "<!LOAD_HEAD_2!>"
	rm -f ~/.toprc 2> /dev/null && ${10:+"ssh ${10}${11:+" -p ${11}"}"} ${12:-"top"} -b -n1 2> /dev/null | head -5 2> /dev/null | perl -ne \
		'END { $mema = (( grep {(defined)} ($memu,$memb,$memc)) == 3) ? ($memu-$memb-$memc) : undef;
			print +( join "\t", ($actv,$tsks,$cpuu,$cpus,$load,$usrs,$mema,$memt,$swpu,$swpt))."\n" }
		/^top.*?(\d+)\s+users,.*?load\s+average:\s+\d+\.\d+,\s+(\d+\.\d+)/ ? ($usrs,$load) = ($1,$2) :
		/^Tasks:\s+(\d+)\s+total,\s+(\d+)\s+running,/ ? ($tsks,$actv) = ($1,$2) :
		/^Cpu\(s\):\s+(\d+\.\d+)%us,\s+(\d+\.\d+)%sy,/ ? ($cpuu,$cpus) = ($1,$2) :
		/^Mem:\s+(\d+)k\s+total,\s+(\d+)k\s+used,.*?(\d+)k\s+buffers$/ ? ($memt,$memu,$memb) = ($1,$2,$3) :
		/^Swap:\s+(\d+)k\s+total,\s+(\d+)k\s+used,.*?(\d+)k\s+cached$/ ? ($swpt,$swpu,$memc) = ($1,$2,$3) :
		undef ; '
fi

#Run	Proc	%CPU	Time	%MEM	RSS	VSZ
if [[ -n ${13} ]]; then echo "<!LOAD_PROCESS_1!>"
	${14:+"ssh ${14}${15:+" -p ${15}"}"} ${16:-"ps"} -o state= -o etime= -o pcpu= -o pmem= -o rssize= -o vsize= -o comm= -A 2> /dev/null | perl -ne \
		'END { print +( join "\t", map { (( int ( 100*$_ + 0.5 )) / 100 ) }
			($r,$p,,( map {($_/$p)} ($t[0],$s,@t[1..3]))))."\n" if ($p) }
		chomp; (@s) = ( split /\s+/ ); next unless $s[6] =~ /^'${13}'/;
		$p++; $r += ((shift @s) eq q(R));
		((shift @s) =~ /^(?:(?:(\d+)-)?(\d+):)?(\d+):(\d+)$/) &&
			do { $s += ($1*24*60*60 + $2*60*60 + $3*60 + $4) };
		$t[$_] += $s[$_] for (0..3);'
fi

#Run	Proc	%CPU	Time	%MEM	RSS	VSZ
if [[ -n ${17} ]]; then echo "<!LOAD_PROCESS_2!>"
	${18:+"ssh ${18}${19:+" -p ${19}"}"} ${20:-"ps"} -o state= -o etime= -o pcpu= -o pmem= -o rssize= -o vsize= -o comm= -A 2> /dev/null | perl -ne \
		'END { print +( join "\t", map { (( int ( 100*$_ + 0.5 )) / 100 ) }
			($r,$p,,( map {($_/$p)} ($t[0],$s,@t[1..3]))))."\n" if ($p) }
		chomp; (@s) = ( split /\s+/ ); next unless $s[6] =~ /^'${17}'/;
		$p++; $r += ((shift @s) eq q(R));
		((shift @s) =~ /^(?:(?:(\d+)-)?(\d+):)?(\d+):(\d+)$/) &&
			do { $s += ($1*24*60*60 + $2*60*60 + $3*60 + $4) };
		$t[$_] += $s[$_] for (0..3);'
fi

echo "<!NULL!>"

exit 0

