#!/usr/bin/perl

package Local::Path;

use strict;

use constant {
	BASE_PATH	=> '<[0]>',
	PERL_PATH	=> '<[1]>',
	PERL_LIB_PATH	=> '<[2]>',
	LOCAL_PATH	=> '<[3]>',
	MON_PATH	=> '<[4]>',
	HTML_PATH	=> '<[5]>',
	CGI_PATH	=> '<[6]>',
	};

use lib BASE_PATH.PERL_LIB_PATH; use local::lib BASE_PATH.PERL_PATH;

use Exporter;

use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

@ISA = qw(Exporter);

@EXPORT = ();

@EXPORT_OK = qw( BASE_PATH PERL_PATH PERL_LIB_PATH LOCAL_PATH MON_PATH HTML_PATH CGI_PATH );

%EXPORT_TAGS = ( all => \@EXPORT_OK );

1

