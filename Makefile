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

DIRNAME     := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
RST2MAN     := rst2man.py
GF          := gf
README      := README
MANFILE     := $(GF).1
USAGEFILE   := $(GF).usage
VERFILE     := VERSION
CHLOGFILE   := CHANGELOG
DESTPATH    := $(DESTDIR)$(PREFIX)
BINPATH     := $(DESTDIR)$(EXEC_PREFIX)/bin
SHAREPATH   := $(DESTPATH)/share
MANDIR      := man/man1
GCB         := $$(git rev-parse --abbrev-ref HEAD)
NOMASTER    := $$([[ $(GCB) != master ]] && echo -$(GCB))
DISTNAME    := compiled
DISTDIR     := dist
INSTFILE    := install
INSDEVTFILE := install_develop
UNINSTFILE  := uninstall
USAGEHEADER := "Usage: "

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
	echo "GF_DATAPATH=\"$(SHAREPATH)/$(GF)\""; \
	tail -n+2 $(GF); \
	} > $(DISTNAME)/$(GF)
	@ chmod +x $(DISTNAME)/$(GF)
	@ echo DONE

	@ echo -n "Compiling man file ..."
	@ { \
	echo -n ".TH \"GF\" \"1\" "; \
	echo -n "\""; echo -n $$(stat -c %z $(README).rst | cut -d" " -f1); echo -n "\" "; \
	echo -n "\"User Manual\" "; \
	echo -n "\"Version "; echo -n $$(cat $(VERFILE)); echo -n "\" "; \
	echo; \
	} > $(DISTNAME)/$(MANFILE)
	@ cat $(README).rst | sed -n '/^NAME/,/^INSTALL/p;/^EXIT STATUS/,//p' $(README).rst | grep -v "^INSTALL" | sed 's/`\(.*\)<\(.*\)>`__/\1\n\t\2/g' | $(RST2MAN) | tail -n+8 >> $(DISTNAME)/$(MANFILE)
	@ echo DONE

	@ echo -n "Compiling readme file ..."
	@ cp $(README).rst $(DISTNAME)/$(README).rst
	@ echo DONE

	@ echo -n "Compiling usage file ..."
	@ echo -n "$(USAGEHEADER)" > $(DISTNAME)/$(USAGEFILE)
	@ grep "^gf \[" $(README).rst | sed 's/\\|/|/g' >> $(DISTNAME)/$(USAGEFILE)
	@ echo ".TH" >> $(DISTNAME)/$(USAGEFILE)
	@ sed -n '/^OPTIONS/,/^BASIC FLOW EXAMPLES/p' $(README).rst  | grep -v "^\(BASIC FLOW EXAMPLES\|OPTIONS\|======\)" \
	| sed 's/^\\/-/;s/^-/.TP 18\n-/' | sed 's/^    //' | sed '/^$$/d' >> $(DISTNAME)/$(USAGEFILE)
	@ echo DONE

	@ echo -n "Compiling install file ..."
	@ { \
	echo "#!/bin/bash"; \
	echo; \
	echo ": \$${BINPATH:=$(BINPATH)}"; \
	echo ": \$${SHAREPATH:=$(SHAREPATH)}"; \
	echo ": \$${MANPATH:=\$$SHAREPATH/$(MANDIR)}"; \
	echo; \
	echo "dir=\"\$$(dirname \"\$$0\")\""; \
	echo "mkdir -p \"\$$MANPATH\" \\"; \
	echo "&& cp --remove-destination \"\$$dir/$(MANFILE)\" \"\$$MANPATH\" \\"; \
	echo "&& mkdir -p \"\$$BINPATH\" \\"; \
	echo "&& cp --remove-destination \"\$$dir/$(GF)\" \"\$$BINPATH\" \\"; \
	echo "&& mkdir -p \"\$$SHAREPATH/$(GF)\" \\"; \
	echo "&& cp --remove-destination \"\$$dir/$(USAGEFILE)\" \"\$$dir/$(VERFILE)\" \"\$$SHAREPATH/$(GF)\" \\"; \
	echo "&& echo 'Installation completed.'"; \
	} > $(DISTNAME)/$(INSTFILE)
	@ chmod +x $(DISTNAME)/$(INSTFILE)
	@ echo DONE

	@ echo -n "Compiling uninstall file ..."
	@ { \
	echo "#!/bin/bash"; \
	echo; \
	echo ": \$${BINPATH:=$(BINPATH)}"; \
	echo ": \$${SHAREPATH:=$(SHAREPATH)}"; \
	echo ": \$${MANPATH:=\$$SHAREPATH/$(MANDIR)}"; \
	echo; \
	echo "rm \"\$$MANPATH/$(MANFILE)\""; \
	echo "rm \"\$$BINPATH/$(GF)\""; \
	echo "rm -rf \"\$$SHAREPATH/$(GF)\""; \
	echo "echo 'Uninstallation completed.'"; \
	} > $(DISTNAME)/$(UNINSTFILE)
	@ chmod +x $(DISTNAME)/$(UNINSTFILE)
	@ echo DONE

dist: DISTNAME=$(GF)-$$(cat $(VERFILE))$(NOMASTER)-$(SYSTEM)
dist: all
	@ mkdir -p $(DISTDIR)
	@ tar czf $(DISTDIR)/$(DISTNAME).tar.gz $(DISTNAME)
	@ rm -rf $(DISTNAME)
	@ echo "Distribution built; see 'tar tzf $(DISTDIR)/$(DISTNAME).tar.gz'"
