#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

use LWP::UserAgent ();

use HTTP::Request::Common ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i;

my ($brsr) = LWP::UserAgent->new();

( my ($newv) = map { chomp; 0+$_ } map {( $_->content())} grep {( $_->is_success())}
	$brsr->request( HTTP::Request::Common::GET('http://www.joelwalker.net/code/brazos/version.txt'))) or
	die 'Cannot establish latest Brazos release.';

( my ($oldv) = map { chomp; 0+$_ } (( open FHI, BASE_PATH.MON_PATH.'/CONFIG/version.txt' ) ? ( scalar <FHI>, close FHI)[0] : ())) or
	die 'Cannot establish installed Brazos version.';

if ($newv > $oldv) { ( my $newp = $newv ) =~ s/\./p/g;
	system ( 'rm -rf '.BASE_PATH.MON_PATH.'/UPGRADE/* 2>/dev/null' );
	$brsr->request( HTTP::Request::Common::GET('http://www.joelwalker.net/code/brazos/upgrade_'.($newp).'.tgz'),
		BASE_PATH.MON_PATH.'/UPGRADE/upgrade.tgz' )->is_success() or die 'Cannot download Brazos upgrade package '.($newp);
	(( system ( 'cd '.BASE_PATH.MON_PATH.'/UPGRADE/ && [ -f ./upgrade.tgz ] && tar -xzf ./upgrade.tgz && ./upgrade.sh' )) == 0 )
		or die 'Cannot install Brazos upgrade package '.($newp); Local::Subs::ALERT( q(UPGRADE), (2,1,$newv));
	( open FHO, '>', BASE_PATH.MON_PATH.'/CONFIG/version.txt' ) && do { print FHO $newv."\n"; close FHO }; }

1

