#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

use LWP::UserAgent ();

use HTTP::Request::Common ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my (@unit) = ( !(! m/\bhour(?:ly)?\b/i), !(! m/\b(?:day|daily)\b/i), !(! m/\bweek(?:ly)?\b/i), !(! m/\ball\b/i));

my ($brsr) = LWP::UserAgent->new();

my ($time) = time;

my ($site) = grep { (length) or die 'Cannot Establish Local CMS Site Descriptor' } ${ Local::Subs::CONFIG_LOCAL('CMS') || {}}{'SITE'};

for (	$unit[0] || (!($unit[1]) && !($unit[2])) || $unit[3] ? [48,3600,'hourly'] : (),
	$unit[1] || $unit[3] ? [45,86400,'daily'] : (),
	$unit[2] || $unit[3] ? [52,604800,'weekly'] : ()) { my ($step,$span,$unit) = @$_;
	my $stop = ($time + $span) - ($time % $span); my $strt = $stop - $step*$span;
	do { my ($qdrs,$prld) = @$_; $brsr->request(HTTP::Request::Common::GET(
		'https://cmsweb.cern.ch/phedex/graphs/'.( qw( pending resident )[$qdrs]).'?conn=' .
		( qw( Prod Debug )[$prld]).'%2FWebSite'.( !$qdrs && '&from_node=.%2A' ).'&'.( !$qdrs && 'to_' ).'node='.($site).'&link=' .
		( qw( src dest )[$qdrs]).'&no_mss='.( qw( true false )[$prld]).'&starttime='.($strt).'&span='.($span).'&endtime='.($stop)),
		BASE_PATH.HTML_PATH.'/IMAGES/PLOTS/'.( my $inam = 'subscription_'.( qw( queued resident )[$qdrs]) .
			'_'.( qw( prod load )[$prld]).'_'.($unit)).'.png' ); Local::Subs::CREATE_THUMB($inam,800,500,1);
	} for ( [0,0], [0,1], [1,0], [1,1] ); }

open FHO, '>'.BASE_PATH.HTML_PATH.'/htdocs/tier3/mon/SSI/TABLES/subscription_plot.ssi'; select FHO;

print <<EndHTML;

<DIV id="subscription_plot_anchor" style="z-index:0; display:block; position:relative; top:0px; left:0px; height:318px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
	<DIV id="subscription_plot_hour" style="z-index:10; display:block; position:absolute; top:29px; left:3px; height:260px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:260px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a id="subscription_plot_leader_0" href="IMAGES/PLOTS/subscription_queued_prod_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_prod_hourly.png?${time}" alt="PhEDEx Queued Production Data Volume (Last 48 Hours)" title="PhEDEx Queued Production Data Volume (Last 48 Hours)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_prod_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_prod_hourly.png?${time}" alt="PhEDEx Resident Production Data Volume (Last 48 Hours)" title="PhEDEx Resident Production Data Volume (Last 48 Hours)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="subscription_plot_day" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:260px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:260px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a id="subscription_plot_leader_1" href="IMAGES/PLOTS/subscription_queued_prod_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_prod_daily.png?${time}" alt="PhEDEx Queued Production Data Volume (Last 45 Days)" title="PhEDEx Queued Production Data Volume (Last 45 Days)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_prod_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_prod_daily.png?${time}" alt="PhEDEx Resident Production Data Volume (Last 45 Days)" title="PhEDEx Resident Production Data Volume (Last 45 Days)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="subscription_plot_week" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:260px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:260px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a id="subscription_plot_leader_2" href="IMAGES/PLOTS/subscription_queued_prod_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_prod_weekly.png?${time}" alt="PhEDEx Queued Production Data Volume (Last 52 Weeks)" title="PhEDEx Queued Production Data Volume (Last 52 Weeks)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_prod_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_prod_weekly.png?${time}" alt="PhEDEx Resident Production Data Volume (Last 52 Weeks)" title="PhEDEx Resident Production Data Volume (Last 52 Weeks)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV>
	<DIV style="z-index:0; display:block; position:static; height:318px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_default" style="width:826px; height:318px;">
			<tr class="mon_default">
				<td class="mon_default" colspan="5" style="width:810px; height:16px;">Production Data</td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" colspan="5" style="width:810px; height:250px;"></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:TopUp.displayTopUp(document.getElementById('subscription_plot_leader_'+SubscriptionPlotIndex));" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:this.style.backgroundColor=\'#FFFFFF\';">&uarr; Click to Enlarge Images</td>
				<td class="mon_default" style="width:91px; height:16px;">Select &rarr;</td>
				<td class="mon_default" id="subscription_plot_select_hour" style="width:93px; height:16px; color:black; background-color:#3BB9FF; cursor:pointer;" onClick="javascript:SubscriptionPlotSelect(0);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(SubscriptionPlotIndex!=0)this.style.backgroundColor=\'#FFFFFF\';">Hourly</td>
				<td class="mon_default" id="subscription_plot_select_day" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:SubscriptionPlotSelect(1);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(SubscriptionPlotIndex!=1)this.style.backgroundColor=\'#FFFFFF\';">Daily</td>
				<td class="mon_default" id="subscription_plot_select_week" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:SubscriptionPlotSelect(2);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(SubscriptionPlotIndex!=2)this.style.backgroundColor=\'#FFFFFF\';">Weekly</td>
			</tr>
		</table>
	</DIV>
</DIV>

EndHTML

close FHO;

=pod
print <<EndHTML;

<DIV id="subscription_plot_anchor" style="z-index:0; display:block; position:relative; top:0px; left:0px; height:578px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
	<DIV id="subscription_plot_hour" style="z-index:10; display:block; position:absolute; top:29px; left:3px; height:520px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:520px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a id="subscription_plot_leader_0" href="IMAGES/PLOTS/subscription_queued_prod_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_prod_hourly.png?${time}" alt="PhEDEx Queued Production Data Volume (Last 48 Hours)" title="PhEDEx Queued Production Data Volume (Last 48 Hours)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_queued_load_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_load_hourly.png?${time}" alt="PhEDEx Queued Load Test Volume (Last 48 Hours)" title="PhEDEx Queued Load Test Volume (Last 48 Hours)" width="400" height="250"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_prod_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_prod_hourly.png?${time}" alt="PhEDEx Resident Production Data Volume (Last 48 Hours)" title="PhEDEx Resident Production Data Volume (Last 48 Hours)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_load_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_load_hourly.png?${time}" alt="PhEDEx Resident Load Test Volume (Last 48 Hours)" title="PhEDEx Resident Load Test Volume (Last 48 Hours)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="subscription_plot_day" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:520px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:520px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a id="subscription_plot_leader_1" href="IMAGES/PLOTS/subscription_queued_prod_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_prod_daily.png?${time}" alt="PhEDEx Queued Production Data Volume (Last 45 Days)" title="PhEDEx Queued Production Data Volume (Last 45 Days)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_queued_load_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_load_daily.png?${time}" alt="PhEDEx Queued Load Test Volume (Last 45 Days)" title="PhEDEx Queued Load Test Volume (Last 45 Days)" width="400" height="250"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_prod_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_prod_daily.png?${time}" alt="PhEDEx Resident Production Data Volume (Last 45 Days)" title="PhEDEx Resident Production Data Volume (Last 45 Days)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_load_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_load_daily.png?${time}" alt="PhEDEx Resident Load Test Volume (Last 45 Days)" title="PhEDEx Resident Load Test Volume (Last 45 Days)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="subscription_plot_week" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:520px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:520px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a id="subscription_plot_leader_2" href="IMAGES/PLOTS/subscription_queued_prod_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_prod_weekly.png?${time}" alt="PhEDEx Queued Production Data Volume (Last 52 Weeks)" title="PhEDEx Queued Production Data Volume (Last 52 Weeks)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_queued_load_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_queued_load_weekly.png?${time}" alt="PhEDEx Queued Load Test Volume (Last 52 Weeks)" title="PhEDEx Queued Load Test Volume (Last 52 Weeks)" width="400" height="250"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_prod_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_prod_weekly.png?${time}" alt="PhEDEx Resident Production Data Volume (Last 52 Weeks)" title="PhEDEx Resident Production Data Volume (Last 52 Weeks)" width="400" height="250"></a></td>
				<td class="mon_default" style="width:400px; height:250px;"><a href="IMAGES/PLOTS/subscription_resident_load_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/subscription_resident_load_weekly.png?${time}" alt="PhEDEx Resident Load Test Volume (Last 52 Weeks)" width="400" title="PhEDEx Resident Load Test Volume (Last 52 Weeks)" width="400" height="250"></a></td>
			</tr>
		</table>
	</DIV>
	<DIV style="z-index:0; display:block; position:static; height:578px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_default" style="width:826px; height:578px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:16px;">Production Data</td>
				<td class="mon_default" colspan="4" style="width:400px; height:16px;">Load Tests</td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" colspan="5" style="width:810px; height:510px;"></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:TopUp.displayTopUp(document.getElementById('subscription_plot_leader_'+SubscriptionPlotIndex));" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:this.style.backgroundColor=\'#FFFFFF\';">&uarr; Click to Enlarge Images</td>
				<td class="mon_default" style="width:91px; height:16px;">Select &rarr;</td>
				<td class="mon_default" id="subscription_plot_select_hour" style="width:93px; height:16px; color:black; background-color:#3BB9FF; cursor:pointer;" onClick="javascript:SubscriptionPlotSelect(0);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(SubscriptionPlotIndex!=0)this.style.backgroundColor=\'#FFFFFF\';">Hourly</td>
				<td class="mon_default" id="subscription_plot_select_day" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:SubscriptionPlotSelect(1);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(SubscriptionPlotIndex!=1)this.style.backgroundColor=\'#FFFFFF\';">Daily</td>
				<td class="mon_default" id="subscription_plot_select_week" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:SubscriptionPlotSelect(2);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(SubscriptionPlotIndex!=2)this.style.backgroundColor=\'#FFFFFF\';">Weekly</td>
			</tr>
		</table>
	</DIV>
</DIV>

EndHTML

close FHO;
=cut

1

