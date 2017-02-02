#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

use LWP::UserAgent ();

use HTTP::Request::Common ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV";
my ($log) = m/\blog\b/i;
my ($url) = m/\burl\b/i;
my (@unit) = (	!(! m/\bhour(?:ly)?\b/i),
		!(! m/\b(?:day|daily)\b/i),
		!(! m/\bweek(?:ly)?\b/i),
		!(! m/\ball\b/i));

my ($brsr) = LWP::UserAgent->new();

my ($time) = time;

my ($site) = grep { (length) or die 'Cannot Establish Local CMS Site Descriptor' } ${ Local::Subs::CONFIG_LOCAL('CMS') || {}}{'SITE'};

my ($hrly);
for (	$unit[0] || (!($unit[1]) && !($unit[2])) || $unit[3] ? do { $hrly++; [48,3600,'hourly'] } : (),
	$unit[1] || $unit[3] ? [45,86400,'daily'] : (),
	$unit[2] || $unit[3] ? [52,604800,'weekly'] : ()) { my ($step,$span,$unit) = @$_;
	my $stop = ($time + $span) - ($time % $span); my $strt = $stop - $step*$span;
	do { my ($qlqn,$prld) = @$_; $brsr->request( HTTP::Request::Common::GET((
		grep { $url ? do { print $_."\n"; next } : 1 }
		'https://cmsweb.cern.ch/phedex/graphs/'.( qw( quality_all quantity_rates )[$qlqn]) .
		'?conn='.( qw( Prod Debug )[$prld]).'%2FWebSite&from_node=.%2A&to_node='.($site) .
		'&link=src&no_mss='.( qw( true false )[$prld]).'&starttime='.($strt).'&span='.($span).'&endtime='.($stop))[0]),
		BASE_PATH.HTML_PATH.'/IMAGES/PLOTS/'.( my $inam = 'transfer_'.( qw( quality rate )[$qlqn]) .
			'_'.( qw( prod load )[$prld]).'_'.($unit)).'.png' ); Local::Subs::CREATE_THUMB($inam,800,(620,500)[$qlqn],1);
	} for ( [0,0], [0,1], [1,0], [1,1] ); }

exit if $url;

if ($hrly) {

	Local::Subs::ALERT( q(PROD_QUAL), ((defined $$_[0]) ? (2,1,$$_[0]) : (0))) for [
		map { ( Local::Subs::ROUND($$_[2],0)) } grep { (defined $$_[0]) && ($$_[2] < 75) }
		map { my ($all,$def) = ($_,[ grep {(defined)} @$_ ]); [ ((0+@$all) ? 100*(@$def/@$all) : undef ), Local::Subs::STDEV(@$def) ] }
		map { my ($clip,$keep) = map { (1+int) } map { ((1-(($time%3600)/3600))*($_/48),(2*$_/48)) } 0+@{$$_[0]};
			[ map { map { ($_ >= 86) ? 100 : $_ } (( grep {(defined)} # KLUDGE ... Color Algo Seems Shifted
				( reverse @{ $_ || [] } )[$clip..$keep] ), undef )[0] } @$_ ] }
		(( Local::Subs::SCORE_PLOT( q(transfer_quality_prod_hourly), [102,52,782,499] ))[2] || [] ) ];

# Early Algo Takes Most Recent Vertical Slice Only
#	Local::Subs::ALERT( q(PROD_QUAL), ((defined $$_[0]) ? (2,1,$$_[0]) : (0))) for [
#		map { ( Local::Subs::ROUND($$_[-1][2],0)) } grep { ($$_[-1][0] > 0) && ($$_[-1][2] < 85) }
#		(( Local::Subs::SCORE_PLOT( q(transfer_quality_prod_hourly), [102,52,782,499] ))[1] || [] ) ];

	Local::Subs::ALERT(@$_) for
		grep {(@$_ > 1)} map { [ q(LOAD_QUAL), @{( shift @$_ )||[]}], [ q(LOAD_SKIP), @{( shift @$_ )||[]}] }
		map { ($$_[0] < 50) ? [(undef),[2,1]] : ($$_[2] < 50) ? [[2,1,( Local::Subs::ROUND($$_[2],0))],[0]] : [[0],[0]] }
		map { my ($all,$def) = ($_,[ grep {(defined)} @$_ ]); [ ((0+@$all) ? 100*(@$def/@$all) : undef ), Local::Subs::STDEV(@$def) ] }
		map { my ($clip,$keep) = map { (1+int) } map { ((1-(($time%3600)/3600))*($_/48),(6*$_/48)) } 0+@{$$_[0]};
			[ map { map { ($_ >= 86) ? 100 : $_ } (( grep {(defined)} # KLUDGE ... Color Algo Seems Shifted
				( reverse @{ $_ || [] } )[$clip..$keep] ), undef )[0] } @$_ ] }
		(( Local::Subs::SCORE_PLOT( q(transfer_quality_load_hourly), [115,51,784,499] ))[2] || [] );

# Early Algo Averages last 6 Hours, Equal Weighting for all Data Pts.
#		grep {(@$_ > 1)} map { [ q(LOAD_QUAL), @{( shift @$_ )||[]}], [ q(LOAD_SKIP), @{( shift @$_ )||[]}] }
#		map { (( Local::Subs::AVG( @{ $$_[0]})) < 20) ? [(undef),[2,1]] :
#			( map { ($_ < 70) ? [[2,1,( Local::Subs::ROUND($_,0))],[0]] : [[0],[0]] }
#				( Local::Subs::DOT( @$_[0,1])/ Local::Subs::SUM( @{ $$_[0]}))) }
#		map { my ($clip,$keep) = map { (1+int) } map { ((1-(($time%3600)/3600))*($_/48),(6*$_/48)) } 0+@$_;
#			shift @$_ while (($clip--) && ($$_[0][0]<20)); splice @$_, $keep;
#			[[ map { $$_[0] } @$_ ], [ map { $$_[2] } @$_ ]] }
#		[ reverse @{ ( Local::Subs::SCORE_PLOT( q(transfer_quality_load_hourly), [115,51,784,499] ))[1] || []} ];

	}

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/transfer_plot.ssi'; select FHO;

print <<EndHTML;

<DIV id="transfer_plot_anchor" style="z-index:0; display:block; position:relative; top:0px; left:0px; height:638px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
	<DIV id="transfer_plot_hour" style="z-index:10; display:block; position:absolute; top:29px; left:3px; height:580px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:580px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:310px;"><a id="transfer_plot_leader_0" href="IMAGES/PLOTS/transfer_quality_prod_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_quality_prod_hourly.png?${time}" alt="PhEDEx Production Data Transfer Quality (Last 48 Hours)" title="PhEDEx Production Data Transfer Quality (Last 48 Hours)" width="400" height="310"></a></td>
				<td class="mon_default" style="width:400px; height:310px;"><a href="IMAGES/PLOTS/transfer_quality_load_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_quality_load_hourly.png?${time}" alt="PhEDEx Load Test Transfer Quality (Last 48 Hours)" title="PhEDEx Load Test Transfer Quality (Last 48 Hours)" width="400" height="310"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/transfer_rate_prod_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_rate_prod_hourly.png?${time}" alt="PhEDEx Production Data Transfer Rate (Last 48 Hours)" title="PhEDEx Production Data Transfer Rate (Last 48 Hours)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/transfer_rate_load_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_rate_load_hourly.png?${time}" alt="PhEDEx Load Test Transfer Rate (Last 48 Hours)" title="PhEDEx Load Test Transfer Rate (Last 48 Hours)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="transfer_plot_day" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:580px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:580px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:310px;"><a id="transfer_plot_leader_1" href="IMAGES/PLOTS/transfer_quality_prod_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_quality_prod_daily.png?${time}" alt="PhEDEx Production Data Transfer Quality (Last 45 Days)" title="PhEDEx Production Data Transfer Quality (Last 45 Days)" width="400" height="310"></a></td>
				<td class="mon_default" style="width:400px; height:310px;"><a href="IMAGES/PLOTS/transfer_quality_load_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_quality_load_daily.png?${time}" alt="PhEDEx Load Test Transfer Quality (Last 45 Days)" title="PhEDEx Load Test Transfer Quality (Last 45 Days)" width="400" height="310"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/transfer_rate_prod_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_rate_prod_daily.png?${time}" alt="PhEDEx Production Data Transfer Rate (Last 45 Days)" title="PhEDEx Production Data Transfer Rate (Last 45 Days)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/transfer_rate_load_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_rate_load_daily.png?${time}" alt="PhEDEx Load Test Transfer Rate (Last 45 Days)" title="PhEDEx Load Test Transfer Rate (Last 45 Days)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="transfer_plot_week" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:580px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:580px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:310px;"><a id="transfer_plot_leader_2" href="IMAGES/PLOTS/transfer_quality_prod_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_quality_prod_weekly.png?${time}" alt="PhEDEx Production Data Transfer Quality (Last 52 Weeks)" title="PhEDEx Production Data Transfer Quality (Last 52 Weeks)" width="400" height="310"></a></td>
				<td class="mon_default" style="width:400px; height:310px;"><a href="IMAGES/PLOTS/transfer_quality_load_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_quality_load_weekly.png?${time}" alt="PhEDEx Load Test Transfer Quality (Last 52 Weeks)" title="PhEDEx Load Test Transfer Quality (Last 52 Weeks)" width="400" height="310"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/transfer_rate_prod_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_rate_prod_weekly.png?${time}" alt="PhEDEx Production Data Transfer Rate (Last 52 Weeks)" title="PhEDEx Production Data Transfer Rate (Last 52 Weeks)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/transfer_rate_load_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/transfer_rate_load_weekly.png?${time}" alt="PhEDEx Load Test Transfer Rate (Last 52 Weeks)" title="PhEDEx Load Test Transfer Rate (Last 52 Weeks)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV>
	<DIV style="z-index:0; display:block; position:static; height:638px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_default" style="width:826px; height:638px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:16px;">Production Data</td>
				<td class="mon_default" colspan="4" style="width:400px; height:16px;">Load Tests</td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" colspan="5" style="width:810px; height:570px;"></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:TopUp.displayTopUp(document.getElementById('transfer_plot_leader_'+TransferPlotIndex));" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:this.style.backgroundColor=\'#FFFFFF\';">&uarr; Click to Enlarge Images</td>
				<td class="mon_default" style="width:91px; height:16px;">Select &rarr;</td>
				<td class="mon_default" id="transfer_plot_select_hour" style="width:93px; height:16px; color:black; background-color:#3BB9FF; cursor:pointer;" onClick="javascript:TransferPlotSelect(0);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(TransferPlotIndex!=0)this.style.backgroundColor=\'#FFFFFF\';">Hourly</td>
				<td class="mon_default" id="transfer_plot_select_day" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:TransferPlotSelect(1);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(TransferPlotIndex!=1)this.style.backgroundColor=\'#FFFFFF\';">Daily</td>
				<td class="mon_default" id="transfer_plot_select_week" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:TransferPlotSelect(2);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(TransferPlotIndex!=2)this.style.backgroundColor=\'#FFFFFF\';">Weekly</td>
			</tr>
		</table>
	</DIV>
</DIV>

EndHTML

close FHO;

1

