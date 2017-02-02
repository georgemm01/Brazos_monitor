#!/usr/bin/perl

use strict;

use FindBin (); use lib $FindBin::RealBin.'/..';

use Local::Path qw(:all);

use Local::Subs ();

use POSIX ();

my ($lock) = grep { (ref) || (die $_) } Local::Subs::LOCK_SELF();

local ($_) = "@ARGV"; my ($log) = m/\blog\b/i; my ($bckg) = m/\b(?:bg|background)\b/i; my ($isod) = m/\b(?:iso|isolated|all)\b/i; my ($fast) = m/\b(?:fast)\b/i;

($isod = !1) if ($fast); # turning off "du" for user directories and replacing with "fast" query of .csv files in /tmp ... NOT generalized for off-site use

my ($task) = q(disk_usage);

system( 'rm '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'*_data.txt > /dev/null 2>&1' ) if ($isod);

Local::Subs::BACKGROUND_SELF() if ($bckg);

my ($sshh) = map { (length $$_[0]) ? q(ssh ).($$_[0]).q( ).((length $$_[1]) ? q(-p ).$$_[1].q( ) : q()) : q() } map {[ /^(.*?):?(\d*)$/ ]}
	(( split /\s+/, ${ Local::Subs::CONFIG_MODULES('DISK_USAGE_DATA') || {}}{'SSH'} ), undef )[0];
my ($cmmd) = map { (length) ? do { /(?:^|\/)du$/ && !(/\s/) or die 'Invalid du executable path'; $_ } : q(du) }
        ${ Local::Subs::CONFIG_MODULES('DISK_USAGE_DATA') || {}}{'COMMAND'};
my ($ddir) = grep {(length) || die 'Invalid Data Directory' } grep { s/\/+$//; 1 }
	(( split /\s+/, ${ Local::Subs::CONFIG_MODULES('DISK_USAGE_DATA') || {}}{'DATA_DIR'} ), undef )[0];
my (@isod) = ( map { '/'.$_ } grep {(length)} grep { s/[^\w]//g; 1 } split /[\s,]+/, ${ Local::Subs::CONFIG_MODULES('DISK_USAGE_DATA') || {}}{'ISOLATE'} );

my ($ntim,$dlay) = (600,0); while ( &DELAY()) { sleep $ntim; $dlay++; };

	for (($fast) ? () : ((($isod && @isod) ? @isod : ()), \@isod )) {

my ($line); my ($time,$stim) = map {( $_, POSIX::strftime('%A, %d-%b-%Y %H:%M:%S %Z', localtime($_)) )} (time);
my $ddir = $ddir.( grep {!(ref)} ($_))[0];
my $task = $task.( grep { s/\//_/g; 1 } map { (ref) ? () : qq($_) } ($_))[0];
my (@excl) = (ref) ? @$_ : ();

system( 'rm '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt > /dev/null 2>&1' );

$line .= '<!DU!>'."\n";

$line .= `${\( '/usr/bin/time -f "DU_TIME\t%E\t%P\t%F\t%W" -o '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_time.txt ' .
	($sshh.$cmmd).( join '', map { ' --exclude='.$ddir.$_ } (@excl)).' --one-file-system --max-depth=2 ' .
	'--time --time-style=+%s '.($ddir).' 2> '.BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_errors.txt' )}`;

$line .= '<!DU_DENIED!>'."\n";

$line .= join q(), map { $_."\n" } map { my (%dend) = map {( $_ => 1 )} @$_; sort keys %dend } [
	map { m/(?:cannot read directory|du:) `${ddir}((?:\/[^\/']+){1,2})[^']*': Permission denied/g }
	(( open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_errors.txt' ) ?
		@{ ([ grep { chomp; 1 } <FHI> ], ( close FHI ))[0] } : ()) ];

$line .= '<!DU_ERRORS!>'."\n";

$line .= (0+@$_)."\n" for [ grep { /Input\/output error/ }
        (( open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_errors.txt' ) ?
                @{ ([ grep { chomp; 1 } <FHI> ], ( close FHI ))[0] } : ()) ];

$line .= '<!DU_DELAY!>'."\n";

$line .= ($dlay*$ntim)."\n";

$line .= '<!DU_TIME!>'."\n";
#Stamp  Wall    %CPU    Faults  Swaps

$line .= $_ for map { ( join "\t", ($time,@$_[0..3]))."\n" }
	grep { ( open FHO, '>>', BASE_PATH.MON_PATH.'/LOGS/DISK_USAGE_DATA/time_'.($task).'.txt' ) &&
		( print FHO q().( join "\t", ($time,@$_[0..3],$stim))."\n" ) && ( close FHO ); 1 }
	(( open FHI, BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_time.txt' ) ? ([ map { chomp;
	(( split "\t" ), undef )[0..3] } ( grep { s/^DU_TIME\t//; } <FHI> )[0]], ( close FHI ))[0] : ());

$line .= '<!DU_QUERY!>'."\n";

$line .= ($cmmd).( join '', map { ' --exclude='.$ddir.$_ } (@excl)).' --one-file-system --max-depth=2 --time --time-style=+%s '.($ddir)."\n";

#$line .= '<!DF!>'."\n";

#$line .= `df`;

$line .= '<!NULL!>'."\n";

open FHO, '>', BASE_PATH.MON_PATH.'/DOWNLOAD/'.($task).'_data.txt' or die 'Cannot Open File ... Exiting';

print FHO $line;

close FHO;

	}

sub DELAY {
#	my ($data) = Local::Subs::LOAD_DATA([ map { m/^(.*)$/mg } `${\( BASE_PATH.CGI_PATH.'/_Perl/report_load_data.pl spool' )}` ]) || exit;
#	( return 1 ) unless ( 3 == ( my ($lqur,$lgfs,$lgfp) = grep {(defined)}
#		@$data{ qw( LOAD_QUEUE_UTILIZATION LOAD_GLUSTERFS LOAD_GRIDFTP_PROCESSES )} ));
#	((( &SUM(@{ $$lqur[0]}[2,3],@{ $$lqur[1]}[2,3]))/( &SUM($$lqur[0][1],$$lqur[1][1]) || 1 )) > 1.25) ||
#	($$lgfs[0][0] > 80) ||
#	($$lgfp[0][0] > 8) and return 1;
	0 }

my ($data) = Local::Subs::LOAD_DATA($task) || exit;

if (1) { # VERY LOCAL TAMU ONLY BEHAVIOR
my $dir = '/fdata/hepx/store/user';
my (%users) = map { $_ => 1 } ( split "\n", `ls -1 $dir` );
open FHI, '/tmp/beegfs_userspace.csv';
my ($sum); while (<FHI>) { chomp;
	my ($uid,$usr,$kib) = split /,/;
	next unless $users{$usr};
	$kib = Local::Subs::ROUND($kib/1024,0);
	push @{$$data{DU}}, [$kib,0,$dir.'/'.$usr];
	$sum += $kib;
	} close FHI; push @{$$data{DU}}, [$sum,0,$dir]; }
else { ( opendir DHI, BASE_PATH.MON_PATH.'/DOWNLOAD' ) || (exit);
	do { my ($t) = $_; for ( qw( DU DU_DENIED DU_QUERY )) { unshift @{ $$data{$_}}, @{ $$t{$_}} }; ${ $$data{DU_ERRORS}}[0][0] += ${ $$t{DU_ERRORS}}[0][0]; }
	for map { scalar Local::Subs::LOAD_DATA($_) || exit } map { /^(${task}_\w+)_data\.txt$/ } (readdir DHI); closedir DHI; };

( my ($dtim) = map { my ($t) = Local::Subs::TAKE_FIVE($_); ($t > Local::Subs::TIME_STAMP(q(DISK_USAGE_DATA),$t)) ? $t : () }
	map { Local::Subs::SUM(@$_) } grep { 0+( grep { /^\d+$/ } @$_ ) == 2 } [ ${ $$data{DU_TIME}}[0][0], ${ $$data{DU_DELAY}}[0][0]] ) or exit; 

my ($du,$phdx,$dutot,$stmptot) = [undef,undef,{}]; do { my ($path,$byte,$stmp,@path) = ($du,@$_);
	if (@path == 2) { $dutot += $byte; $stmptot = Local::Subs::MAX($stmp,$stmptot); } while (@path) {
	$path = ${ $$path[2] }{ shift @path } ||= [undef,undef,{}] }; $$path[0] += $byte; $$path[1] = Local::Subs::MAX($stmp,$$path[1]); } for
	map {[ 1024*$$_[0], $$_[1], (length $$_[2]) ? ( map { my ($pat1,$pat2) = @{ ${{
		mc			=> [ q(PhEDEx Monte Carlo) ],
		data			=> [ q(PhEDEx CMS Data) ],
		PhEDEx_LoadTest07	=> [ q(PhEDEx Load Tests), sub { $_[0] =~ /^LoadTest07_Debug_(.+)$/ ? $1 : $_[0] } ],
		user			=> [ q(User Output), \&Local::Subs::LOCAL_USER_NAME ]
	}}{$$_[0]} || do { unshift @$_, undef; [ (length $$_[2]) ? q(Null) : q(Miscellaneous) ]}};
	( $pat1, (length $$_[1]) ? &{ $pat2 || sub { ucfirst(lc(shift)) }}($$_[1]) : ()) } [( split '/', $$_[2])[1,2]] ) : () ]}
	grep {(@$_==3)} map {[ $$_[0] =~ /^(\d+)$/, $$_[1] =~ /^(\d+)$/, $$_[2] =~ /^${ddir}((?:\/[^\/]+){0,2})$/ ]} @{ $$data{DU}};

my (@alrt); do { push @alrt, q(Failure Invoking "DU" as:).( join q([BR][TAB]), ((@{ $$data{DU_QUERY}} > 1) ? ((undef), map { $$_[0] } @{ $$data{DU_QUERY}}) : ' '.${ $$data{DU_QUERY}}[0][0])) if
	(!(0+@{ $$data{DU}}) or 0+@$_); push @alrt, map { qq($_) } @$_; } for [
#	( map { !(length) ? q(Could Not Establish "DU" Page Fault Status) : ($_ > 0) ? q(Experienced ).(($_>1)?($_) .
#		q( Major Page Faults):q(A Major Page Fault)).q( During "DU" Query) : () } ${ $$data{DU_TIME}}[0][3]),
	( map { !(length) ? q(Could Not Establish "DU" I/O Error Status) : ($_ > 0) ? q(Experienced ).(($_>1)?($_) .
		q( Input/Output Errors):q(An Input/Output Error)).q( During "DU" Query) : () } ${ $$data{DU_ERRORS}}[0][0]),
	( map { !(defined) ? q(Could Not Establish "DU" Run Time) : ($_ > 30*60) ? q(Excessive "DU" Run Time of ) .
		( Local::Subs::TIME_FORMAT_SECONDS_MINUTES($_,1)).q( Minutes - Less Than 5 Expected) : () }
		Local::Subs::TIME_FORMAT_MINUTES_SECONDS( ${ $$data{DU_TIME}}[0][1])),
	( map { q(Delayed "DU" Run for ).( Local::Subs::TIME_FORMAT_SECONDS_MINUTES($_,1)).q( Minutes Due to Heavy Cluster Load) }
		grep {($_ > 18*600)} 0+${ $$data{DU_DELAY}}[0][0]) ];

Local::Subs::ALERT( q(GRAB_DU),((0+@alrt) ? (2,1,( join q([BR]* ), ((undef),@alrt))) : (0)));

open FHO, '>', BASE_PATH.HTML_PATH.'/SSI/TABLES/'.($task).'_data.ssi'; select FHO;
print '<DIV id="disk_usage_data_anchor" style="z-index:0; display:block; position:static; height:auto; width:550px; margin:0px 138px; padding:0px; text-align:center; overflow:hidden;">'."\n";
print "\t".'<table class="mon_default" style="height:auto; width:550px;">'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF;">'."\n";
print "\t\t\t".'<td colspan="3" class="mon_default" style="width:534px; height:16px;">HEPX Disk Store Usage &nbsp; &nbsp( '.(
	Local::Subs::DATE_FORMAT(($dtim),0,q(%Y-%m-%d %R CST))).' )</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
print "\t\t\t".'<td class="mon_default" style="width:166px; height:16px;">Directory</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Bytes</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">Percent</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:174px; height:16px;">Date Modified</td>'."\n";
print "\t\t".'</tr>'."\n";
my ($i) = 0; for my $dirg ( q(PhEDEx Monte Carlo), q(PhEDEx CMS Data), q(PhEDEx Load Tests), q(User Output), q(Miscellaneous)) { my ($path) = $$du[2]{$dirg} || [undef,undef,{}];
	my ($bsum,$smax,$tbit) = map { my ($j,$bsum,$smax) = ( 0, 0+( Local::Subs::SUM( map {0+($$_[1])} (@$_))), 0+( Local::Subs::MAX( map {0+($$_[2])} (@$_)))); ( $bsum, $smax, ( join '', map {
		"\t\t".'<tr class="mon_default" id="disk_usage_data_element_'.$i.'_'.$j.'" style="display:none; color:black; background-color:#'.(( qw( E9FBFA B3F3F0 ))[($j++)%2]).';">'."\n" .
		"\t\t\t".'<td class="mon_default" style="width:166px; height:16px;">'.$$_[0].'</td>'."\n" .
		"\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">'.( Local::Subs::DATA_FORMAT_BYTES_HUMAN(0+$$_[1],1)).'</td>'."\n" .
		"\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">'.(( map {((defined) ? ( Local::Subs::DEFAULT( Local::Subs::ROUND(100*$_,1,1),q(0.0))).q( &#37;) : q(-))} Local::Subs::SAFE_RATIO($$_[1],$bsum))[0]).'</td>'."\n" .
		"\t\t\t".'<td class="mon_default" style="width:174px; height:16px;">'.(($$_[2]) ? Local::Subs::DATE_FORMAT($$_[2],1,q(%Y-%m-%d %R UTC)) : q(NA)).'</td>'."\n" .
		"\t\t".'</tr>'."\n" } (@$_))) } [ sort {( $$b[1] <=> $$a[1] )} map {[ $_, @{ $$path[2]{$_}}[0,1]]} (keys %{ $$path[2]}) ];
	print "\t\t".'<tr class="mon_default" id="disk_usage_data_select_'.$i.'" style="display:block; color:black; background-color:#30CCAA; cursor:pointer;" onClick="javascript:DiskUsageDataToggle('.$i.');" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:this.style.backgroundColor=\'#30CCAA\';">'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:166px; height:16px; color:inherit; background-color:transparent;">'."\n";
	print "\t\t\t\t".'<DIV style="position:relative; left:0px; top:0px; width:166px; height:16px; padding:0px; display:block;">'.$dirg."\n";
	print "\t\t\t\t\t".'<DIV id="disk_usage_data_indicator_'.$i.'_0" style="position:absolute; top:-2px; left:0px; display:block;">&rarr;</DIV>'."\n";
	print "\t\t\t\t\t".'<DIV id="disk_usage_data_indicator_'.$i.'_1" style="position:absolute; top:-2px; left:0px; display:none;">&darr;</DIV>'."\n";
	print "\t\t\t\t".'</DIV>'."\n";
	print "\t\t\t".'</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px; color:inherit; background-color:transparent;">' .
		( Local::Subs::DATA_FORMAT_BYTES_HUMAN(( grep { ($phdx += $_) if (($dirg =~ /^PhEDEx/) && ($dirg !~ /Load/)); 1 } ($bsum))[0],1)).'</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px; color:inherit; background-color:transparent;">' .
		(( map {((defined) ? ( Local::Subs::DEFAULT( Local::Subs::ROUND(100*$_,1,1),q(0.0))).q( &#37;) : q(-))} Local::Subs::SAFE_RATIO($bsum,$dutot))[0]).'</td>'."\n";
	print "\t\t\t".'<td class="mon_default" style="width:174px; height:16px; color:inherit; background-color:transparent;">' .
		(($smax) ? Local::Subs::DATE_FORMAT($smax,1,q(%Y-%m-%d %R UTC)) : q(NA)).'</td>'."\n";
	print "\t\t".'</tr>'."\n";
	print $tbit; } continue { $i++; }
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#20B2AA;">'."\n";
print "\t\t\t".'<td class="mon_default" style="width:166px; height:16px;">Total</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">'.( Local::Subs::DATA_FORMAT_BYTES_HUMAN( 0+$dutot, 1 )).'</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:82px; height:16px;">'.(($dutot)?'100.0 &#37;':'-').'</td>'."\n";
print "\t\t\t".'<td class="mon_default" style="width:174px; height:16px;">'.( Local::Subs::DATE_FORMAT($stmptot,1,q(%Y-%m-%d %R UTC))).'</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t\t".'<tr class="mon_default" style="display:block; color:black; background-color:#FFFFFF; cursor:pointer;" onClick="javascript:DiskUsageDataToggleAll();" onMouseOver="javascript:this.style.backgroundColor=\'#3BB9FF\';" onMouseOut="javascript:this.style.backgroundColor=\'#FFFFFF\';">'."\n";
print "\t\t\t".'<td colspan="3" class="mon_default" style="width:534px; height:16px; color:inherit; background-color:transparent;">&uarr; Click to Expand or Collapse Table</td>'."\n";
print "\t\t".'</tr>'."\n";
print "\t".'</table>'."\n";
print '</DIV>'."\n";
close FHO;

open FHO, '>', BASE_PATH.MON_PATH.'/PERSIST/'.($task).'_phedex_local.dat'; print FHO q().($dtim)."\t".($phdx)."\n"; close FHO;
open FHO, '>', BASE_PATH.MON_PATH.'/PERSIST/'.($task).'_net.dat'; print FHO q().($dtim)."\t".(0+$dutot)."\n"; close FHO;

Local::Subs::ALERT( q(DISK_DENIED),((0+@$_) ? (2,1,( join ', ', @$_)) : (0))) for [ map { $$_[0] } @{ $$data{DU_DENIED}} ];

1

