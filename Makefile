#-------------------------------------------------------------------------------
# Variables to setup through environment
#-------------------------------------------------------------------------------

# Specify default values.
prefix       := /usr/local
exec_prefix  := $(prefix)
destdir      :=
system       := cygwin
# Fallback to defaults but allow to get the values from environment.
PREFIX       ?= $(prefix)
EXEC_PREFIX  ?= $(exec_prefix)
DESTDIR      ?= $(destdir)
SYSTEM       ?= $(system)

#-------------------------------------------------------------------------------
# Installation paths
#-------------------------------------------------------------------------------

PANDOC      := pandoc
GF          := gf
README      := README
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
NOMASTER    := $$([[ $(GCB) != master ]] && echo -$(GCB))
DISTNAME    := compile
INSTFILE    := install
UNINSTFILE  := uninstall

#-------------------------------------------------------------------------------
# Recipes
#-------------------------------------------------------------------------------

all:

	@ rm -rf $(DISTNAME) 2>/dev/null || true
	@ mkdir -p $(DISTNAME)
	@ cp $(VERFILE) $(CHLOGFILE) $(DISTNAME)

	@ echo -n "Compiling command file ..."
	@ { \
	head -n1 $(GF); \
	echo "DATAPATH=\"$(DATAPATH)\""; \
	tail -n+2 $(GF); \
	} > $(DISTNAME)/$(GF)
	@ chmod +x $(DISTNAME)/$(GF)
	@ echo DONE

	@ echo -n "Compiling man file ..."
	@ { \
	echo -n "% GF(1) User Manual | Version "; cat VERSION; \
	echo -n "% "; sed -n '/# AUTHORS/,/# COPYRIGHT/p' $(README).md | grep "@" | tr -d '*'; \
	echo -n "% "; stat -c %z $(README).md | cut -d" " -f1; \
	echo; \
	sed -n '/# NAME/,/# INSTALL/p;/# EXIT STATUS/,//p' $(README).md | grep -v "# INSTALL"; \
	} | $(PANDOC) -s -t man -o $(DISTNAME)/$(MANFILE)
	@ echo DONE

	@ echo -n "Compiling readme file ..."
	@ $(PANDOC) -s -t rst $(README).md -o $(DISTNAME)/$(README).rst
	@ echo DONE

	@ echo -n "Compiling help file ..."
	@ sed -n '/# SYNOPSIS/,/# DESCRIPTION/p;/# OPTIONS/,/# INTRODUCTION/p;/# REPORTING BUGS/,//p' $(README).md  | grep -v "# DESCRIPTION\|# INTRODUCTION" \
	| sed "s/\*\*//g;s/^: \+/       /;s/^[^#]/       \0/;s/^# //;s/\[\(.\+\)(\([0-9]\+\))\](\(.\+\))/(\2) \1\n              \3/;s/\[\(.\+\)\](\(.\+\))/\1\n              \2/" > $(DISTNAME)/$(HELPFILE)
	@ echo -e "\nOTHER\n\n       See man $(GF) for more information." >> $(DISTNAME)/$(HELPFILE)
	@ echo DONE

	@ echo -n "Compiling install file ..."
	@ { \
	echo "#!/bin/bash"; \
	echo "dir=\"\$$(dirname \"\$$0\")\""; \
	echo "mkdir -p $(MANPATH) \\"; \
	echo "&& cp \"\$$dir/$(MANFILE)\" $(MANPATH) \\"; \
	echo "&& mkdir -p $(BINPATH) \\"; \
	echo "&& cp \"\$$dir/$(GF)\" $(BINPATH) \\"; \
	echo "&& mkdir -p $(DATAPATH) \\"; \
	echo "&& cp \"\$$dir/$(HELPFILE)\" \"\$$dir/$(VERFILE)\" $(DATAPATH) \\"; \
	echo "&& echo 'Installation completed.'"; \
	} > $(DISTNAME)/$(INSTFILE)
	@ chmod +x $(DISTNAME)/$(INSTFILE)
	@ echo DONE

	@ echo -n "Compiling uninstall file ..."
	@ { \
	echo "#!/bin/bash"; \
	echo "rm \"$(MANPATH)/$(MANFILE)\" \\"; \
	echo "&& rm \"$(BINPATH)/$(GF)\" \\"; \
	echo "&& rm -rf \"$(DATAPATH)\" \\"; \
	echo "&& echo 'Uninstallation completed.'"; \
	} > $(DISTNAME)/$(UNINSTFILE)
	@ chmod +x $(DISTNAME)/$(UNINSTFILE)
	@ echo DONE

dist: DISTNAME=$(GF)-$$(cat $(VERFILE))$(NOMASTER)-$(SYSTEM)
dist: all
	@ tar czf $(DISTNAME).tar.gz $(DISTNAME)
	@ rm -rf $(DISTNAME)
	@ echo "Distribution build, see 'tar tvzf $(DISTNAME).tar.gz"