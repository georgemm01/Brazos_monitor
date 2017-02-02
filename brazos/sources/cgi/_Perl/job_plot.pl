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

for (	$unit[0] || (!($unit[1]) && !($unit[2])) || $unit[3] ? ['last48',undef,'hourly'] : (),
	$unit[1] || $unit[3] ? [45,86400,'daily'] : (),
	$unit[2] || $unit[3] ? [52,604800,'weekly'] : ()) { my ($step,$span,$unit) = @$_;

	my ($scpe) = ((defined $span) ? do { my $stop = ($time + $span) - ($time % $span); my $strt = $stop - $step*$span;
		'&start='.( Local::Subs::DATE_FORMAT($strt,1,'%Y-%m-%d')).'&end='.( Local::Subs::DATE_FORMAT($stop,1,'%Y-%m-%d')).'&timeRange=daily' } :
		'&start=null&end=null&timeRange='.($step)) . '&granularity='.( ucfirst($unit));

	do { my ($qery,$type,$fnam) = @$_; $brsr->request( HTTP::Request::Common::GET(
		'http://dashb-cms-jobsmry.cern.ch/dashboard/request.py/'.($qery).'?type='.($type) .
			'&sites='.($site).'&activities=all&sitesSort=3&generic=0&sortBy=1'.($scpe) ),
		BASE_PATH.HTML_PATH.'/IMAGES/PLOTS/'.( my $inam = 'job_'.($fnam).'_'.($unit)).'.png' );
		Local::Subs::SIZE_IMAGE($inam,800,600); Local::Subs::CREATE_THUMB($inam,800,600,1);
	} for (
		[ qw( jobnumbers_individual s submitted) ],
		[ qw( jobnumbers_individual p pending) ],
		[ qw( jobnumbers_individual r running) ],
		[ qw( jobnumbers_individual t terminated) ],
		[ qw( consumptions_individual wab running_cpu) ],
		[ qw( efficiency_individual ea running_cpu_efficiency) ],
		[ qw( terminatedjobsstatus_individual nsfb terminated_status) ],
		[ qw( terminatedjobsstatus_individual ebsf terminated_status_efficiency) ],
		[ qw( failedjobsstatus_individual aahb terminated_status_failed_grid) ],
		[ qw( failedjobsstatus_individual aabb terminated_status_failed_application) ],
	); }

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/TABLES/job_plot.ssi'; select FHO;

print <<EndHTML;

<DIV id="job_plot_anchor" style="z-index:0; display:block; position:relative; top:0px; left:0px; height:678px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
	<DIV id="job_plot_runtime_hour" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:620px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:620px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a id="job_plot_leader_0_0" href="IMAGES/PLOTS/job_submitted_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_submitted_hourly.png?${time}" alt="Submitted Jobs Summary (Last 48 Hours)" title="Submitted Jobs Summary (Last 48 Hours)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_hourly.png?${time}" alt="Running Jobs Summary (Last 48 Hours)" title="Running Jobs Summary (Last 48 Hours)" width="400" height="300"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_cpu_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_cpu_hourly.png?${time}" alt="Job Runtime Days Expended per Calendar Day (Last 48 Hours)" title="Job Runtime Days Expended per Calendar Day (Last 48 Hours)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_cpu_efficiency_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_cpu_efficiency_hourly.png?${time}" alt="Processor Usage per Expended Runtime Efficiency (Last 48 Hours)" title="Processor Usage per Expended Runtime Efficiency (Last 48 Hours)" width="400" height="300"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="job_plot_termination_hour" style="z-index:10; display:block; position:absolute; top:29px; left:3px; height:620px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:620px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a id="job_plot_leader_1_0" href="IMAGES/PLOTS/job_terminated_status_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_hourly.png?${time}" alt="Job Termination Status Summary (Last 48 Hours)" title="Job Termination Status Summary (Last 48 Hours)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_efficiency_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_efficiency_hourly.png?${time}" alt="Job Termination Success Efficiency (Last 48 Hours)" title="Job Termination Success Efficiency (Last 48 Hours)" width="400" height="300"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_failed_application_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_failed_application_hourly.png?${time}" alt="Job Termination Failure Application Diagnostics (Last 48 Hours)" title="Job Termination Failure Application Diagnostics (Last 48 Hours)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_failed_grid_hourly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_failed_grid_hourly.png?${time}" alt="Job Termination Failure Grid Diagnostics (Last 48 Hours)" title="Job Termination Failure Grid Diagnostics (Last 48 Hours)" width="400" height="300"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="job_plot_runtime_day" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:620px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:620px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a id="job_plot_leader_0_1" href="IMAGES/PLOTS/job_submitted_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_submitted_daily.png?${time}" alt="Submitted Jobs Summary (Last 45 Days)" title="Submitted Jobs Summary (Last 45 Days)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_daily.png?${time}" alt="Running Jobs Summary (Last 45 Days)" title="Running Jobs Summary (Last 45 Days)" width="400" height="300"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_cpu_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_cpu_daily.png?${time}" alt="Job Runtime Days Expended per Calendar Day (Last 45 Days)" title="Job Runtime Days Expended per Calendar Day (Last 45 Days)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_cpu_efficiency_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_cpu_efficiency_daily.png?${time}" alt="Processor Usage per Expended Runtime Efficiency (Last 45 Days)" title="Processor Usage per Expended Runtime Efficiency (Last 45 Days)" width="400" height="300"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="job_plot_termination_day" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:620px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:620px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a id="job_plot_leader_1_1" href="IMAGES/PLOTS/job_terminated_status_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_daily.png?${time}" alt="Job Termination Status Summary (Last 45 Days)" title="Job Termination Status Summary (Last 45 Days)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_efficiency_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_efficiency_daily.png?${time}" alt="Job Termination Success Efficiency (Last 45 Days)" title="Job Termination Success Efficiency (Last 45 Days)" width="400" height="300"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_failed_application_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_failed_application_daily.png?${time}" alt="Job Termination Failure Application Status (Last 45 Days)" title="Job Termination Failure Application Status (Last 45 Days)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_failed_grid_daily.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_failed_grid_daily.png?${time}" alt="Job Termination Failure Grid Status (Last 45 Days)" title="Job Termination Failure Grid Status (Last 45 Days)" width="400" height="300"></a></td>
			</tr>
		</table>
	</DIV> 
	<DIV id="job_plot_runtime_week" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:620px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:620px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a id="job_plot_leader_0_2" href="IMAGES/PLOTS/job_submitted_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_submitted_weekly.png?${time}" alt="Submitted Jobs Summary (Last 52 Weeks)" title="Submitted Jobs Summary (Last 52 Weeks)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_weekly.png?${time}" alt="Running Jobs Summary (Last 52 Weeks)" title="Running Jobs Summary (Last 52 Weeks)" width="400" height="300"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_cpu_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_cpu_weekly.png?${time}" alt="Job Runtime Days Expended per Calendar Day (Last 52 Weeks)" title="Job Runtime Days Expended per Calendar Day (Last 52 Weeks)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_running_cpu_efficiency_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_running_cpu_efficiency_weekly.png?${time}" alt="Processor Usage per Expended Runtime Efficiency (Last 52 Weeks)" title="Processor Usage per Expended Runtime Efficiency (Last 52 Weeks)" width="400" height="300"></a></td>
			</tr>
		</table>
	</DIV>
	<DIV id="job_plot_termination_week" style="z-index:-10; display:block; position:absolute; top:29px; left:3px; height:620px; width:820px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_inner" style="width:820px; height:620px;">
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a id="job_plot_leader_1_2" href="IMAGES/PLOTS/job_terminated_status_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_weekly.png?${time}" alt="Job Termination Status Summary (Last 52 Weeks)" title="Job Termination Status Summary (Last 52 Weeks)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_efficiency_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_efficiency_weekly.png?${time}" alt="Job Termination Success Efficiency (Last 52 Weeks)" title="Job Termination Success Efficiency (Last 52 Weeks)" width="400" height="300"></a></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_failed_application_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_failed_application_weekly.png?${time}" alt="Job Termination Failure Application Status (Last 52 Weeks)" title="Job Termination Failure Application Status (Last 52 Weeks)" width="400" height="300"></a></td>
				<td class="mon_default" style="width:400px; height:300px;"><a href="IMAGES/PLOTS/job_terminated_status_failed_grid_weekly.png?${time}" target="NEW"><img class="mon_default" src="IMAGES/THUMBS/job_terminated_status_failed_grid_weekly.png?${time}" alt="Job Termination Failure Grid Status (Last 52 Weeks)" title="Job Termination Failure Grid Status (Last 52 Weeks)" width="400" height="300"></a></td>
			</tr>
		</table>
	</DIV>
	<DIV style="z-index:0; display:block; position:static; height:678px; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">
		<table class="mon_default" style="width:826px; height:678px;">
			<tr class="mon_default">
				<td class="mon_default" colspan="2" style="width:299px; height:16px;">Process Cycle Statistics</td>
				<td class="mon_default" colspan="4" style="width:400px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:TopUp.displayTopUp(document.getElementById('job_plot_leader_'+JobPlotModeIndex+'_'+JobPlotSpanIndex));" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:this.style.backgroundColor=\'#FFFFFF\';">Click to Enlarge Images &darr;</td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" colspan="6" style="width:810px; height:610px;"></td>
			</tr>
			<tr class="mon_default">
				<td class="mon_default" id="job_plot_mode_select_runtime" style="width:195px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:JobPlotModeSelect(0);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(JobPlotModeIndex!=0)this.style.backgroundColor=\'#FFFFFF\';">Initiation &amp; Runtime</td>
				<td class="mon_default" id="job_plot_mode_select_termination" style="width:195px; height:16px; color:black; background-color:#3BB9FF; cursor:pointer;" onClick="javascript:JobPlotModeSelect(1);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(JobPlotModeIndex!=1)this.style.backgroundColor=\'#FFFFFF\';">Termination Status</td>
				<td class="mon_default" style="width:91px; height:16px;">&larr; Select &rarr;</td>
				<td class="mon_default" id="job_plot_span_select_hour" style="width:93px; height:16px; color:black; background-color:#3BB9FF; cursor:pointer;" onClick="javascript:JobPlotSpanSelect(0);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(JobPlotSpanIndex!=0)this.style.backgroundColor=\'#FFFFFF\';">Hourly</td>
				<td class="mon_default" id="job_plot_span_select_day" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:JobPlotSpanSelect(1);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(JobPlotSpanIndex!=1)this.style.backgroundColor=\'#FFFFFF\';">Daily</td>
				<td class="mon_default" id="job_plot_span_select_week" style="width:93px; height:16px; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:JobPlotSpanSelect(2);" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:if(JobPlotSpanIndex!=2)this.style.backgroundColor=\'#FFFFFF\';">Weekly</td>
			</tr>
		</table>
	</DIV>
</DIV>

EndHTML

close FHO;

1

