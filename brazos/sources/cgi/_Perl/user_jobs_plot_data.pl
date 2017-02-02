#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

use LWP::UserAgent ();

use HTTP::Request::Common ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($url) = m/\burl\b/i; my (@unit) = ( !(! m/\bhour\b/i), !(! m/\bday\b/i), !(! m/\bweek\b/i), !(! m/\ball\b/i));

my ($brsr) = LWP::UserAgent->new();

my ($time) = time;

my ($site) = grep { (length) or die 'Cannot Establish Local CMS Site Descriptor' } ${ Local::Subs::CONFIG_LOCAL('CMS') || {}}{'SITE'};

print Local::Subs::DATE_FORMAT(($time),1,q(%Y-%m-%d%%20%H%%3A%M%%3A%S))."\n";

for (	$unit[0] || (!($unit[1]) && !($unit[2])) || $unit[3] ? [3600,'hour',180] : (),
	$unit[1] || (!($unit[0]) && !($unit[2])) || $unit[3] ? [86400,'day',180] : (),
	$unit[2] || $unit[3] ? [604800,'week',720] : ()) {
	my ($span,$unit,$tmot) = @$_; $brsr-> timeout($tmot); for my $mode (0,1) { &{(
		sub { do { open FHO, '>'.BASE_PATH.MON_PATH.'/TABLES/user_jobs_data_'.($unit).'.txt'; select FHO;
			print ''.( join "\t", @$_ )."\n" for @$_; close FHO; return 0+@$_ } for [
			map {[ (( map {( 0+( defined $$_[1]), $$_[0], Local::Subs::DEFAULT($$_[1],$$_[2]) )} map {[ Local::Subs::DEFAULT($$_[0],q()),
				(( defined $$_[0]) && ( defined $$_[1]) ? Local::Subs::DEFAULT((
					(( $$_[1] eq q(unknown)) || ( $$_[1] eq q(NotAvailable)) || ( $$_[1] =~ /\.\.$/ )) ?
					undef : Local::Subs::LOCAL_USER_NAME($$_[1],1))[0], Local::Subs::LOCAL_USER_NAME($$_[0],1)) : undef ),
				( join q( ), map { (/^[A-Z]$/) ? $_.q(.) : $_ } split /(?<=\w)(?:\.)?(?=[A-Z])/, Local::Subs::DEFAULT($$_[0],q(-))),
				]} [ $$_[0] =~ /^([\w.]+)\/([\w.]+)$/ ]), @$_[2..7,10..12], Local::Subs::ROUND($$_[19],0), $$_[20]) ]}
			grep {(@$_==21)} map {[ grep { s/&[\w#]*;//sg; s/<[^>]*>//sg; s/\s+//sg; 1 } m/<td[^>]*>(.*?)<\/td>/sg ]}
			map { m/<tr[^>]*>(.*?)<\/tr>/sg } map { m/<tbody>(.*)<\/tbody>/s } ( grep { (defined) || (return $url) } (shift))] },
		sub { my ($inam) = 'user_jobs_'.($unit); if ((( grep { (defined) || (return $url) } (shift))[0]) =~ m/\/(\d+\.\d+\.png)"/s ) { my ($rpt,$slp) = (3,2);
			while (!(( $brsr-> request( HTTP::Request::Common::GET( 'http://dashb-cms-job-dev.cern.ch/dashboard/tmp/'.($1)),
				BASE_PATH.HTML_PATH.'/IMAGES/PLOTS/'.($inam).'.png' ))-> is_success()) && (($rpt--) > 0)) {( sleep $slp )};
				Local::Subs::SIZE_IMAGE($inam,810,undef); } else { unlink ( BASE_PATH.HTML_PATH.'/IMAGES/PLOTS/'.($inam).'.png' ); }},
		)[$mode] } ( map { $url ?  do { print STDOUT $_."\n"; undef } :
			( map {( $_-> content())} grep {( $_-> is_success())} $brsr-> request(
			HTTP::Request::Common::GET( $_ , Accept => ( q(application/)).(( q(xhtml+xml), q(image-map))[$mode])))) }
				'http://dashb-cms-job-dev.cern.ch/dashboard/request.py/jobsummary-plot-or-table' .
				'?site='.($site).'&check=terminated&sortby=user&scale=linear' .
				'&date1='.( Local::Subs::DATE_FORMAT(($time-$span),1,q(%Y-%m-%d%%20%H%%3A%M%%3A%S))) .
				'&date2='.( Local::Subs::DATE_FORMAT($time,1,q(%Y-%m-%d%%20%H%%3A%M%%3A%S)))) or last; }}

exit if $url; open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/user_jobs_plot_data.ssi'; select FHO;

print "\t".'<DIV id="user_jobs_plot_data_anchor" style="z-index:0; display:block; position:static; height:auto; ' .
	'width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="height:auto; width:826px;">'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px; color:black; background-color:#FFFFFF;">' .
	'CMS Recent Job Activity on the Local Cluster by User ( '.( Local::Subs::DATE_FORMAT($time,1,q(%Y-%m-%d %R UTC))).' )</td>'."\n"; print "\t\t".'</tr>'."\n";
for my $mode (0..2) { my ($unit) = ( qw( hour day week ))[$mode]; my (@jobs) = (
	open FHI, BASE_PATH.MON_PATH.'/TABLES/user_jobs_data_'.($unit).'.txt' ) ? do { my ($totl,%jobs) = [ q(), q(Totals)];
		do { my ($jobt) = $_; shift @$jobt; @{ $jobs{$$jobt[0]}||=[]}[0,1] = @$jobt[0,1]; do {
			$jobs{$$jobt[0]}[$_] += $$jobt[$_]; $$totl[$_] += $$jobt[$_]; } for (2..12) } for
			sort { $$a[0] <=> $$b[0] } map { chomp; [ split /\t/ ] } <FHI>; close FHI;
			(( map { $$_[1] } sort { $$a[0] cmp $$b[0] } map {[( Local::Subs::LAST_NAME_FIRST($$_[1]))[0],$_]} values %jobs ),$totl) } : ();
	print "\t\t".'<tr class="mon_default" id="user_jobs_plot_data_element_'.($mode).'" style="display:' .
		(( qw( none block none ))[$mode]).'; color:black; background-color:#FFFFFF; overflow:hidden;">'."\n";
	if (@jobs) { my ($ihgt) = map { (${$_ || []}[0] == 810) && $$_[1] } Local::Subs::IMAGE_SIZE( BASE_PATH.HTML_PATH.'/'.(
		my $inam = 'IMAGES/PLOTS/user_jobs_'.($unit).'.png' )); my ($thgt) = ( $ihgt && ($ihgt + 10)) + 26*(1+@jobs);
		print "\t\t\t".'<td colspan="5" class="mon_default" style="width:820px; height:'.($thgt).'px; padding:0px; border-width:0px;">'."\n";
		print "\t\t\t\t".'<table class="mon_default" style="width:820px; height:'.($thgt).'px; border-width:0px;">'."\n";
		print "\t\t\t\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n" .
			"\t\t\t\t\t\t".'<td colspan="8" class="mon_default" style="width:810px; height:'.($ihgt) .
			'px;"><img class="mon_default" src="'.($inam).'?'.($time).'" alt="Job Activity Per User (Last '.( ucfirst $unit ) .
			')" title="Job Activity Per User (Last '.( ucfirst $unit ).')" width="810" height="'.($ihgt).'"></td>'."\n" .
			"\t\t\t\t\t".'</tr>'."\n" if ($ihgt);
		print "\t\t\t\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:166px; height:16px;">User Name</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Pending</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Running</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Terminated</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">App Failed</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Grid Failed</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">CPU Usage</td>'."\n";
		print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Run Hours</td>'."\n";
		print "\t\t\t\t\t".'</tr>'."\n";
		my ($i) = 0; for my $jobt (@jobs) { my (@jobd) = ( $$jobt[1], ( map { Local::Subs::COMMA($_) } @$jobt[2..4] ));
			$jobd[4] = ( $$jobt[4] ? ( Local::Subs::ROUND(100*($$jobt[9]+$$jobt[10])/$$jobt[4],1,1)) : q(0.0)).q( &#37;);
			$jobd[5] = ( $$jobt[4] ? ( Local::Subs::ROUND(100*($$jobt[6]+$$jobt[7])/$$jobt[4],1,1)) : q(0.0)).q( &#37;);
			$jobd[6] = ( $$jobt[12] ? ( Local::Subs::ROUND(100*$$jobt[11]/$$jobt[12],1,1)) : q(100.0)).q( &#37;);
			$jobd[7] = Local::Subs::TIME_FORMAT_SECONDS_HOURS($$jobt[12],1);
			my @usergridname= $$jobt[0] =~ /([A-Z][a-z]*)/g;
			print "\t\t\t\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#' .
				(($i==$#jobs) ? q(20B2AA) : ( qw( E9FBFA B3F3F0 ))[$i%2]).';'.(!( length $$jobt[0]) ?
				'">' : ' cursor:pointer;" onClick="javascript:window.open(' .
				'\'http://dashb-cms-job-task.cern.ch/dashboard/request.py/taskmonitoring#' .
				'action=tasksTable&amp;usergridname='.(join(' ', @usergridname)).'&amp;timerange=last' .
				(( qw( Day Day Week ))[$mode]).'\',\'NEW\');" ' .
				'onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" '.
				'onMouseOut="javascript:this.style.backgroundColor=\'#'.(( qw( E9FBFA B3F3F0 ))[$i%2]).'\';">' )."\n";
			print "\t\t\t\t\t\t".'<td class="mon_default" style="width:166px; height:16px; ' .
				'color:inherit; background-color:transparent">'.($jobd[0]).'</td>'."\n";
			print "\t\t\t\t\t\t".'<td class="mon_default" style="width:82px; height:16px; ' .
				'color:inherit; background-color:transparent">'.($_).'</td>'."\n" for @jobd[1..7];
			print "\t\t\t\t\t".'</tr>'."\n"; } continue { $i++; }
		print "\t\t\t\t".'</table>'."\n"; print "\t\t\t".'</td>'."\n"; }
	else { print "\t\t\t".'<td colspan="5" class="mon_default" style="width:810px; height:16px; color:black; background-color:#20B2AA;">' .
		'No User Job Activity for the Last '.( ucfirst $unit ).'</td>'."\n"; } print "\t\t".'</tr>'."\n"; }
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td class="mon_default" style="width:442px; height:16px; color:black; background-color:#FFFFFF;">' .
	'&uarr; Click User Row for Job Details</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Select &rarr;</td>'."\n";
print "\t\t\t".'<td class="mon_default" id="user_jobs_plot_data_select_hour" ' .
	'style="width:82px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" ' .
	'onClick="javascript:UserJobsPlotDataSelect(0);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" ' .
	'onMouseOut="javascript:if(UserJobsPlotDataIndex!=0)this.style.backgroundColor=\'#FFFFFF\';">Hour</td>'."\n";
print "\t\t\t".'<td class="mon_default" id="user_jobs_plot_data_select_day" ' .
	'style="width:82px; height:16px; color:black; background-color:#3BB9FF; cursor:pointer;" ' .
	'onClick="javascript:UserJobsPlotDataSelect(1);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" ' .
	'onMouseOut="javascript:if(UserJobsPlotDataIndex!=1)this.style.backgroundColor=\'#FFFFFF\';">Day</td>'."\n";
print "\t\t\t".'<td class="mon_default" id="user_jobs_plot_data_select_week" ' .
	'style="width:82px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" ' .
	'onClick="javascript:UserJobsPlotDataSelect(2);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" ' .
	'onMouseOut="javascript:if(UserJobsPlotDataIndex!=2)this.style.backgroundColor=\'#FFFFFF\';">Week</td>'."\n";
print "\t\t".'</tr>'."\n"; print "\t".'</table>'."\n"; print '</DIV>'."\n\n";

close FHO;

1

#~~~~~~~~~~~~~~
#http://dashb-cms-job.cern.ch/dashboard/request.py/jobsummary#user=&site=${site}&ce=&submissiontool=&dataset=&application=&rb=&activity=&grid=&date1=2011-10-25%2015%3A21%3A00&date2=2011-10-26%2015%3A21%3A00&sortby=user&nbars=&scale=linear&jobtype=&tier=&check=terminated
#~~~~~~~~~~~~~~

