#!/usr/bin/perl

# crontab
# * * * * * . ${HOME}/.bashrc && ${BRAZOS_BASE_PATH}${BRAZOS_CGI_PATH}/_Perl/brazos.pl > /dev/null 2>&1

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::TimeShift qw(:all);

use Local::Subs ();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($all) = m/\ball\b/i;

my ($mins) = Local::Subs::ROUND(( time + TIME_SHIFT )/(60),0);

my ($mods) = Local::Subs::CONFIG_MODULES();

my (%cmds); my (@cmds) = grep { !${{ upgrade => 1 }}{$$_[0]}} grep { $cmds{$$_[0]}++; 1 } map { my ($cmmd) = (shift @$_);
	map {[ $cmmd, (shift @$_) ]} ( grep { ($all) or ($$_[2]) && !(($mins+$$_[1])%($$_[2])) } (@$_))[0] } grep { $$mods{(uc $$_[0])}{'ACTIVE'}} (
		[ q(upgrade), [q(),10,6*60]],
		[ q(transfer_plot), [q(all),0,0], [q(week),45,24*60], [q(day),15,6*60], [q(),5,30]],
		[ q(transfer_data), [q(),5,30]],
		[ q(subscription_plot), [q(all),0,0], [q(week),50,24*60], [q(day),20,6*60], [q(),5,30]],
		[ q(subscription_data), [q(),5,30]],
		[ q(job_plot), [q(all),0,0], [q(week),55,24*60], [q(day),25,6*60], [q(),5,30]],
		[ q(sam_plot), [q(),5,30]],
		[ q(user_jobs_plot_data), [q(all),0,0], [q(week),30,6*60], [q(),5,30]],
		[ q(cats_data), [q(),5,30]],
		[ q(heartbeat_data), [q(),0,5]],
		[ q(load_data), [q(),0,5]],
		[ q(queue_data), [q(),0,5]],
#		[ q(disk_usage_data), [q(all bg),40-9*60,24*60], [q(bg),40,3*60]],
		[ q(disk_usage_data), [q(fast),35,20], [q(bg),40,3*60]],
##replacing qstat_data with this squeue module instead!!! Jun '16, KC
		[ q(squeue_hepxjobs_data), [q(),0,5]],
		#[ q(qstat_data), [q(),0,5]],
		[ q(condorq_data), [q(),0,5]],
		[ q(clean_logs), [q(),30,24*60]],
	);

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF( $cmds{'upgrade'} ? 1 : 2 );

my (@subp); for (@cmds) { my ($pid) = fork();
	if ($pid) { push @subp, $pid; }
	elsif ($pid == 0) { system( BASE_PATH.CGI_PATH.'/_Perl/'.($$_[0]).'.pl', $$_[1], $log && 'log' ); exit(0); }
	else { die "couldn't fork: $!\n"; }} for (@subp) { waitpid($_,0); }

my (@prst) = map { ( open FHI, '<', BASE_PATH.MON_PATH.'/PERSIST/'.($_).'.dat' ) ?
	[ map { close FHI; chomp; split /\t/ } ( scalar <FHI> )] : undef } ( qw(
		disk_usage_net disk_usage_phedex_local disk_usage_phedex_resident
		disk_usage_phedex_subscribed transfer_rate_prod_hourly ));

if ($cmds{'disk_usage_data'}) { my ($qota) = map { ($_)*(1024**4) } grep {(length)} ${ Local::Subs::CONFIG_MODULES('DISK_USAGE_DATA') || {}}{'QUOTA'};
		Local::Subs::ALERT(q(DISK_QUOTA),( shift @$_),1,( map { Local::Subs::DATA_FORMAT_BYTES_HUMAN(int,1) } @$_[0,1] )) for
			map { [( map { (($_>1.20)?4:($_>1.00)?3:($_>1.00)?2:($_>1.00)?1:0) } ($_/$qota))[0],$_,$qota] }
			map {($$_[1])} grep { (defined) && (defined $qota) } $prst[0];
			# [( map { (($_>1.20)?4:($_>1.00)?3:($_>0.95)?2:($_>0.90)?1:0) }

	Local::Subs::ALERT(q(PHDX_MISMATCH),@$_) for map { (($$_[0] != $$_[1]) && (!($$_[0]) || (( abs (1-($$_[1]/$$_[0]))) > 0.05) || (( abs ($$_[1]-$$_[0])) > 500*(1024)**3))) ?
		[2,1,( map { Local::Subs::DATA_FORMAT_BYTES_HUMAN(int,1) } @$_[0,1] )] : [0] } grep {(@$_==2)} [ map {($$_[1])} grep {(defined)} @prst[1,2]]; }

if ($cmds{'transfer_data'} || $cmds{'subscription_data'}) {
	Local::Subs::ALERT(q(PHDX_TRANSFER),@$_) for map { (($$_[2] < 10*(1024)**2) && (($$_[1]-$$_[0]) > 10*(1024)**3) && (!($$_[0]) || ((($$_[1]/$$_[0])-1) > 0.05))) ?
		[2,1,( map { Local::Subs::DATA_FORMAT_BYTES_HUMAN(int,1) } @$_[0..2] )] : [0] } grep {(@$_==3)} [ map {($$_[1])} grep {(defined)} @prst[2..4]]; }

system( BASE_PATH.CGI_PATH.'/_Perl/refresh_users.pl', $log && 'log' ) if (($all) or !(($mins+10)%(4*60)));

system( BASE_PATH.CGI_PATH.'/_Perl/refresh_index.pl', $log && 'log' ) if (@cmds);

system( BASE_PATH.CGI_PATH.'/_Perl/upgrade.pl', $log && 'log' ) if ($cmds{'upgrade'});

1

