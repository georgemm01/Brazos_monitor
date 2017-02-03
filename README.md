
# Brazos Copy of the CMS Tier3 Site Monitor 

The [Mithcell Institute Computing](http://mitchcomp.physics.tamu.edu/) through the [Brazos Cluster](http://brazos.tamu.edu/) provides computing resources to the [Mitchell Institute for Fundamental Physics and Astronomy](http://mitchell.tamu.edu/), at the [Texas A&M University](http://www.tamu.edu/).  This monitor is a most useful tool to make sure that our high throughput cluster is working efficiently, you can see it live here: (http://hepx.brazos.tamu.edu/)[http://hepx.brazos.tamu.edu/], and you can see some status and history notes [here](http://mitchcomp.physics.tamu.edu/status_perf/status_perf.php). 


#### Source code by Joel W. Walker, updated and adapted by Jorge D. Morales

For problems regarding adaptions to the Brazos Cluster contact Jorge D. Morales (via gitHub)

For installing in Brazos: 

1. Make sure that the account hosting the monitor has a public_html directory that is broadcasting to the web.

2. Make a direcotry in public_html named cgi-bin:   
	```
	$ mkdir ~/public_html/cgi-bin
	```

3. Clone this repository in your home area:   
	```
	$ git clone https://github.com/georgemm01/Brazos_monitor.git
	```

4. Copy the brazos directory in your home area:  
	```
	$ cp ~/Brazos_monitor/brazos ~/.
	```

5. Go to the brazos directory and run the configuration script. It should detect the locations of public_html and cgi-bin, just acknowledge with *Y*:  
	```
	$ cd ~/brazos
	$ ./configure.pl
	```

6. Compile the libraries and the monitor (this should just work painlessly by fetching the PERL libraries with cpan):
	```
	$ make
	```

7. It's set up! Now double check your configuration files, go to the CONFIG area and view/edit them:
	``` 
	$ cd ~/mon/CONFIG
	$ ls 
	```

8. Once you are happy with the configs, test your monitor. Go to the _Perl scripts location_, and run it:  
	```
	$ cd ~/public_html/cgi-bin/mon/_Perl
	$ ./brazos.pl -all 
	```

9. If you are setting it up to be running continously, then set up your crontab to execute it as frequently as desired: 
	``` 
	$ crontab -e
	## Then add and save the following: 
	* * * * * . ${HOME}/.bashrc && ${BRAZOS_BASE_PATH}${BRAZOS_CGI_PATH}/_Perl/brazos.pl > /dev/null 2>&1
	```

If you wish to update or fix any features, first make a copy of your own. Then install it and fix the problems. Once you are happy, checkout a development branch, push in your changes/updates, and create a merge/pull request so that they are verified and propagated to **master**. 


___

### The orginal README file from the source: 

Thanks for your interest in installing "Brazos", the CMS Tier 3 Site Monitor!

If you have any questions, requests or suggestions please email Joel Walker: jwalker@shsu.edu

If you have any comments that may be helpful or interesting to the larger community, please email
the Tier 3 list: hn-cms-osg-tier3@cern.ch or the Monitoring list: hn-cms-comp-monitoring@cern.ch

All files required for installation are bundled for delivery as a tar-gzip file (brazos.tgz)

The main source repository is maintained for download at the author's personal website:
	http://joelwalker.net/code/brazos/brazos.tgz

A presentation on the monitoring software is viewable here:
	http://www.joelwalker.net/talks/LHC_Monitoring.pdf

The prototype monitoring installation at Texas A&M is viewable here:
	http://brazos.tamu.edu/~ext-jww004/mon/

There are several prerequisites that should be in place for proper installation and functioning:

	- A clean account on the host cluster - we suggest "brazos" as the username
	- Allocation of ~ 2 GB disk capacity quota
	- Allocation of ~ 100,000+ filename inode quota
	- Linux shell: /bin/sh & /bin/bash
	- Apache web server with SSI enabled for .html or .shtml (or available via .htaccess)
	- An HTML document root directory that publishes to the web (e.g. ~/public_html or ~/httpdocs)
	- Perl and a CGI-BIN script alias web directory (e.g. ~/public_html/cgi-bin)
	- Standard build tools, e.g. make, cpan, gcc
	- Access to web via lwp-download, curl or wget, etc.
	- Group member access to common CMS data disk partition
	- Job scheduling via crontab


The tar-zipped distribution that you have now unpacked should have created a single directory "brazos"
holding all the files essential to installing the Brazos monitor, including this README file.

You should have unpacked the brazos.tgz package directly in the home directory "~" of the user
account that will be running this software, while logged in as that user (not root).  Note that there
are specific consequences for file permissions when a tar archive is unpacked as the root user,
and one must "rm -rf brazos" and start over if this is the case.  If the unpacked /brazos directory is
not currently at the base of the monitoring user's home directory (use "ls ~/brazos" to verify),
it must be moved there "mv brazos ~/" before proceeding.

To Install:

	- Navigate "cd ~/brazos" into the monitoring distribution directory.
	- Run the configuration script "./configure.pl" and answer the required questions
	- Run make to locally install libraries and system files "make"
	- Re-enter the shell to source the new environment "exec bash"


The above steps should be all that is required to establish a minimal monitoring installation.
However, it is likely that unanticipated system configurations will sometimes break this
processing chain.  In particular, the make procedure is quite complex.  As it is running
(this can take some time) updates on the status will be posted to your terminal.  If the
process terminates abnormally, please send the reported error and its surrounding context
by email to Joel Walker (jwalker@shsu.edu).  Even (and especially) if you are ultimately able
to resolve the error, this will greatly assist improvement of the distribution package.

Please use a web browser to navigate to the document root to test if the monitor is viewable.
If you see a 505 server error, try adjusting the .htaccess file or try loading the .shtml
page versions.  If the .shtml pages are configured on your system to utilize server side
includes, you will need to indicate this in the ~/mon/CONFIG/local.txt file.  This is a good
time to go ahead and edit the rest of the configuration in that file to reflect your own
installation.  No detailed documentation yet exists for this process, although the provided
examples may be a sufficient guide.  You can refresh the page rendering (including the selected
document extension) by executing the script ${HOME}${BRAZOS_CGI_PATH}/_Perl/refresh_index.pl .

Note that the prior step does not actually regenerate the individual items of content.  For this
purpose, you may execute any of the modular scripts in the _Perl directory directly, or run
"./brazos.pl all" to invoke all scripts simultaneously.  In parallel, you will need to configure
the operation of the individual data harvesting modules by editing the file ~/mon/CONFIG/local.txt .
The files users.txt and alert.txt in the same directory allow you to add Human name substitutions
for your local users and to tailor (or individually disable) operation of the email alerts.  It is
also possible to add or remove email recipients for individual alerts.

Most of the monitoring modules are designed to be reasonably adaptable to your local environment.
Those modules dedicated to harvesting CMS Dashboard and PhEDEx data should naturally be the
most readily generalizable, while modules designed for monitoring of the local cluster are
more likely to be susceptible to system variations.  In particular, the CATS_DATA module
will not function "out of the box" as it is employed at Texas A&M.  This module currently
requires the separate submission of batches of best-practice compliant jobs from a member of
your physics group, whereas the monitor collects and reports the outcome of those processes.
Thus, you may initially wish to set this module to "<ACTIVE=FALSE>".  Please contact
Joel Walker (jwalker@shsu.edu) if you interested in a copy of our automated "CATS" test jobs
CRAB submission scripts.

Once your data downloads have been tested and your preferred configuration of active modules
is established, it is time to register the monitor with the crontab job scheduler.
The following line should be added verbatim to the monitor user's crontab:
```
* * * * * . ${HOME}/.bashrc && ${BRAZOS_BASE_PATH}${BRAZOS_CGI_PATH}/_Perl/brazos.pl > /dev/null 2>&1
```

Note that although the monitor is triggered by this command once each minute, most cycles will
pass without any action being taken.  The most rapidly refreshed statistics are handled on a five
minute cycle, while standard statistics that take longer to generate are refreshed every thirty
minutes.  Longer running queries, and plots for long time scales are refreshed less regularly.
This timing is handled internally by the brazos.pl script, and cannot be overridden by alteration
of the crontab.  Safeguards exist to prohibit the duplicate execution of any already running
process, so that there is no danger of pileup.  Additionally, the scheduler shifts your job cycle
by an offset randomly generated during your initial configuration to help prevent excessive
simultaneous queries of the CMS PhEDEx and Dashboard systems.

If you receive more email than desired after enabling the monitor's crontab, please recall that
this feature may be rapidly disabled by editing the ~/mon/CONFIG/alert.txt configuration file.
Improving the intelligence of the email distribution manager is a planned object of future work.

Your feedback and comments are very much appreciated!

Enjoy -- Joel Walker
Asst. Professor of Physics
Sam Houston State University
jwalker@shsu.edu

****************************

Release Notes

Version 1.0
September 2012
Original Public Release

Version 1.01
October 2012
Modified configure.pl to fix variable interpolation in pattern matches.

Version 1.02
March 2013
Substantially mproved portability of the install.
Configured for auto-upgradability.
Also several bug fixes and system upgrades.
Thanks David Sanders / OleMiss !

