#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

print "Content-type:text/html\n\n";

my ($html) = Local::Subs::HTML_EXTENSION();

my ($tmod,$dtim) = ( $ENV{QUERY_STRING_UNESCAPED} =~ /^([a-z]+)?_?(\d+)?$/ );

my $mode = Local::Subs::DEFAULT(${{ qstat => 0, condorq => 1 }}{$tmod},0); (defined $dtim) || ($dtim = (time - 300)); my $ltim = ( $dtim - ($dtim % 300));

print '<h2>The '.(( qw( TORQUE Condor))[$mode]).' Queue WayBack Machine</h2>'."\n".'<p>'."\n";

my (%idex,@nams); if ($mode == 0) {
	my (@ques) = ( grep { (length) } map { split /[,\s]+/ } ${ Local::Subs::CONFIG_MODULES('QSTAT_DATA') || {}}{'QUEUES'} );
	my ($nick) = map { scalar { map { m/^([a-z]+)\s*:\s*([\w\s\.-]+)$/i ? (qq($1),(uc $2)) : () }
        	( split /\s*,\s*/, $_ ) }} ${ Local::Subs::CONFIG_MODULES('QSTAT_DATA') || {}}{'NAMES'};
	(%idex) = map {( $ques[$_] => $_ )} (0..(@ques-1)); (@nams) = map { (length $$nick{$_}) ? ($$nick{$_}) : (uc) } (@ques); }

print Local::Subs::QUEUE_TABLE($mode,$ltim,(($mode == 0) ? (undef,\%idex,\@nams,undef) : ()));

print '<br>'."\n".'View <a href="wayback.'.($html).'?'.(( qw( condorq qstat))[$mode]).'_'.($ltim) .
	'" class="mon_default" target="WAYBACK">'.(( qw( Condor TORQUE))[$mode]).'</a> Queue'."\n".'<br>'."\n";

1;

