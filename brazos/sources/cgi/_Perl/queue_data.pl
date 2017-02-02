#!/usr/bin/perl

# NOTE: this script has been modified to use squeue instead of qstat to probe the queues, be aware! -KC

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF(0,6,5);

my ($clst) = map { (length) ? $_ : q(Local) } ${ Local::Subs::CONFIG_LOCAL('SITE') || {}}{'CLUSTER'};

my ($sshh) = join '', map { q( ').($_).q(') } map { /^(.*?):?(\d*)$/ }
             (( split /\s+/, ${ Local::Subs::CONFIG_MODULES('QUEUE_DATA') || {}}{'SSH'} ), undef )[0];
my ($cmmd) = map { q( ').($_).q(') } map { (length) ? do { /(?:^|\/)squeue$/ &&
                   !(/\s/) or die 'Invalid squeue executable path'; $_ } : q(squeue) }
	           ${ Local::Subs::CONFIG_MODULES('QUEUE_DATA') || {}}{'COMMAND'};
my ($ques) = map { q( ').($_).q(') }
             ( join ',', ( grep { (length) } map { split /[,\s]+/ } ${ Local::Subs::CONFIG_MODULES('QUEUE_DATA') || {}}{'QUEUES'} ));
my ($nick) = map { scalar { map { m/^([a-z]+)\s*:\s*([\w\s\.-]+)$/i ? (qq($1),(uc $2)) : () }
	     ( split /\s*,\s*/, $_ ) }} ${ Local::Subs::CONFIG_MODULES('QUEUE_DATA') || {}}{'NAMES'};
local ($_) = "@ARGV";
my ($log)  = m/\blog\b/i;
my ($spl)  = m/\bspool\b/i;
my ($task) = q(squeue);

do {
     my ($pidf) = grep {(defined)} fork() or die '2: Error Forking Process ... Exiting';
     do {
          setpgrp(0,0);
          exec ( BASE_PATH.CGI_PATH.'/_Shell/'.($task).'.sh '.($sshh.$cmmd.$ques).' > ' .
	 	 BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_tmp.txt');
          exit 0
     } if ($pidf == 0);
     eval {
          local $SIG{ALRM} = sub { die };
          alarm 60;
          waitpid ($pidf,0);
          alarm 0;
          1
     } or do {
          system ('kill -TERM -'.($pidf));
          waitpid ($pidf,0);
          die '2: Error Completing Task Within 60 Seconds ... Exiting';
     };
     system ( 'cp '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_tmp.txt ' .
		    BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' );
} if (((time) - ( stat BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' )[9] ) > 90 );

print +(( open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' ) ? (( join '', <FHI> ), ( close FHI ))[0] : undef ) if ($spl);

my ($data) = Local::Subs::LOAD_DATA($task) || exit;

( my ($dtim) = map { my ($t) = my ($t) = Local::Subs::TAKE_FIVE($_); ($t > Local::Subs::TIME_STAMP(q(QUEUE_DATA),$t)) ? $t : () }
	       grep { /^\d+$/ } ${ $$data{QUEUE_TIME}}[0][0] ) or exit;

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/queue_data.ssi'; select FHO;
print '<DIV id="cluster_queue_anchor" style="z-index:0; display:block; position:static; height:auto; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="height:auto; width:826px;">'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px;">'.($clst).' Cluster Queue Utilization Statistics ( '.( Local::Subs::DATE_FORMAT($dtim,0,q(%Y-%m-%d %R CST))).' )</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Queue</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Accessible Cores</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Active Cores (Running) (hepx/all users)</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Requested Cores (Queued) (hepx/all users)</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Other Core States<br>(Held, Waiting, Exiting) (hepx/all users)</td>'."\n";
print "\t\t".'</tr>'."\n";
my ($i) = 0; for (@{ $$data{QUEUE_UTILIZATION}}) { my (@qlod) = @$_;
	$qlod[0] = Local::Subs::DEFAULT( $$nick{$qlod[0]}, (uc $qlod[0]));  @qlod[1..7] = map { Local::Subs::COMMA($_) } @qlod[1..7];
	print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#'.(( qw( E9FBFA B3F3F0 ))[($i++)%2]).';">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($qlod[$_]).'</td>'."\n" for (0..1);
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($qlod[2]).'/'.($qlod[3]).'</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($qlod[4]).'/'.($qlod[5]).'</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($qlod[6]).'/'.($qlod[7]).'</td>'."\n";
        print "\t\t".'</tr>'."\n"; }
print "\t".'</table>'."\n";
print '</DIV>'."\n";
close FHO;
