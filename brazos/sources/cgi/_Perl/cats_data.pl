#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

use Time::Local ();

use LWP::UserAgent ();

use HTTP::Request::Common ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i;

my ($brsr) = LWP::UserAgent->new();

my ($time) = time; my ($stmp) = '( '.( Local::Subs::DATE_FORMAT($time,1,q(%Y-%m-%d %R UTC))).' )';

my ($clst) = map { (length) ? $_ : q(Local) } ${ Local::Subs::CONFIG_LOCAL('SITE') || {}}{'CLUSTER'};

my (@cats); ( my (@gnam) = grep {(length)} ( split /[\s,]+/, ${ Local::Subs::CONFIG_MODULES('CATS_DATA') || {}}{'USERS'} ))
        or die 'Cannot Establish User List for Module CATS_DATA';

for my $gidx (0..$#gnam) { do { $cats[$$_[0][0]][$$_[0][1]][$$_[0][2]][$gidx] ||= do { ( grep {
	(@{ $$_[2]} == 6) && do { $$_[2][1]--; $$_[2] = Time::Local::timegm( reverse @{ $$_[2]}); 1 }}
	[ @$_[1,2], [ map { /TaskCreatedTimeStamp:\s+(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/ }
	grep { s/&[\w#]*;//g; s/<[^>]*>//sg; 1 } map {( $_->content())} grep {( $_->is_success())}
	$brsr->request( HTTP::Request::Common::GET( 'http://dashb-cms-job-task.cern.ch/dashboard/request.py/taskinfo?' .
	'usergridname='.(join(' ',$gnam[$gidx]=~ /([A-Z][a-z]*)/g)).'&taskmonid='.($$_[1]))) ]] )[0] }} for reverse map {
		$$_[0] =~ /^[a-zA-Z0-9\:\.\_]*(?:(SLURM|CondorG|CRAB3))_(?:(?:Small|(Large))_)?Output_(?:${clst}|(FNAL))_[a-z\d]+$/ ?
		[[ 0+${{ SLURM => 0, CondorG => 1, CRAB3 => 2 }}{$1}, 0+(defined $3), 0+(defined $2) ], @$_ ] : () }
	map { ($$_[1] > 0) && ($$_[1] == Local::Subs::SUM(@$_[4..6])) ? [ $$_[0], [ map {(int)} @$_[4..6]]] : () }
	map {[ ( grep { s/&[\w#]*;//g; s/<[^>]*>//g; 1 } m/<td[^>]*>(.*?)<\/td>/g )[0..6]]}
	map { m/<tr[^>]*>(.*?)<\/tr>/g } grep { s/<div[^>]*><table[^>]*>.*?<\/table><\/div>//sg; 1 }
	map {( $_->content())} grep {( $_->is_success())} $brsr->request( HTTP::Request::Common::GET(
		'http://dashb-cms-job-task.cern.ch/dashboard/request.py/taskstable?' .
		'typeofrequest=A&timerange=lastWeek&usergridname='.(join(' ',$gnam[$gidx]=~ /([A-Z][a-z]*)/g)))); }

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/cats_data.ssi'; select FHO;

print <<EndHTML;

<DIV id="cats_data_anchor" style="z-index:0; display:block; position:static; height:248px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
	<table class="mon_default" style="height:248px; width:826px;">
		<tr class="mon_default" style="color:black; background-color:#FFFFFF;">
			<td class="mon_default" style="width:106px; height:16px;">&darr; Grid Client</td>
			<td colspan="4" class="mon_default" style="width:694px; height:16px;">CRAB Analysis Test Suite (CATS) Completed Job Status ${stmp}</td>
		</tr>
		<tr class="mon_default" style="color:black; background-color:#FFFFFF;">
			<td class="mon_default" style="width:106px; height:16px;">Output Host &rarr;</td>
			<td colspan="2" class="mon_default" style="width:336px; height:16px; color:black; background-color:#20B2AA;">Local: ${clst} Cluster</td>
			<td colspan="2" class="mon_default" style="width:336px; height:16px; color:black; background-color:#20B2AA;">Remote: Fermi National Laboratory</td>
		</tr>
		<tr class="mon_default" style="color:black; background-color:#FFFFFF;">
			<td class="mon_default" style="width:106px; height:16px;">Output Size &rarr;</td>
			<td class="mon_default" style="width:166px; height:16px; color:black; background-color:#20B2AA;">Small</td>
			<td class="mon_default" style="width:166px; height:16px; color:black; background-color:#20B2AA;">Large</td>
			<td class="mon_default" style="width:166px; height:16px; color:black; background-color:#20B2AA;">Small</td>
			<td class="mon_default" style="width:166px; height:16px; color:black; background-color:#20B2AA;">Large</td>
		</tr>
EndHTML

my (@wide) = (undef,undef,1); my (@grey) = (undef,undef,[undef,[1]]); my ($tsts); # grey defines if it will write it in the table or not

my (@rslt); for my $clnt (0..2) {
#my (@rslt); for my $clnt (0..1) {
	print "\t\t".'<tr class="mon_default" style="color:black; background-color:#FFFFFF;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:106px; height:36px; color:black; background-color:#20B2AA;">' .
		(( qw( SLURM CondorG CRAB3 ))[$clnt]).'</td>'."\n";
	for my $host (0,1) { for my $size (0,1) { my ($wide,$grey) = ($wide[$clnt],$grey[$clnt][$host][$size]);
		my ($cats) = $grey ? undef : ( sort {($$b[2]<=>$$a[2])} grep {(defined)} @{ $cats[$clnt][$host][$size]||[]} )[0];
		my ($link) = $cats && 'http://dashb-cms-job-task.cern.ch/dashboard/request.py/taskmonitoring#' .
			'action=taskJobs&amp;usergridname=undefined&amp;taskmonid='.($$cats[0]).'&amp;what=all';
		my (@pfoc) = $cats && @{ $$cats[1]}; my ($date) = $cats && Local::Subs::DATE_FORMAT($$cats[2],1,q(%Y-%m-%d %R UTC));
		my ($bclr) = map { $rslt[$_]++; ( q(#FFFFFF), qw( red orange green ), q(#CCCCCC))[$_] }
			( $cats ? $pfoc[1] ? 1 : $pfoc[2] ? 2 : 3 : $grey ? 4 : 0 ); $tsts++ unless $grey;
		print "\t\t\t".'<td'.( $wide ? q( colspan="2") : q()).' class="mon_default" style="width:'.(( qw( 166 342 ))[0+!(!$wide)]) .
			'px; height:36px; color:black;  background-color:'.($bclr).';'.( $cats && ' cursor:pointer;' ).'"' .
			( $cats && ' onClick="javascript:window.open(\''.($link).'\',\'NEW\');"' ) .
			( $cats && ' onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';"' ) .
			( $cats && ' onMouseOut="javascript:this.style.backgroundColor=\''.($bclr).'\';"' ).'>' .
			( $cats ? 'Pass:'.( Local::Subs::COMMA($pfoc[0])).' &nbsp; Fail:'.( Local::Subs::COMMA($pfoc[1])).' &nbsp; Other:'.( Local::Subs::COMMA($pfoc[2])) .
				'<br>'.($date) : $grey ? q() : q(No Test Results<br>Found for Prior Week)).'</td>'."\n"; last if $wide; }}
	print "\t\t".'</tr>'."\n"; } print "\t\t".'<tr class="mon_default" style="color:black; background-color:#FFFFFF;">'."\n";
	print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px;">&uarr; Test Results Link to Job Details &uarr;</td>'."\n";
	print "\t\t".'</tr>'."\n"; print "\t".'</table>'."\n"; print '</DIV>'."\n"; close FHO;

Local::Subs::ALERT( q(CATS_FAIL),(($rslt[1]) ? (2,1,( Local::Subs::ROUND(100*(($rslt[2]/2+$rslt[3])/($tsts||1)),0))) : (0)));

Local::Subs::ALERT( q(CATS_SKIP),(($rslt[0]) ? (2,!($rslt[1])) : (0)));

1
