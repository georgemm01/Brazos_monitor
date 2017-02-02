#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF(0,6,5);

my ($clst) = map { (length) ? $_ : q(Local) } ${ Local::Subs::CONFIG_LOCAL('SITE') || {}}{'CLUSTER'};

my (%modl) = map { my ($modl) = $_; map {( (uc) => scalar {
	map { m/^([a-z]+)\s*:\s*([\S\s\.-]+)$/i ? ((uc $1),qq($2)) : () } ( split /\s*,\s*/, $$modl{$_} )
	} )} (keys %$modl) } ( Local::Subs::CONFIG_MODULES('LOAD_DATA') || {} );

my ($cmmd) = join '', map { q( ').$_.q(') } map {(( $modl{$$_[0]}{ACTIVE} =~ m/^(?:1|true)$/i ) ?
	(( grep {(length)} ( split /\s+/, $modl{$$_[0]}{MATCH} ), q(1))[0],
	((( split /\s+/, $modl{$$_[0]}{SSH} ), undef )[0] =~ /^(.*?):?(\d*)$/ ),
	( do { my ($cmmd) = $$_[1]; ( grep { /(?:^|\/)${cmmd}$/ } ( split /\s+/, $modl{$$_[0]}{COMMAND} )[0] )}, undef )[0])
	: (undef,undef,undef,undef))}
	( [q(CLUSTER),q(qnodes)], [q(HEAD_1),q(top)], [q(HEAD_2),q(top)], [q(PROCESS_1),q(ps)], [q(PROCESS_2),q(ps)] );

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($spl) = m/\bspool\b/i;

my ($task) = q(load); do { my ($pidf) = grep {(defined)} fork() or die '2: Error Forking Process ... Exiting';
	do { setpgrp(0,0); exec ( BASE_PATH.CGI_PATH.'/_Shell/'.($task).'.sh'.($cmmd).' > ' .
		BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_tmp.txt'); exit 0 } if ($pidf == 0);
	eval { local $SIG{ALRM} = sub { die }; alarm 60; waitpid ($pidf,0); alarm 0; 1 } or do {
		system ('kill -TERM -'.($pidf)); waitpid ($pidf,0); die '2: Error Completing Task Within 60 Seconds ... Exiting'; };
	system ( 'cp '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data_tmp.txt ' .
		BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' ); }
if (((time) - ( stat BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' )[9] ) > 90 );

print +(( open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' ) ? (( join '', <FHI> ), ( close FHI ))[0] : undef ) if ($spl);

my ($data) = Local::Subs::LOAD_DATA($task) || exit;

( my ($dtim) = map { my ($t) = my ($t) = Local::Subs::TAKE_FIVE($_); ($t > Local::Subs::TIME_STAMP(q(LOAD_DATA),$t)) ? $t : () }
	grep { /^\d+$/ } ${ $$data{LOAD_TIME}}[0][0] ) or exit;

my (@nlod) = map { ( map { (defined) ? ( Local::Subs::COMMA( Local::Subs::DEFAULT(
	Local::Subs::ROUND(100*$_,1,1),q(0.0)))).q( &#37;) : q(-) } ( Local::Subs::SAFE_RATIO($$_[0],$$_[1],1)))[0].q( of ).((length $$_[2]) ? $$_[2] : q(-)) }
	map {	[$$_[0][0],$$_[0][1],Local::Subs::COMMA($$_[0][1])], [$$_[0][2],$$_[0][3],Local::Subs::COMMA($$_[0][3])], [$$_[0][4],$$_[0][5],Local::Subs::COMMA($$_[0][5])],
		[$$_[0][6],$$_[0][7],Local::Subs::DATA_FORMAT_BYTES_HUMAN(1024*$$_[0][7],1)], [$$_[0][8],$$_[0][9],Local::Subs::DATA_FORMAT_BYTES_HUMAN(1024*$$_[0][9],1)] }
	grep {(defined)} $$data{LOAD_CLUSTER};

my (@hlod) = map {[
	((length $$_[1]) ? $$_[1].q( ) : q()).q(Head Node Usage Load Statistics),
	[ q(Running Processes), q(User &amp; System CPU Use), q(Net Load Average), q(Physical Memory Use), q(Virtual Memory Use) ],
	[	( Local::Subs::DEFAULT( Local::Subs::COMMA($$_[0][0][0]), q(-))).' of '.( Local::Subs::DEFAULT( Local::Subs::COMMA($$_[0][0][1]), q(-))),
		( Local::Subs::DEFAULT( Local::Subs::COMMA( Local::Subs::ROUND($$_[0][0][2],1,1)), q(-))).q( &#37;) .
			' &nbsp; &amp; &nbsp; '.( Local::Subs::DEFAULT( Local::Subs::COMMA( Local::Subs::ROUND($$_[0][0][3],1,1)), q(-))).q( &#37;),
		( Local::Subs::DEFAULT( Local::Subs::COMMA( Local::Subs::ROUND(100*$$_[0][0][4],1,1)), q(-))).' &#37; ( ' .
			( Local::Subs::DEFAULT( Local::Subs::COMMA($$_[0][0][5]), q(-))).' Users )',
		( map { ( map { (defined) ? ( Local::Subs::COMMA( Local::Subs::DEFAULT(
			Local::Subs::ROUND(100*$_,1,1),q(0.0)))).q( &#37;) : q(-) } ( Local::Subs::SAFE_RATIO($$_[0],$$_[1],1)))[0].q( of ).((length $$_[2]) ? $$_[2] : q(-)) }
			[$$_[0][0][6],$$_[0][0][7],Local::Subs::DATA_FORMAT_BYTES_HUMAN(1024*$$_[0][0][7],1)],
			[$$_[0][0][8],$$_[0][0][9],Local::Subs::DATA_FORMAT_BYTES_HUMAN(1024*$$_[0][0][9],1)] ) ],
	]} grep {(defined $$_[0])} map {[ $$data{'LOAD_HEAD_'.$_}, @{ $modl{'HEAD_'.$_} || {}}{( qw( NODE ))} ]} (1,2);

my (@plod) = map {[
	((defined $$_[1]) ? $$_[1].q( ) : q()).q(Processes).((length $$_[2]) ? q( on ).$$_[2] : q()),
	[ q(Running Processes), q(Average CPU Use), q(Average Hours Elapsed), q(Average Memory Use), q(Average Virtual Size) ],
	[	( Local::Subs::DEFAULT( Local::Subs::COMMA($$_[0][0][0]), q(-))).' of '.( Local::Subs::DEFAULT( Local::Subs::COMMA($$_[0][0][1]), q(-))),
		( Local::Subs::DEFAULT( Local::Subs::COMMA( Local::Subs::ROUND($$_[0][0][2],1,1)), q(-))).q( &#37;),
		((defined $$_[0][0][3]) ? Local::Subs::TIME_FORMAT_SECONDS_HOURS((int $$_[0][0][3]+0.5),1) : q(-)),
		( Local::Subs::DEFAULT( Local::Subs::COMMA( Local::Subs::ROUND($$_[0][0][4],1,1)), q(-))).q( &#37;),
		((defined $$_[0][0][6]) ? Local::Subs::DATA_FORMAT_BYTES_HUMAN((int 1024*$$_[0][0][6]+0.5),1) : q(-)) ],
	]} grep {(defined $$_[0])} map {[ $$data{'LOAD_PROCESS_'.$_}, @{ $modl{'PROCESS_'.$_} || {}}{( qw( NAME NODE ))} ]} (1,2);

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/load_data.ssi'; select FHO;
print '<DIV id="cluster_load_anchor" style="z-index:0; display:block; position:static; height:auto; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="height:auto; width:826px;">'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px;">'.($clst).' Cluster Usage Load Statistics ( '.( Local::Subs::DATE_FORMAT($dtim,0,q(%Y-%m-%d %R CST))).' )</td>'."\n";
print "\t\t".'</tr>'."\n";
if (@nlod) {
	print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Occupied Nodes</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Occupied Processors</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Load Average per CPU</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Physical Memory Use</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">Virtual Memory Use</td>'."\n";
	print "\t\t".'</tr>'."\n";
	print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#E9FBFA;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($nlod[$_]).'</td>'."\n" for (0..4);
	print "\t\t".'</tr>'."\n"; }
for (@hlod,@plod) { my ($titl,$head,$body) = @$_;
	print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
	print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px;">'.($titl).'</td>'."\n";
	print "\t\t".'</tr>'."\n";
	print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($$head[$_]).'</td>'."\n" for (0..4);
	print "\t\t".'</tr>'."\n";
	print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#E9FBFA;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:154px; height:16px;">'.($$body[$_]).'</td>'."\n" for (0..4);
	print "\t\t".'</tr>'."\n"; }
print "\t".'</table>'."\n";
print '</DIV>'."\n";
close FHO;

1

