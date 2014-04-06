# $Id: makefile.in,v 1.3 2002/11/23 17:29:32 tom Exp $
# top-level makefile-template for 'bcpp'

THIS		= bcpp

#### Start of system configuration section. ####

srcdir		= .


INSTALL		= /bin/install.exe
INSTALL_PROGRAM	= ${INSTALL}
INSTALL_DATA	= ${INSTALL} -m 644

prefix		= /usr/local
exec_prefix	= ${prefix}

bindir		= $(DESTDIR)${exec_prefix}/bin
mandir		= $(DESTDIR)${prefix}/man/man1
manext		= 1

#### End of system configuration section. ####

SHELL		= /bin/sh

DISTFILES = configure $(SRC)

all:
	cd code && $(MAKE) $@

install: all installdirs
	cd code && $(MAKE) $@
	$(INSTALL_PROGRAM) code/$(THIS) $(bindir)/$(THIS)
	$(INSTALL_DATA) $(srcdir)/txtdocs/$(THIS).1 $(mandir)/$(THIS).$(manext)

installdirs:
	$(SHELL) ${srcdir}/mkdirs.sh $(bindir) $(mandir)

uninstall:
	rm -f $(bindir)/$(THIS) $(mandir)/$(THIS).$(manext)

mostlyclean:
	cd code && $(MAKE) $@
	rm -f *.o core *~ *.out *.BAK *.atac

clean: mostlyclean
	cd code && $(MAKE) $@
	rm -f $(THIS)

distclean: clean
	cd code && $(MAKE) $@
	rm -f makefile code/makefile code/autoconf.h
	rm -f config.log config.cache config.status

realclean: distclean
	cd code && $(MAKE) $@

check:
	cd code && $(MAKE) $@

RELEASE	= `cat $(srcdir)/VERSION`
RELDIR	= echo "$(THIS)-`sed -e 's/[^0-9]//g' $(srcdir)/VERSION`"

# I keep my sources in RCS, and assign a symbolic release to the current patch
# level.  The 'manifest' script knows how to build a list of files for a given
# revision.
MANIFEST: $(srcdir)/VERSION
	manifest -r$(RELEASE)

dist: MANIFEST
	- rm -f .fname .files
	$(RELDIR) >.fname
	cat MANIFEST | grep ' ' | egrep -v ' subdirectory$$' | sed -e 's/\ .*//' | uniq >.files
	rm -rf `cat .fname`
	TOP=`cat .fname`; mkdir $$TOP `cat .files | grep / | sed -e 's@/.*@@' | sed -e s@\^@$$TOP/@ | uniq`
	for file in `cat .files`; do \
	  ln $(srcdir)/$$file `cat .fname`/$$file \
	    || { echo copying $$file instead; cp $$file `cat .fname`/$$file; }; \
	done
	tar -cf - `cat .fname` | gzip >`cat .fname`.tgz
	rm -rf `cat .fname` .fname .files

# Some of the output will be uuencoded because the test scripts include
# <CR><LF> terminated ".bat" files for MS-DOS.
dist-shar: MANIFEST
	- rm -f .fname .files
	$(RELDIR) >.fname
	cat MANIFEST | grep ' ' | egrep -v ' subdirectory$$' | sed -e 's/\ .*//' | uniq >.files
	shar -M -n`cat .fname` -opart -l50 `cat .files`
	- rm -f .fname .files
