#!/usr/bin/perl

package Local::TimeShift;

use strict;

use constant {
	TIME_SHIFT	=> <[0]>,
	};

use Exporter;

use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );

@ISA = qw(Exporter);

@EXPORT = ();

@EXPORT_OK = qw( TIME_SHIFT );

%EXPORT_TAGS = ( all => \@EXPORT_OK );

1

