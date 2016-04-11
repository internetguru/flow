#-------------------------------------------------------------------------------
# Variables to setup through environment
#-------------------------------------------------------------------------------

# Specify default values.
prefix      := /usr/local
exec_prefix := $(prefix)
destdir     :=
system      := cygwin
# Fallback to defaults but allow to get the values from environment.
PREFIX      ?= $(prefix)
EXEC_PREFIX ?= $(exec_prefix)
DESTDIR     ?= $(destdir)
SYSTEM      ?= $(system)

#-------------------------------------------------------------------------------
# Installation paths
#-------------------------------------------------------------------------------

PANDOC      := pandoc
GF          := gf
GFWRAPPER   := _gf
MDFILE      := README.md
MANFILE     := $(GF).1
HELPFILE    := $(GF).help
VERFILE     := VERSION
CHLOGFILE   := CHANGELOG
DESTPATH    := $(DESTDIR)$(PREFIX)
BINPATH     := $(DESTDIR)$(EXEC_PREFIX)/bin
SHAREPATH   := $(DESTPATH)/share
DATAPATH    := $(SHAREPATH)/$(GF)
MANPATH     := $(SHAREPATH)/man/man1
GCB         := $$(git rev-parse --abbrev-ref HEAD)
NOTMASTER   := $$([[ $(GCB) != master ]] && echo -$(GCB))
DISTNAME    := $(GF)-$$(cat $(VERFILE))$(NOTMASTER)-$(SYSTEM)
INSTFILE    := install
UNINSTFILE  := uninstall

#-------------------------------------------------------------------------------
# Recipes
#-------------------------------------------------------------------------------

compile:
	@ echo -n "Creating man file ..."
	@ { \
	echo -n "% GF(1) User Manual | Version "; cat VERSION; \
	echo -n "% "; cat AUTHORS; echo; \
	echo -n "% "; stat -c %z $(MDFILE) | cut -d" " -f1; \
	echo; \
	sed -n '/# NAME/,/# INSTALL/p;/# REFERENCES/,//p' $(MDFILE) | grep -v "# INSTALL"; \
	} | $(PANDOC) -s -t man -o $(local_prefix)$(MANFILE)
	@ echo DONE
	@ echo -n "Creating help file ..."
	@ sed -n '/# SYNOPSIS/,/# DESCRIPTION/p;/# OPTIONS/,/# INTRODUCTION/p;/# REPORTING BUGS/,//p' README.md  | grep -v "# DESCRIPTION\|# INTRODUCTION" \
	| sed "s/\*\*//g;s/^: \+/       /;s/^[^#]/       \0/;s/^# //;s/\[\(.\+\)(\([0-9]\+\))\](\(.\+\))/(\2) \1\n              \3/;s/\[\(.\+\)\](\(.\+\))/\1\n              \2/" > $(HELPFILE)
	@ echo -e "\nOTHER\n\n       See man $(GF) for more information." >> $(local_prefix)$(HELPFILE)
	@ echo DONE

installers:
	@ { \
	echo "#!/bin/bash"; \
	echo "env SHAREPATH=$(SHAREPATH) $(DATAPATH)/$(GF) \"\$$@\" "; \
	} > $(local_prefix)$(GFWRAPPER)
	@ chmod +x $(local_prefix)$(GFWRAPPER)
	@ { \
	echo "#!/bin/bash"; \
	echo "cp $(MANFILE) $(MANPATH) \\"; \
	echo "&& cp $(GFWRAPPER) $(BINPATH)/$(GF) \\"; \
	echo "&& mkdir -p $(DATAPATH) \\"; \
	echo "&& cp $(HELPFILE) $(VERFILE) $(MDFILE) $(CHLOGFILE) $(GF) $(DATAPATH) \\"; \
	echo "&& echo 'Installation completed.'"; \
	} > $(local_prefix)$(INSTFILE)
	@ chmod +x $(local_prefix)$(INSTFILE)
	@ { \
	echo "#!/bin/bash"; \
	echo "rm $(MANPATH)/$(MANFILE) \\"; \
	echo "&& rm $(BINPATH)/$(GF) \\"; \
	echo "&& rm -rf $(DATAPATH) \\"; \
	echo "&& echo 'Uninstallation completed.'"; \
	} > $(local_prefix)$(UNINSTFILE)
	@ chmod +x $(local_prefix)$(UNINSTFILE)

clean:
	@ echo -n "Remove compiled files ..."
	@ rm "$(MANFILE)" 2>/dev/null || true
	@ rm "$(HELPFILE)" 2>/dev/null || true
	@ echo DONE

distfolder:
	@ [ -d $(DISTNAME) ] && echo "Distribution folder $(DISTNAME) already exists" && exit 1 || true
	@ mkdir -p $(DISTNAME)

dist: local_prefix=$(DISTNAME)/
dist: distfolder compile installers
	@ cp $(GF) $(VERFILE) $(CHLOGFILE) $(MDFILE) $(DISTNAME)
	@ tar czf $(DISTNAME).tar.gz $(DISTNAME)
	@ rm -rf $(DISTNAME)