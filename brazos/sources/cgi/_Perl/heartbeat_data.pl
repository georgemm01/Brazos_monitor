#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF(0,6,5);

my ($clst) = map { (length) ? $_ : q(Local) } ${ Local::Subs::CONFIG_LOCAL('SITE') || {}}{'CLUSTER'};

my ($sshh) = join '', map { q( ').($_).q(') } map { @$_ } grep {(length $$_[0]) || die 'Invalid SSH Domain' } map {[ /^(.*?):?(\d*)$/ ]}
	(( split /\s+/, ${ Local::Subs::CONFIG_MODULES('HEARTBEAT_DATA') || {}}{'SSH'} ), undef )[0];
my ($ddir) = map { q( ').($_).q(') } grep {(length) || die 'Invalid Data Directory' } grep { s/\/+$//; 1 }
	(( split /\s+/, ${ Local::Subs::CONFIG_MODULES('HEARTBEAT_DATA') || {}}{'DATA_DIR'} ), undef )[0];
my ($sdir) = map { q( ').($_).q(') } grep {(length) || die 'Invalid Small Test Directory' } grep { s/\/+$//; 1 }
	(( split /\s+/, ${ Local::Subs::CONFIG_MODULES('HEARTBEAT_DATA') || {}}{'SMALL_DIR'} ), undef )[0];

my ($dftt) = ${ Local::Subs::CONFIG_MODULES('HEARTBEAT_DATA') || {}}{'PARTITION'};
my ($dffp) = ${ Local::Subs::CONFIG_MODULES('HEARTBEAT_DATA') || {}}{'PARTITION_PERCENT'};
my ($dffs) = ${ Local::Subs::CONFIG_MODULES('HEARTBEAT_DATA') || {}}{'PARTITION_TIB'};

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($spl) = m/\bspool\b/i;

my ($task) = q(heartbeat); do { my ($pidf) = grep {(defined)} fork() or die '2: Error Forking Process ... Exiting';
	do { setpgrp(0,0); exec ( BASE_PATH.CGI_PATH.'/_Shell/'.($task).'.sh'.($sshh.$ddir.$sdir).' > ' .
		BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_tmp.txt'); exit 0 } if ($pidf == 0);
	eval { local $SIG{ALRM} = sub { die }; alarm 60; waitpid ($pidf,0); alarm 0; 1 } or do {
		system ('kill -TERM -'.($pidf)); waitpid ($pidf,0); die '2: Error Completing Task Within 60 Seconds ... Exiting'; };
	system ( 'cp '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_tmp.txt ' .
		BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' ); }
if (((time) - ( stat BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' )[9] ) > 90 );

print +(( open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' ) ? (( join '', <FHI> ), ( close FHI ))[0] : undef ) if ($spl);

my ($data) = Local::Subs::LOAD_DATA($task) || exit;

( my ($dtim) = map { my ($t) = my ($t) = Local::Subs::TAKE_FIVE($_); ($t > Local::Subs::TIME_STAMP(q(HEARTBEAT_DATA),$t)) ? $t : () }
	grep { /^\d+$/ } ${ $$data{HEARTBEAT_TIME}}[0][0] ) or exit;

my (@alrt,@htxt);
(${ $$data{HEARTBEAT_SSH}}[0][0] eq q(1)) && ($htxt[0] = [2,q(Pass)]) or push @alrt, q(Cannot SSH to ).($sshh);
(${ $$data{HEARTBEAT_MOUNT}}[0][0] eq q(1)) && ($htxt[1] = [2,q(Pass)]) or push @alrt, q(Cannot Detect ).($ddir).q( Filesystem Mount);
do { push @alrt, map { @$_ or $htxt[2][0] = 2; @$_; } [( ((shift @$_) ?  q(Failure Invoking "DF" as: ) .
	( ${ $$data{HEARTBEAT_DF_QUERY}}[0][0]) : ()), do { @$_ and $htxt[2][0] = 1; @$_ } )] } for
		[ map { ($$_[2] > 0) ? do { $htxt[2][1] = $$_[1].q( of ).$$_[3]; ($$_[3] eq $dftt) ?
			((((1 - ($$_[0]/$$_[2])) < $dffp) || (($$_[2] - $$_[0])/(1024)**3 < $dffs)) ? () : (1, q([TAB]Disk Usage ).$htxt[2][1].q( Exceeds Bounds ))) :
			(1, q([TAB]Disk Partition of ).($$_[3]).q( Differs From Expected ).((length $dftt) ? $dftt : q(-))) } : (1) }
			[ map {( $$_[0], ((length $$_[0]) ? q().( Local::Subs::DATA_FORMAT_BYTES_HUMAN(1024*$$_[0],1)) : q(-)))} @{ $$data{HEARTBEAT_DF}}[0,1] ]];
do { push @alrt, q(Failure Invoking "DU" as: ).( ${ $$data{HEARTBEAT_DU_QUERY}}[0][0]) if
	((${ $$data{HEARTBEAT_DU}}[0][0] ne '1') or 0+@$_); push @alrt, map { q([TAB]).$_ } @$_; } for [
#	( map { !(length) ? do { q(Could Not Establish "DU" Page Fault Status) } : ($_ > 0) ?
#		do { $htxt[3] = [1,($_).q( Page Fault).(($_>1) && q(s))]; q(Experienced ).(($_>1)?($_) .
#			q( Major Page Faults):q(A Major Page Fault)).q( During "DU" Query) } :
#		do { $htxt[3] = [2,q(Pass)]; () }} ${ $$data{HEARTBEAT_DU_TIME}}[0][3]),
#	( map { !(length) ? do { undef $htxt[3]; q(Could Not Establish "DU" I/O Error Status) } : ($_ > 0) ?
#		do { $htxt[3] = [1,($_).q( I/O Error).(($_>1) && q(s))] if (defined $htxt[3]); q(Experienced ).(($_>1)?($_) .
#			q( Input/Output Errors):q(An Input/Output Error)).q( During "DU" Query) } :
#		do { () }} ${ $$data{HEARTBEAT_DU_ERRORS}}[0][0]),

	( map { !(length) ? do { q(Could Not Establish "DU" I/O Error Status) } : ($_ > 0) ?
		do { $htxt[3] = [1,($_).q( I/O Error).(($_>1) && q(s))]; q(Experienced ).(($_>1)?($_) .
			q( Input/Output Errors):q(An Input/Output Error)).q( During "DU" Query) } :
		do { $htxt[3] = [2,q(Pass)]; () }} ${ $$data{HEARTBEAT_DU_ERRORS}}[0][0]),
	( map { !(defined) ? q(Could Not Establish "DU" Run Time) : do { $htxt[4][1] = ($_).q( Seconds);
		($_ > 59) ? do { $htxt[4][0] = 1; q(Excessive "DU" Run Time of ).($_).q( Seconds - Much Less Than 1 Expected, alert shows at more than 59s ) } :
		do { $htxt[4][0] = 2; () }}} Local::Subs::TIME_FORMAT_MINUTES_SECONDS( ${ $$data{HEARTBEAT_DU_TIME}}[0][1]))
];
Local::Subs::ALERT( q(GRAB_HEART),((0+@alrt) ? (2,1,( join q([BR][TAB]*), (q(),@alrt))) : (0)));

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/heartbeat_data.ssi'; select FHO;
print '<DIV id="heartbeat_anchor" style="z-index:0; display:block; position:static; height:84px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="height:84px; width:826px;">'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px;">'.($clst).' Cluster Heartbeat Tests ( ' .
	( Local::Subs::DATE_FORMAT($dtim,0,q(%Y-%m-%d %R CST))).' )</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">SSH Link</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">FData Filesystem Mount</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">FData Partition Usage</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">"DU" Query Status</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">"DU" Query Timer</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px; color:black; background-color:' .
	(( qw( red orange green ))[ Local::Subs::DEFAULT($htxt[$_][0],0)]).';">'.( Local::Subs::DEFAULT($htxt[$_][1],q(Fail))).'</td>'."\n" for (0..4);
print "\t\t".'</tr>'."\n";
print "\t".'</table>'."\n";
print '</DIV>'."\n";
close FHO;

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/totaldisk_data.ssi'; select FHO;
print '<DIV id="disk_usage_data_anchor" style="z-index:0; display:block; position:static; height:84px; width:350px; margin:0px 238px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="height:84px; width:350px;">'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="1" class="mon_default" style="width:350px; height:16px;"> Total Disk Usage ( ' .
	( Local::Subs::DATE_FORMAT($dtim,0,q(%Y-%m-%d %R CST))).' )</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
print "\t\t\t".'<td colspan="1" class="mon_default" style="width:350px; height:16px;">FData Partition Usage</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="1" class="mon_default" style="width:350px; height:16px; color:black; background-color:' .
	(( qw( red orange green ))[ Local::Subs::DEFAULT($htxt[$_][0],0)]).';">'.( Local::Subs::DEFAULT($htxt[$_][1],q(Fail))).'</td>'."\n" for (2..2);
print "\t\t".'</tr>'."\n";
print "\t".'</table>'."\n";
print '</DIV>'."\n";
close FHO;


1

