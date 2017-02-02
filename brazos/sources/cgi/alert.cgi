#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin;

use Local::Path qw(:all);

use Local::Subs ();

print "Content-type:text/html\n\n" if (exists $ENV{HTTP_HOST});

my ($alrt) = ( $ENV{QUERY_STRING_UNESCAPED} =~ /^(\w+)$/ );

my (@alrt) = Local::Subs::LOAD_ALERT( $alrt, qw( alert title long active ));

my ($summ) = Local::Subs::SUMM_ALERT() || {}; 

my ($shrt) = !(exists $ENV{HTTP_HOST});

my ($html) = Local::Subs::HTML_EXTENSION();

print '<h2>Alert Summary'.((defined $alrt) && !(!@alrt) && ' - '.$alrt[0][1]).(($shrt) && ' (<a href="alert.'.($html).'" class="mon_default">Details</a>)').'</h2>'."\n".'<p>'."\n";

print '<DIV id="alert_data_anchor" style="z-index:0; display:block; position:static; height:auto; width:826px; margin:0px 0px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="width:826px; height:auto;">'."\n";
my ($j) = 0; for (@alrt) { my ($stmp,$alvl) = @{ $$summ{$$_[0]} || [] };
	my ($mode) = ($$_[3]) ? ($$_[3] == 1) ? (defined $stmp) ? do { $stmp = '( '.( Local::Subs::DATE_FORMAT($stmp,1,q(%Y-%m-%d %R UTC))).' )'; ($alvl == 0) ? 3 : 2 } : 1 : 0 : -1;
	(next) unless (((defined $alrt) && !(!@alrt)) || ($mode != 0));
	print "\t\t".'<tr class="mon_default" style="color:black; background-color:#FFFFFF;">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:210px; height:16px; color:black; background-color:#20B2AA;">'.($$_[1]).'</td>'."\n";
	unless ($shrt) {
		print "\t\t\t".'<td class="mon_inset" rowspan="2" style="width:566px; height:auto; text-align:justify; color:black; background-color:#' .
			(( qw( E9FBFA B3F3F0 ))[($j++)%2]).';">'.($$_[2]).'</td>'."\n";
		print "\t\t".'</tr>'."\n";
		print "\t\t".'<tr class="mon_default" style="color:black; background-color:#FFFFFF;">'."\n"; }
	my ($sep) = ($shrt) ? '&nbsp; &nbsp;' : '<br>';
	print "\t\t\t".'<td class="mon_default" style="width:'.($shrt?'590':'210').'px; height:auto; color:black; background-color:'.(( q(#FFFFFF), qw( orange red green ), q(#FFFFFF))[$mode]).';">' .
		(( q(Alert has NULL Status), q(Test Status: UNKNOWN).($sep).'( No Result for 24 Hours )',
			q(Test Status: FAILED).($sep.$stmp), q(Test Status: PASSED).($sep.$stmp), q(Alert is Disabled))[$mode]).'</td>'."\n";
	print "\t\t".'</tr>'."\n"; }
print "\t\t".'<tr class="mon_default" style="color:white; background-color:#E62E2E;">'."\n" .
	"\t\t\t".'<td class="mon_default" style="width:810px; height:16px;">No '.((defined $alrt)?'Matching Alert':'Alerts').' Located</td>'."\n" .
	"\t\t".'</tr>'."\n" unless (@alrt);
print "\t".'</table>'."\n";
print '</DIV>'."\n";

print '<br>'."\n";

print 'View <a href="alert.'.($html).'" class="mon_default">All</a> Alerts'."\n".'<br>'."\n" if (defined $alrt);

1;

