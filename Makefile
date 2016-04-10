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
MDFILE      := $(GF).md
MANFILE     := $(GF).1
HELPFILE    := $(GF).help
VERFILE     := VERSION
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
	echo -n "% "; stat -c %z gf.md | cut -d" " -f1; \
	echo; cat $(MDFILE); \
	} | $(PANDOC) -s -t man -o $(MANFILE)
	@ echo DONE
	@ echo -n "Creating help file ..."
	@ sed -n '/# SYNOPSIS/,/# INTRODUCTION/p;/# REFERENCES/,//p' $(MDFILE) | grep -v "# INTRODUCTION" \
	| sed "s/\*\*//g;s/^:   /       /;s/^[^#]/       \0/;s/^# //;s/\[\(.\+\)(\([0-9]\+\))\](\(.\+\))/(\2) \1\n              \3/" > $(HELPFILE)
	@ echo -e "\nOTHER\n\n       See man $(GF) for more information." >> $(HELPFILE)
	@ echo DONE

installers:
	@ { \
	echo "#!/bin/bash"; \
	echo "cp $(MANFILE) $(MANPATH) \\"; \
	echo "&& cp $(GF) $(BINPATH) \\"; \
	echo "&& mkdir -p $(DATAPATH) \\"; \
	echo "&& cp $(HELPFILE) $(VERFILE) $(DATAPATH) \\"; \
	echo "&& echo 'Installation completed.'"; \
	} > $(INSTFILE)
	@ chmod +x $(INSTFILE)
	@ { \
	echo "#!/bin/bash"; \
	echo "rm $(MANPATH)/$(MANFILE) \\"; \
	echo "&& rm $(BINPATH)/$(GF) \\"; \
	echo "&& rm -rf $(DATAPATH) \\"; \
	echo "&& echo 'Uninstallation completed.'"; \
	} > $(UNINSTFILE)
	@ chmod +x $(UNINSTFILE)

clean:
	@ echo -n "Remove compiled files ..."
	@ rm "$(MANFILE)" 2>/dev/null || true
	@ rm "$(HELPFILE)" 2>/dev/null || true
	@ echo DONE

dist: compile installers
	@ [ -d $(DISTNAME) ] && echo "Distribution folder $(DISTNAME) already exists" && exit 1 || true
	@ mkdir -p $(DISTNAME)
	@ cp $(MANFILE) $(HELPFILE) $(GF) $(VERFILE) $(INSTFILE) $(UNINSTFILE) $(DISTNAME)
	@ tar czf $(DISTNAME).tar.gz $(DISTNAME)
	@ rm -rf $(DISTNAME)