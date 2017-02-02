#!/usr/bin/perl

use strict;
use FindBin (); use lib $FindBin::RealBin.'/..';
use Local::Path qw(:all);
use Local::Subs ();
use Time::Local ();
my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();
local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($bckg) = m/\b(?:bg|background)\b/i;
my ($task) = q(squeue_hepxjobs);
system( 'rm '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt > /dev/null 2>&1' );
Local::Subs::BACKGROUND_SELF() if ($bckg);

my ($sshh) = map { (length $$_[0]) ? q(ssh ).($$_[0]).q( ).((length $$_[1]) ? q(-p ).$$_[1].q( ) : q()) : q() } map {[ /^(.*?):?(\d*)$/ ]}
	           (( split /\s+/, ${ Local::Subs::CONFIG_MODULES('SQUEUE_HEPXJOBS_DATA') || {}}{'SSH'} ), undef )[0];
my ($cmmd) = map { (length) ? do { /(?:^|\/)squeue$/ && !(/\s/) or die 'Invalid qstat executable path'; $_ } : q(squeue) }
                   ${ Local::Subs::CONFIG_MODULES('SQUEUE_HEPXJOBS_DATA') || {}}{'COMMAND'};
( length ( my $ques = join ' ', ( my (@ques) = ( grep { (length) } map { split /[,\s]+/ }
                   ${ Local::Subs::CONFIG_MODULES('SQUEUE_HEPXJOBS_DATA') || {}}{'QUEUES'} ))))
	           or die 'Cannot Establish List of Job Queues for Module SQUEUE_HEPXJOBS_DATA';
my ($nick) = map { scalar { map { m/^([a-z]+|[a-z]+\-[\w]+)\s*:\s*([\w\s\.-]+)$/i ? (qq($1),(uc $2)) : () }
	           ( split /\s*,\s*/, $_ ) }} ${ Local::Subs::CONFIG_MODULES('SQUEUE_HEPXJOBS_DATA') || {}}{'NAMES'};
my (%idex) = map {( $ques[$_] => $_ )} (0..(@ques-1)); my (@nams) = map { (length $$nick{$_}) ? ($$nick{$_}) : (uc) } (@ques); my (@xmpt);
	           ($xmpt[$idex{$_}] = 1) for ( grep { (length) } map { split /[,\s]+/ }
                   ${ Local::Subs::CONFIG_MODULES('SQUEUE_HEPXJOBS_DATA') || {}}{'EXEMPT'} );
my ($time) = (time);

# Removed $ques list because in slurm-qstat it doesn't work, and still the monitor reads only desired queues.
#system(($sshh.$cmmd).' -f -1 '.($ques).' 2> /dev/null > '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_raw.txt' );
#system(($sshh.$cmmd).' -f -1 2> /dev/null > '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_raw.txt' );

do {
        my ($pidf) = grep {(defined)} fork() or die '2: Error Forking Process ... Exiting';
	do {
             setpgrp(0,0);
             exec ( BASE_PATH.CGI_PATH.'/_Shell/'.${task}.'.sh '.($sshh.$cmmd.$ques).' > ' .
		    BASE_PATH.MON_PATH.'/DOWNLOAD/'.${task}.'_data_raw.txt');
             exit 0
        } if ($pidf == 0);
	eval {
               local $SIG{ALRM} = sub { die };
               alarm 900;
               waitpid ($pidf,0);
               alarm 0;
               1
        } or do {
	       system ('kill -TERM -'.($pidf));
               waitpid ($pidf,0);
               die '2: Error Completing Task Within 15 Minutes ... Exiting';
        };
} if (((time) - ( stat BASE_PATH.MON_PATH.'/DOWNLOAD/'.${task}.'_data_raw.txt' )[9] ) > 90 ); 
# only updates if file is greater than 90 seconds since last modified (swtch bcack to 90)

my @qkey = ( 'Job_Owner', 'queue', 'job_state', 'exec_host', 'Resource_List.nodes', 'resources_used.mem',
	     'resources_used.cput', 'resources_used.walltime', 'qtime', 'ctime' ); my %qkey = map {( $_ => 1 )} @qkey;

open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_raw.txt';
my ($qstt,%qstt); while (<FHI>) {
	if (/^Job Id:\s+(\d+(?:-\d+)?)/) { $qstt = $qstt{$1} = {}; next; }
	my ($qkey,$qval) = (/^\s+([^\s]+)\s+=\s+(.*)$/) or next;
        $qkey{$qkey} or next;
	$$qstt{$qkey} = &{ ${{
		'Job_Owner'	      => sub { ( grep { s/\@.*$//; 1 } (shift))[0] },
		'exec_host'	      => sub { my $i = 0; ( 0+ keys %{{ map { $i++; ( $_ => 1 )}
				               map {( m/^(\w+)\/\d+$/ )} map {( split /\+/ )} (shift) }}).':'.$i },
		'Resource_List.nodes' => sub { (shift) =~ /^(\d+)(?::ppn=(\d+))?/ or return;
				               $1.(!(!(length $2)) && ':'.($1*$2)) },}}{$qkey} or sub { (shift) }} ($qval);
}
close FHI;

my ($line);
$line .= '<!SQUEUE_TIME!>'."\n".($time)."\n";
$line .= '<!SQUEUE!>'."\n";
for ( map {( shift @$_ )} sort { ($$a[1]<=>$$b[1]) || ($$a[2]<=>$$b[2]) } map {[ $_, split /-/ ]} keys %qstt ) {
        $line .= '' . ( join "\t", ( $_, ( map { (defined $_) ? $_ : q(-) } grep { s/\s+/_/g; 1 } @{ $qstt{$_}}{@qkey} )))."\n"; }
$line .= '<!NULL!>'."\n";
open FHO, '>', BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' or die 'Cannot Open File ... Exiting';
print FHO $line;
close FHO;

# 0:Job_ID 1:Owner 2:Queue 3:Status 4:Utilized_Nodes:CPUs 5:Requested_Nodes:CPUs 6:Memory 7:CPU_Time 8:Run_Time 9:Init_Time 10:Queue_Time
# =>
# 0:Job_ID 1:Owner 2:Queue 3:Status 4:CPUs 5:Memory 6:CPU_Time 7:Run_Time 8:Init_Time

my ($data) = Local::Subs::LOAD_DATA($task) || exit;

( my ($dtim) = map { my ($t) = my ($t) = Local::Subs::TAKE_FIVE($_);
                     ($t > Local::Subs::TIME_STAMP(q(SQUEUE_HEPXJOBS_DATA),$t)) ? $t : () }
	       grep { /^\d+$/ } ${ $$data{SQUEUE_TIME}}[0][0] ) or exit;
## only will continue script if rounded timestamp is after last rounded timestamp in ~/mon/TIMESTAMP/data.txt
## can manually change it so that it runs if desired or needed for debugging
 
open FHO, '>'.BASE_PATH.MON_PATH.'/LOGS/SQUEUE_DATA/'.($dtim).'.dat'; select FHO;
print q().( join "\t", @$_ )."\n" for grep {(@$_ == 9)}
            map {[ grep {(defined)}
              $$_[0] =~ /^(\d+(?:-\d+)?)$/ ? q().$1 : (),
              (length $$_[1]) ? $$_[1] : (),
              $$_[2],
              $$_[3] = ${{ 'PD' => 0, 'R' => 1, 'C' => 2, 'E' => 3, 'S' => 4, 'H' => 5, 'W' => 6, 'T' => 7 }}{$$_[3]},
              $$_[4] =~ /^\d+:(\d+)$/ ? 0+$1 : ($$_[3]==0) ?
              $$_[5] =~ /^\d+:(\d+)$/ && 0+$1 : (),
              Local::Subs::DEFAULT( Local::Subs::DATA_FORMAT_HUMAN_BYTES($$_[6]),(($$_[3]!=0) && undef)),
              Local::Subs::DEFAULT( Local::Subs::TIME_FORMAT_HOURS_SECONDS($$_[7]),(($$_[3]!=0) && undef)),
              Local::Subs::DEFAULT( Local::Subs::TIME_FORMAT_HOURS_SECONDS($$_[8]),(($$_[3]!=0) && undef)),
              ( map { @$_ && defined( $$_[4] = ${{Jan=>0,Feb=>1,Mar=>2,Apr=>3,May=>4,Jun=>5,Jul=>6,Aug=>7,Sep=>8,Oct=>9,Nov=>10,Dec=>11}}{$$_[4]} ) ?
              	Time::Local::timelocal(@$_) : () } [((!(defined $$_[9]) &&
                      ($$_[3] == 0) ? $$_[10] : $$_[9]) =~ m/^[A-Z]+_([A-Z]+)_(\d+)_(\d{2}):(\d{2}):(\d{2})_(\d{4})$/i )[4,3,2,1,0,5]] ),
 	    ]} @{ $$data{SQUEUE}};
close FHO;

my (%stll);
open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/'.($task).'_data.ssi';
print FHO Local::Subs::SQUEUE_TABLE(0,$dtim,\%stll,\%idex,\@nams,\@xmpt);
close FHO;

Local::Subs::ALERT( q(TORQUE_STALL),@$_) for map { (0+@$_) ? (@$_ == 1) ? [2,1,$$_[0]] : [4,1,q(MULTIPLE)] : [0] } [ keys %stll ];

1
