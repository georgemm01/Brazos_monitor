#!/usr/bin/perl

package Local::Path;

use strict;

use constant {
	BASE_PATH	=> '/home/hepxmon',
	PERL_PATH	=> '/perl5',
	PERL_LIB_PATH	=> '/perl5/lib/perl5',
	LOCAL_PATH	=> '/local',
	MON_PATH	=> '/mon',
	HTML_PATH	=> '/public_html/mon',
	CGI_PATH	=> '/public_html/cgi-bin/mon',
	};

use lib BASE_PATH.PERL_LIB_PATH; use local::lib BASE_PATH.PERL_PATH;

use Exporter;

use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

@ISA = qw(Exporter);

@EXPORT = ();

@EXPORT_OK = qw( BASE_PATH PERL_PATH PERL_LIB_PATH LOCAL_PATH MON_PATH HTML_PATH CGI_PATH );

%EXPORT_TAGS = ( all => \@EXPORT_OK );

1

