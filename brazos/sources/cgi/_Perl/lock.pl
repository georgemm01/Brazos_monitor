#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my $mode = (shift @ARGV);

my ($lock) = grep { (ref) || (die $_) } &LOCK_SELF($mode);

sub LOCK_SELF {
	my ($mode,$trys,$napt) = map {(int)} (@_); my ($path,$name,$rpid) = (BASE_PATH.MON_PATH.q(/LOCKS/),qq($0),qq($$));
        $mode = 0+(0..3)[$mode]; $trys = (($mode%2) ? -1 : Local::Subs::MAX(1,$trys)); $napt = Local::Subs::MAX(1,$napt);
	$name =~ s/^.*\///; $name .= q(.lock); my ($excl) = ($mode<2); package Local::Subs::LOCK; sub DESTROY { eval { (shift)->(1) }}
        while ($trys) { (next) if ((-e $path.q(EXCLUSIVE/).$name) or (($excl) && (-s $path.q(SHARED/).$name)));
                ($excl) ? system(q(touch ).$path.q(EXCLUSIVE/).$name) : system(q(echo ).$rpid.q( >> ).$path.q(SHARED/).$name);
                return bless sub { ($excl) ? unlink($path.q(EXCLUSIVE/).$name) : system(q(sed -i '/^).$rpid.q($/d' ).$path.q(SHARED/).$name) }}
        continue { --$trys && sleep($napt) } q(1: Error Opening Self ... Exiting)."\n\t".q(* May need to delete lockfiles in ).$path." *\n\t" }
# INPUT: MODE, TRYS, NAPTIME
# MODE 0: Exclusive, Non-Blocking
# MODE 1: Exclusive, Blocking
# MODE 2: Shared, Non-Blocking
# MODE 3: Shared, Blocking

print "LOCKED\n";
sleep 10;
print "DONE\n";

