#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($bckg) = m/\b(?:bg|background)\b/i;

my ($task) = q(condorq);

system( 'rm '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt > /dev/null 2>&1' );

Local::Subs::BACKGROUND_SELF() if ($bckg);

my ($sshh) = join '', map { q( ').($_).q(') } map { /^(.*?):?(\d*)$/ } (( split /\s+/, ${ Local::Subs::CONFIG_MODULES('CONDORQ_DATA') || {}}{'SSH'} ), undef )[0];
my ($cmmd) = map { q( ').($_).q(') } map { (length) ? do { /(?:^|\/)condor_q$/ && !(/\s/) or die 'Invalid condor_q executable path'; $_ } : q(condor_q) }
        ${ Local::Subs::CONFIG_MODULES('CONDORQ_DATA') || {}}{'COMMAND'};

system( BASE_PATH.CGI_PATH.'/_Shell/'.($task).'.sh'.($sshh.$cmmd).' > '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' );

# 0:ClusterId 1:ProcId 2:Owner 3:JobUniverse 4:JobStatus 5:RequestCpus 6:ImageSize
# 7:RemoteUserCpu 8:RemoteSysCpu 9:RemoteWallClockTime 10:CumulativeSuspensionTime 11:QDate 12:CompletionDate
# =>
# 0:Job_ID 1:Owner 2:Universe 3:Status 4:CPUs 5:Memory 6:CPU_Time 7:Run_Time 8:Init_Time 9:Complete_Time

my ($data) = Local::Subs::LOAD_DATA($task) || exit;

( my ($dtim) = map { my ($t) = Local::Subs::TAKE_FIVE($_); ($t > Local::Subs::TIME_STAMP(q(CONDORQ_DATA),$t)) ? $t : () }
	grep { /^\d+$/ } ${ $$data{CONDORQ_TIME}}[0][0] ) or exit;

open FHO, '>', BASE_PATH.MON_PATH.'/LOGS/CONDORQ_DATA/'.($dtim).'.dat'; select FHO;
print q().( join "\t", @$_ )."\n" for grep {(@$_ == 10)} map {[
	($$_[0] =~ /^\d+$/ && $$_[1] =~ /^\d+$/ ? ($$_[0]).q(:).($$_[1]) : ()),
	((length $$_[2]) ? $$_[2] : ()),
	($$_[3] =~ /^(\d+)$/ && ($1>=0) && ($1<=14) ? 0+$1 : ()),
	($$_[4] =~ /^(\d+)$/ && ($1>=0) && ($1<=6) ? 0+$1 : ()),
	($$_[5] =~ /^(\d+)$/ ? 0+$1 : ()),
	($$_[6] =~ /^(\d+)$/ ? $1*1024 : ()),
	($$_[9] =~ /^\d+$/ && $$_[10] =~ /^\d+$/ ? $$_[9]-$$_[10] : ()),
	($$_[7] =~ /^\d+$/ && $$_[8] =~ /^\d+$/ ? $$_[7]+$$_[8] : ()),
	($$_[11] =~ /^(\d+)$/ ? 0+$1 : ()),
	($$_[12] =~ /^(\d+)$/ ? 0+$1 : ()),
	]} @{ $$data{CONDORQ}}; close FHO;

my (%stll); open FHO, '>', BASE_PATH.HTML_PATH.'/SSI/TABLES/'.($task).'_data.ssi'; print FHO Local::Subs::QUEUE_TABLE(1,$dtim,\%stll); close FHO;


Local::Subs::ALERT( q(CONDOR_STALL),@$_) for map { (0+@$_) ? (@$_ == 1) ? [2,1,$$_[0]] : [4,1,q(MULTIPLE)] : [0] } [ keys %stll ];

1

