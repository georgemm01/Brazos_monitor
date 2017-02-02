#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i;

my ($html) = Local::Subs::HTML_EXTENSION();
my ($other_html) = ${{ html => 'shtml', shtml => 'html' }}{$html};
my ($ssi_html) = ${{ html => '', shtml => '_shtml' }}{$html};

my ($mods) = Local::Subs::CONFIG_MODULES();

my ($time) = time;

my ($name) = map { "\n\n".'<H2>&#9674; '.($_).' &#9674;</H2>'."\n\n" } grep { (length) } ${ Local::Subs::CONFIG_LOCAL('SITE') || {}}{'NAME'};
my ($clst) = map { (length) ? $_ : q(Local) } ${ Local::Subs::CONFIG_LOCAL('SITE') || {}}{'CLUSTER'};

system ( 'rm -f '.BASE_PATH.HTML_PATH.'/all.'.($other_html).' 2>/dev/null' ); my (@FHO); open $FHO[0], '>'.BASE_PATH.HTML_PATH.'/all.'.($html);
for my $i (1..5) { system ( 'rm -f '.BASE_PATH.HTML_PATH.'/page_'.($i).'.'.($other_html).' 2>/dev/null' );
	open $FHO[$i], '>'.BASE_PATH.HTML_PATH.'/page_'.($i).'.'.($html); }

for my $i (0..5) {

  select $FHO[$i];
  print <<EndHTML;

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<head>

<title>Brazos Data Analysis Site Monitoring Utility</title>

<META HTTP-EQUIV="Content-Type" content="text/html;charset=utf-8">
<META HTTP-EQUIV="Refresh" CONTENT="600">
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-control" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">

<LINK rel="stylesheet" href="CSS/mon.css" type="text/css">

<STYLE type="text/css">
A#page_${i}_top, A#page_${i}_bot,
A#page_${i}_top:link, A#page_${i}_bot:link,
A#page_${i}_top:visited, A#page_${i}_bot:visited {
	border-top: 2px solid black;
	border-bottom: 2px solid black;
	color: #3BB9FF;
	background-color: inherit; }
</STYLE>

<script type="text/javascript" language="JavaScript" src="JAVASCRIPT/mon.js"></script>

<script type="text/javascript" language="JavaScript" src="JAVASCRIPT/top_up/top_up-min.js"></script>

<script type="text/javascript" language="JavaScript" src="JAVASCRIPT/mon_top_up.js"></script>

</head>

<body onLoad="javascript:MonitorInitialize();" style="margin:0px 0px; padding:0px; text-align:center; background-repeat:repeat; background-position:top left; background-image:url('IMAGES/GLOBAL/bg_W.gif');">

<DIV id="tier3_mon_anchor" style="z-index:0; display:block; position:static; height:auto; width:826px; margin:20px auto; padding:0px; text-align:center; overflow:hidden; background-image:none;">

<H1>Brazos Data Analysis Site Monitoring Utility</H1>${name}

<p>
<!--#include virtual="SSI/GLOBAL/view_page_top${ssi_html}.ssi"-->
<br>

<p>
<!--#include virtual="SSI/GLOBAL/time_updated_format.ssi"-->
<br>

<noscript>
<p>
<SPAN style="font-size:18px; font-weight:bold; color:red; background-color:transparent;">
	Warning: You must enable JavaScript for optimal site functionality!
</SPAN>
<br>
</noscript>

EndHTML

}
for my $i (0,1) { select $FHO[$i];
	print "\n<p>\n<hr>\n\n<H2>Data Transfers to the ${clst} Cluster</H2>\n";
	print "<p>\n<!--#include virtual=\"SSI/TABLES/${_}.ssi\"-->\n<br>\n" for
		grep { $$mods{(uc)}{'ACTIVE'} }
		( qw( transfer_plot transfer_data ));
	print "\n";

}
for my $i (0,2) { select $FHO[$i];
	print "\n<p>\n<hr>\n\n<H2>Data Holdings on the ${clst} Cluster</H2>\n";
	print "<p>\n<!--#include virtual=\"SSI/TABLES/${_}.ssi\"-->\n<br>\n" for
		grep { $$mods{(uc)}{'ACTIVE'} }
		( qw( subscription_plot subscription_data disk_usage_data totaldisk_data ));

}
for my $i (0,3) { select $FHO[$i];
	print "\n<p>\n<hr>\n\n<H2>Job Status of the ${clst} Cluster</H2>\n";
	print "<p>\n<!--#include virtual=\"SSI/TABLES/${_}.ssi\"-->\n<br>\n" for
		grep { $$mods{(uc)}{'ACTIVE'} }
### replacing qstat module with squeue module!!! Jun '16, KC
		( qw( job_plot squeue_hepxjobs_data condorq_data user_jobs_plot_data ));
		#( qw( job_plot qstat_data condorq_data user_jobs_plot_data ));

}
for my $i (0,4) { select $FHO[$i];
	print "\n<p>\n<hr>\n\n<H2>Service Availability of the ${clst} Cluster</H2>\n";
	print "<p>\n<!--#include virtual=\"SSI/TABLES/${_}.ssi\"-->\n<br>\n" for
		grep { $$mods{(uc)}{'ACTIVE'} }
		( qw( sam_percentage heartbeat_data load_data queue_data sam_plot cats_data ));

}
for my $i (0,5) { select $FHO[$i];
        print "\n<p>\n<hr>\n\n";
        do { print `$_` } for BASE_PATH.CGI_PATH.'/alert.cgi';
}
for my $i (0..5) { select $FHO[$i]; print <<EndHTML;

<p>
<hr>

<p>
<!--#include virtual="SSI/GLOBAL/view_page_bot${ssi_html}.ssi"-->
<br>

</DIV>

</body>

</html>

EndHTML

close $FHO[$i];
}

system( 'rm -f '.BASE_PATH.HTML_PATH.'/index.'.($other_html).' 2>/dev/null' );
system( 'cp '.BASE_PATH.HTML_PATH.'/page_1.'.($html).' '.BASE_PATH.HTML_PATH.'/index.'.($html));

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/GLOBAL/time_updated_format.ssi'; print FHO "\n".'Updated: &nbsp; ' .
	( Local::Subs::DATE_FORMAT($time,1,q(%A, %Y-%m-%d %R UTC))).' &nbsp; &nbsp; &nbsp; &nbsp; ( ' .
	( Local::Subs::DATE_FORMAT($time,!1,q(%A, %Y-%m-%d %R %Z))).' )'."\n\n"; close FHO;

open FHO, '>'.BASE_PATH.HTML_PATH.'/SSI/GLOBAL/time_updated_unix.ssi'; print FHO $time; close FHO;

1

