
-include $(HOME)/brazos/sources/config/Configure.mk

SHELL := /bin/sh

TARGETS := $(HOME)/brazos/sources/targets
VPATH := $(TARGETS)

MON_PATH_HTML ?= /public_html
MON_PATH_CGI ?= /public_html/cgi-bin

.SUFFIXES:

.PHONY: all test install clean uninstall

.PHONY: local_bin local_perl build finish

all: | local_bin local_perl build finish

test:

install:

clean:

# revert to bare configuration
uninstall:
	@rm -rf ~/.cpan ~/.cpanm ~/local ~/perl5 ~/brazos/sources/config/* ~/brazos/sources/targets/* \
	$(HOME)$(MON_PATH_HTML)/mon $(HOME)$(MON_PATH_CGI)/mon $(HOME)/mon 2>/dev/null
	@for f in ~/.bash_profile ~/.profile ~/.bashrc; do [ -e $$f ] && \
	perl -i -ne '/^# (?:BEGIN|(END)) BRAZOS MONITOR/ ? ($$c = !$$1) : ($$c || print)' $$f; \
	[ -s $$f ] || rm -rf $$f; done

# configure local profile
bash_profile: | ; @ \
	printf "%s\n" \
	'# BEGIN BRAZOS MONITOR LOCAL BASH PROFILE CONFIGURATION' \
	'[ -e ~/.profile ] && . ~/.profile' \
	'# END BRAZOS MONITOR LOCAL BASH PROFILE CONFIGURATION' \
	>> ~/.bash_profile && \
	touch $(TARGETS)/$@ 

# configure local bash profile
profile: | bash_profile; @ \
	printf "%s\n" \
	'# BEGIN BRAZOS MONITOR LOCAL PROFILE CONFIGURATION' \
	'[ -e ~/.bashrc ] && . ~/.bashrc' \
	'# END BRAZOS MONITOR LOCAL PROFILE CONFIGURATION' \
	>> ~/.profile && \
	touch $(TARGETS)/$@ 

# configure local binary environment
bashrc_bin: | bash_profile profile; @ \
	printf "%s\n" \
	'# BEGIN BRAZOS MONITOR LOCAL BINARY CONFIGURATION' \
	'umask 0022' \
	'PREFIX=$$HOME/local' \
	'export PATH=$$PREFIX/bin:$$PATH' \
	'export LD_LIBRARY_PATH=$$PREFIX/lib' \
	'export LIBRARY_PATH=$$PREFIX/lib:$$LIBRARY_PATH' \
	'export C_INCLUDE_PATH=$$PREFIX/include' \
	'export CPLUS_INCLUDE_PATH=$$PREFIX/include' \
	'export MANPATH=$$PREFIX/share/man:$$PREFIX/man:$$MANPATH' \
	'export BRAZOS_BASE_PATH=$(HOME)' \
	'export BRAZOS_PERL_PATH=/perl5' \
	'export BRAZOS_PERL_LIB_PATH=/perl5/lib/perl5' \
	'export BRAZOS_LOCAL_PATH=/local' \
	'export BRAZOS_MON_PATH=/mon' \
	'export BRAZOS_HTML_PATH=$(MON_PATH_HTML)/mon' \
	'export BRAZOS_CGI_PATH=$(MON_PATH_CGI)/mon' \
	'# END BRAZOS MONITOR LOCAL BINARY CONFIGURATION' \
	>> ~/.bashrc && \
	touch $(TARGETS)/$@

# configure local perl environment
bashrc_perl: | local_bin; @ \
	printf "%s\n" \
	'# BEGIN BRAZOS MONITOR LOCAL PERL CONFIGURATION' \
	'eval $$(perl -I$$HOME/perl5/lib/perl5 -Mlocal::lib)' \
	'# END BRAZOS MONITOR LOCAL PERL CONFIGURATION' \
	>> ~/.bashrc && \
	touch $(TARGETS)/$@

# Install binary libraries locally
local_bin: | local_bin_zlib local_bin_libpng local_bin_libjpeg local_bin_libgd local_bin_perl

local_bin_libgd: | local_bin_zlib local_bin_libpng local_bin_libjpeg

local_bin_zlib: | bashrc_bin; @ \
	. ~/.bashrc && \
	cd ~/brazos/sources/build/zlib-1.2.7 && \
	./configure --prefix=$(HOME)/local && \
	$(MAKE) && $(MAKE) install && $(MAKE) clean && \
	touch $(TARGETS)/$@

local_bin_libpng: | bashrc_bin; @ \
	. ~/.bashrc && \
	cd ~/brazos/sources/build/libpng-1.5.12 && \
	./configure --prefix=$(HOME)/local && \
	$(MAKE) && $(MAKE) install && $(MAKE) clean && \
	touch $(TARGETS)/$@

local_bin_libjpeg: | bashrc_bin; @ \
	. ~/.bashrc && \
	cd ~/brazos/sources/build/jpeg-8d && \
	./configure --prefix=$(HOME)/local && \
	mkdir -p $(HOME)/local/man/man1 && \
	$(MAKE) && $(MAKE) install && $(MAKE) clean && \
	touch $(TARGETS)/$@

local_bin_libgd: | bashrc_bin; @ \
	. ~/.bashrc && \
	cd ~/brazos/sources/build/GD_2_0_33 && \
	./configure --prefix=$(HOME)/local --with-zlib-dir=$(HOME)/local --with-png=$(HOME)/local --with-jpeg=$(HOME)/local && \
	$(MAKE) && $(MAKE) install && $(MAKE) clean && \
	touch $(TARGETS)/$@

local_bin_perl: | bashrc_bin; @ \
	. ~/.bashrc && \
	cd ~/brazos/sources/build/local-lib-1.008004 && \
	/usr/bin/perl Makefile.PL --bootstrap && \
	$(MAKE) && $(MAKE) install && $(MAKE) clean && \
	touch $(TARGETS)/$@

local_perl: | local_perl_minus local_perl_mods local_perl_gd

local_perl_gd: | local_perl_minus local_perl_mods

local_perl_mods: | local_perl_minus

# Install CPAN::Minus Installer
local_perl_minus: | bashrc_perl; @ \
	. ~/.bashrc && \
	< ~/brazos/sources/build/cpanm perl - --self-upgrade && \
	touch $(TARGETS)/$@

#	cpanm --installdeps GD && \
# Install Perl modules locally
local_perl_mods: | bashrc_perl; @ \
	. ~/.bashrc && \
	cpanm Time::Local && \
	cpanm LWP::UserAgent && \
	cpanm HTTP::Request::Common && \
	cpanm Mail::Sendmail && \
	cpanm MIME::QuotedPrint && \
	cpanm MIME::Base64 && \
	cpanm GD@2.52 && \
	touch $(TARGETS)/$@

# Install Perl GD module locally
#local_perl_gd: | bashrc_perl; @ \
#	. ~/.bashrc && \
#	cd ~/brazos/sources/build/GD-2.49 && \
#	perl Makefile.PL && $(MAKE) && $(MAKE) install && $(MAKE) clean && \
#	touch $(TARGETS)/$@
local_perl_gd: | bashrc_perl; @ \
	touch $(TARGETS)/$@

build: | build_mon build_cgi build_html

build_html: | build_mon build_cgi

build_cgi: | build_mon

build_mon: | config_local_path config_local_timeshift

config_local_path: | local_perl; @ \
	. ~/.bashrc && \
	cp -p ~/brazos/sources/build/Local/Path.pm ~/brazos/sources/cgi/Local/Path.pm && \
	perl -i -pe "BEGIN { @s = ( \
	'$(HOME)', '/perl5', '/perl5/lib/perl5', '/local', '/mon', '$(MON_PATH_HTML)/mon', '$(MON_PATH_CGI)/mon' \
	) } s/<\[(\d+)\]>/\$$s[\$$1]/g" ~/brazos/sources/cgi/Local/Path.pm && \
	touch $(TARGETS)/$@

config_local_timeshift: | local_perl; @ \
	. ~/.bashrc && \
	cp -p ~/brazos/sources/build/Local/TimeShift.pm ~/brazos/sources/cgi/Local/TimeShift.pm && \
	perl -i -pe "BEGIN { @s = ( int rand 6*60*60 ) } \
	s/<\[(\d+)\]>/\$$s[\$$1]/g" ~/brazos/sources/cgi/Local/TimeShift.pm && \
	touch $(TARGETS)/$@

# Build monitor mon directory tree
build_mon: | local_perl; @ \
	. ~/.bashrc && \
	cp -pRP ~/brazos/sources/mon $(HOME)/mon && \
	touch $(TARGETS)/$@

# Build monitor cgi directory tree
build_cgi: | local_perl; @ \
	. ~/.bashrc && \
	[ -d $(HOME)$(MON_PATH_CGI) ] && \
	cp -pRP ~/brazos/sources/cgi $(HOME)$(MON_PATH_CGI)/mon && \
	touch $(TARGETS)/$@

# Build monitor html directory tree
build_html: | local_perl; @ \
	. ~/.bashrc && \
	[ -d $(HOME)$(MON_PATH_HTML) ] && \
	cp -pRP ~/brazos/sources/html $(HOME)$(MON_PATH_HTML)/mon && \
	touch $(TARGETS)/$@

# Output a message indicatng that installation is complete
finish: | ; @ \
	echo "*** BRAZOS MONITOR INSTALLATION COMPLETE ***"

