#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i;

my ($users) = Local::Subs::LOCAL_USER_NAME();

my ($html) = Local::Subs::HTML_EXTENSION();
my ($other_html) = ${{ html => 'shtml', shtml => 'html' }}{$html};
my ($ssi_html) = ${{ html => '', shtml => '_shtml' }}{$html};

do { system ( 'rm -f '.BASE_PATH.HTML_PATH.'/'.($_).'.'.($other_html).' 2>/dev/null' ); } for ( qw( id name ));
my (@FHO); open $FHO[0], '>'.BASE_PATH.HTML_PATH.'/id.'.($html); open $FHO[1], '>'.BASE_PATH.HTML_PATH.'/name.'.($html);

for my $i (0,1) { select $FHO[$i]; my ($tag) = ( qw( id name ))[$i]; print <<EndHTML;

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<head>

<title>Local Cluster User Database </title>

<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-control" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">

<LINK rel="stylesheet" href="CSS/mon.css" type="text/css">

<STYLE type="text/css">
A#page_${tag}_top, A#page_${tag}_bot,
A#page_${tag}_top:link, A#page_${tag}_bot:link,
A#page_${tag}_top:visited, A#page_${tag}_bot:visited {
	border-top: 2px solid black;
	border-bottom: 2px solid black;
	color: #3BB9FF;
	background-color: inherit; }
</STYLE>

</head>

<body style="margin:0px 0px; padding:0px; text-align:center; background-repeat:repeat; background-position:top left; background-image:url('IMAGES/GLOBAL/bg_W.gif');">

<DIV id="tier3_mon_anchor" style="z-index:0; display:block; position:static; height:auto; width:826px; margin:20px auto; padding:0px; text-align:center; overflow:hidden; background-image:none;">

<H1>Local Cluster User Database</H1>

<p>
<!--#include virtual="SSI/GLOBAL/view_users_top${ssi_html}.ssi"-->
<br>

<p>
<hr>

<DIV id="tier3_users_anchor" style="z-index:0; display:block; position:static; height:auto; width:424px; margin:0px 201px; padding:0px; text-align:center; overflow:hidden;">

EndHTML

} do { select $FHO[0];
	print "\t".'<table class="mon_default" style="width:424px; height:auto;">'."\n";
	print "\t\t".'<tr class="mon_default" style="color:black; background-color:#20B2AA;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:132px; height:16px;">ID</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:266px; height:16px;">Name</td>'."\n";
	print "\t\t".'</tr>'."\n";
	for ( map { $$_[0] } sort { ($$a[1] <=> $$b[1]) || ($$a[2] cmp $$b[2]) || ($$a[3] <=> $$b[3]) }
		map {[ $_, ( /^cms(\d{4})$/ ? (1,undef,$1) : (0,lc,undef)) ]} keys %$users ) {
		print "\t\t".'<tr class="mon_default">'."\n";
		print "\t\t\t".'<td class="mon_default" style="width:132px; height:16px;">'.($_).'</td>'."\n";
		print "\t\t\t".'<td class="mon_default" style="width:266px; height:16px;">'.( /^cms\d{4}$/ && q(CMS: )) .
			($$users{$_}).'</td>'."\n";
		print "\t\t".'</tr>'."\n"; }
	print "\t".'</table>'."\n";
}; do { select $FHO[1];
	print "\t".'<table class="mon_default" style="width:424px; height:auto;">'."\n";
	print "\t\t".'<tr class="mon_default" style="color:black; background-color:#20B2AA;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:266px; height:16px;">Name</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:132px; height:16px;">ID</td>'."\n";
	print "\t\t".'</tr>'."\n";
	for ( map { $$_[0] } sort { ($$a[1] cmp $$b[1]) } map {[ $_, ( Local::Subs::LAST_NAME_FIRST($$users{$_}))[0]]} keys %$users ) {
		print "\t\t".'<tr class="mon_default">'."\n";
		print "\t\t\t".'<td class="mon_default" style="width:266px; height:16px;">'.( /^cms\d{4}$/ && q(CMS: )) .
			($$users{$_}).'</td>'."\n";
		print "\t\t\t".'<td class="mon_default" style="width:132px; height:16px;">'.($_).'</td>'."\n";
		print "\t\t".'</tr>'."\n"; }
	print "\t".'</table>'."\n";
}; for my $i (0,1) { select $FHO[$i]; print <<EndHTML;

</DIV>

<p>
<hr>

<p>
<!--#include virtual="SSI/GLOBAL/view_users_bot${ssi_html}.ssi"-->
<br>

</DIV>

</body>

</html>

EndHTML

close $FHO[$i]; }

1

