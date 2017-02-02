#!/usr/bin/perl

use strict;

$|++; print "\n";

my (%config);

my ($home) = grep { -d } $ENV{HOME} or die 'Error: cannot validate the home directory environment variable $HOME';

my ($tilde) = grep { chomp; 1 } `echo ~`;

($tilde eq $home) or die 'Error: $HOME environment variable inconsistent with "~"';

my ($wdir) = grep { chomp; 1 } `pwd`;

($wdir =~ /^\Q${home}\E/) or die 'Error: current working directory inconsistent with home directory '.($home);

(-d $home.'/brazos') or die 'Error: monitor must be unpacked into the home directory '.($home);

($wdir =~ /^\Q${home}\E\/brazos$/) or die 'Error: configure.pl must be executed from "~/brazos"';

($config{mon_path_html}) = grep {
	print 'Detecting HTML document root directory '.($home.$_)."\n\t".' ... Is this correct ? [Y/N]'."\n";
	(<STDIN>) =~ m/^Y$/i } grep {( -d $home.$_ )} map { '/'.$_ }
	qw( public_html public httpdocs htdocs html www web );

while (! defined $config{mon_path_html}) {
	print 'Where is the HTML document root directory located relative to '.($home).' ?'."\n";
	($config{mon_path_html}) =
		grep { ( -d $home.$_ ) or print "\t".'Error: directory '.($home.$_).' does not exist.'."\n" and next }
		grep { (length > 1) or print "\t".'Error: Invalid Entry.'."\n" and next }
		map { s/\s+//g; s/\/{2,}/\//g; s/^\///; s/\/$//; '/'.$_ }
		( scalar <STDIN> );
	last } continue { print "\t".'Please try again.'."\n" }

($config{mon_path_cgi}) = grep {
	print 'Detecting CGI-BIN script alias directory '.($home.$_)."\n\t".' ... Is this correct ? [Y/N]'."\n";
	(<STDIN>) =~ m/^Y$/i } grep {( -d $home.$_ )}
	( q(/cgi-bin), q(/cgi), $config{mon_path_html}.'/cgi-bin', $config{mon_path_html}.'/cgi' );

while (! defined $config{mon_path_cgi}) {
	print 'Where is the CGI-BIN script alias directory located relative to '.($home).' ?'."\n";
	($config{mon_path_cgi}) =
		grep { ( -d $home.$_ ) or print "\t".'Error: directory '.($home.$_).' does not exist.'."\n" and next }
		grep { ($_ !~ m/^\Q$config{mon_path_html}\E$/i) or print "\t".'Error: ... Cannot be identical to HTML document root.'."\n" and next }
		grep { (length > 1) or print "\t".'Error: Invalid Entry.'."\n" and next }
		map { s/\s+//g; s/\/{2,}/\//g; s/^\///; s/\/$//; '/'.$_ }
		( scalar <STDIN> );
	last } continue { print "\t".'Please try again.'."\n" }

print "\n".'Vital configuration completed successfully.'."\n";

open FHO, '>'.($home).'/brazos/sources/config/Configure.mk' or die 'Cannot write to Configure.mk';
print FHO "\n"; for my $key (sort keys %config) { print FHO +(uc $key).' = '.$config{$key}."\n"; } print FHO "\n";
close FHO;

system ( 'cat '.($home).'/brazos/sources/config/Configure.mk' );

