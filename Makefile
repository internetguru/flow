#-------------------------------------------------------------------------------
# Variables to setup through environment
#-------------------------------------------------------------------------------

# Specify default values.
prefix       := /usr/local
destdir      :=
system       := linux
# Fallback to defaults but allow to get the values from environment.
PREFIX       ?= $(prefix)
BINDIR       ?= $(PREFIX)/bin
DESTDIR      ?= $(destdir)
SYSTEM       ?= $(system)

#-------------------------------------------------------------------------------
# Installation paths and defaults
#-------------------------------------------------------------------------------

SHELL       := /bin/bash
DIRNAME     := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
RST2MAN     := rst2man
PROG        := omgf
PROGSINGLE  := omgf.sh
DATAPATHVAR := OMGF_DATAPATH
USAGEVAR    := OMGF_USAGE
VERSIONVAR  := OMGF_VERNUM
README      := README.md
MANFILE     := $(PROG).1
MANRST      := $(PROG).1.rst
USAGEFILE   := $(PROG).usage
VERFILE     := VERSION
CHLOGFILE   := CHANGELOG.md
DESTPATH    := $(DESTDIR)$(PREFIX)
BINPATH     := $(DESTDIR)$(BINDIR)
SHAREPATH   := $(DESTPATH)/share
MANDIR      := man/man1
DISTNAME    := $(PROG)-$$(cat $(VERFILE))-$(SYSTEM)
# COMPILEDIR is overriden by dist and distsingle recipes
COMPILEDIR  := compiled
INSTFILE    := install
INSDEVTFILE := install_develop
UNINSTFILE  := uninstall
USAGEHEADER := "Usage: "

#-------------------------------------------------------------------------------
# Canned recipes
#-------------------------------------------------------------------------------

# Extract text from README between headers and format it to troff syntax
define compile_usage
	@ echo -n "Compiling usage file ..."
	@ echo -n "$(USAGEHEADER)" > $(COMPILEDIR)/$(USAGEFILE)
	@ grep "^$(PROG) \[" $(MANRST) | sed 's/\\|/|/g' >> $(COMPILEDIR)/$(USAGEFILE)
	@ echo ".TH" >> $(COMPILEDIR)/$(USAGEFILE)
	@ sed -n '/^OPTIONS/,/^BASIC FLOW EXAMPLES/p' $(MANRST)  | grep -v "^\(BASIC FLOW EXAMPLES\|OPTIONS\|======\)" \
	| sed 's/^\\//;s/^-/.TP 18\n-/' | sed 's/^    //' | sed '/^$$/d' >> $(COMPILEDIR)/$(USAGEFILE)
	@ echo DONE
endef

#-------------------------------------------------------------------------------
# Recipes
#-------------------------------------------------------------------------------

compile:
	@ mkdir -p $(COMPILEDIR)
	@ cp $(VERFILE) $(CHLOGFILE) $(COMPILEDIR)

	@ # Insert default datapath variable into $(PROG)
	@ echo -n "Compiling command file ..."
	@ { \
	head -n1 $(PROG); \
	echo "$(DATAPATHVAR)=\"$(SHAREPATH)/$(PROG)\""; \
	tail -n+2 $(PROG); \
	} > $(COMPILEDIR)/$(PROG)
	@ chmod +x $(COMPILEDIR)/$(PROG)
	@ echo DONE

	@ # Extract text from README between headers and convert it to troff syntax
	@ echo -n "Compiling man file ..."
	@ { \
	echo -n ".TH \"OMGF\" \"1\" "; \
	echo -n "\""; echo -n $$(stat -c %z $(MANRST) | cut -d" " -f1); echo -n "\" "; \
	echo -n "\"User Manual\" "; \
	echo -n "\"Version "; echo -n $$(cat $(VERFILE)); echo -n "\" "; \
	echo; \
	} > $(COMPILEDIR)/$(MANFILE)
	@ cat $(MANRST) | $(RST2MAN) | tail -n+8 >> $(COMPILEDIR)/$(MANFILE)
	@ echo DONE

	@ # Copy README and MAN rst into COMPILEDIR
	@ echo -n "Compiling readme file ..."
	@ cp $(README) $(COMPILEDIR)/$(README)
	@ cp $(MANRST) $(COMPILEDIR)/$(MANRST)
	@ echo DONE

	$(compile_usage)

	@ echo -n "Compiling install file ..."
	@ { \
	echo "#!/bin/bash"; \
	echo; \
	echo ": \$${BINPATH:=$(BINPATH)}"; \
	echo ": \$${SHAREPATH:=$(SHAREPATH)}"; \
	echo ": \$${USRMANPATH:=\$$SHAREPATH/$(MANDIR)}"; \
	echo; \
	echo "dir=\"\$$(dirname \"\$$0\")\""; \
	echo "mkdir -p \"\$$USRMANPATH\" \\"; \
	echo "&& cp \"\$$dir/$(MANFILE)\" \"\$$USRMANPATH\" \\"; \
	echo "&& mkdir -p \"\$$BINPATH\" \\"; \
	echo "&& cp \"\$$dir/$(PROG)\" \"\$$BINPATH\" \\"; \
	echo "&& mkdir -p \"\$$SHAREPATH/$(PROG)\" \\"; \
	echo "&& cp \"\$$dir/$(USAGEFILE)\" \"\$$dir/$(VERFILE)\" \"\$$SHAREPATH/$(PROG)\" \\"; \
	echo "&& echo 'Installation completed.' \\"; \
	echo "|| { echo 'Installation failed.'; exit 1; }"; \
	} > $(COMPILEDIR)/$(INSTFILE)
	@ chmod +x $(COMPILEDIR)/$(INSTFILE)
	@ echo DONE

	@ echo -n "Compiling uninstall file ..."
	@ { \
	echo "#!/bin/bash"; \
	echo; \
	echo ": \$${BINPATH:=$(BINPATH)}"; \
	echo ": \$${SHAREPATH:=$(SHAREPATH)}"; \
	echo ": \$${USRMANPATH:=\$$SHAREPATH/$(MANDIR)}"; \
	echo; \
	echo "rm \"\$$USRMANPATH/$(MANFILE)\""; \
	echo "rm \"\$$BINPATH/$(PROG)\""; \
	echo "rm -rf \"\$$SHAREPATH/$(PROG)\""; \
	echo "echo 'Uninstallation completed.'"; \
	} > $(COMPILEDIR)/$(UNINSTFILE)
	@ chmod +x $(COMPILEDIR)/$(UNINSTFILE)
	@ echo DONE

dist: COMPILEDIR=$(DISTNAME)
dist: compile
	@ tar czf $(COMPILEDIR).tar.gz $(COMPILEDIR)
	@ echo "Distribution built; see 'tar tzf $(COMPILEDIR).tar.gz'"

distsingle: COMPILEDIR=.
distsingle:
	@ $(compile_usage)

	@ echo -n "Compiling single script ..."
	@ # Insert content of $(USAGEFILE) and $(VERFILE) into $(PROG) as variables
	@ { \
	head -n1 $(PROG); \
	echo "$(USAGEVAR)=\"$$(cat $(USAGEFILE))\""; \
	echo "$(VERSIONVAR)=\"$$(cat $(VERFILE))\""; \
	tail -n+2 $(PROG); \
	} > $(PROGSINGLE)
	@ chmod +x $(PROGSINGLE)
	@ echo DONE

clean:
	@ rm -rf $(COMPILEDIR)
	@ rm -rf $(DISTNAME)
	@ rm -f $(USAGEFILE)

distclean:
	@ rm -f *.tar.gz
	@ rm -f $(PROGSINGLE)
