#-------------------------------------------------------------------------------
# Variables to setup through environment
#-------------------------------------------------------------------------------

# Specify default values.
prefix      := /usr/local
exec_prefix := $(prefix)
destdir     :=
# Fallback to defaults but allow to get the values from environment.
PREFIX      ?= $(prefix)
EXEC_PREFIX ?= $(exec_prefix)
DESTDIR     ?= $(destdir)

#-------------------------------------------------------------------------------
# Installation paths
#-------------------------------------------------------------------------------

PANDOC      := pandoc
GF          := gf
MD_FILE     := $(GF).md
MAN_FILE    := $(GF).1
HELP_FILE   := $(GF).help
VER_FILE    := VERSION
DESTPATH    := $(DESTDIR)$(PREFIX)
BINPATH     := $(DESTDIR)$(EXEC_PREFIX)/bin
SHAREPATH   := $(DESTPATH)/share
DATAPATH    := $(SHAREPATH)/$(GF)
MANPATH     := $(SHAREPATH)/man/man1

#-------------------------------------------------------------------------------
# Recipes
#-------------------------------------------------------------------------------

all:
	@ echo -n "Creating man file ..."
	@ { \
	echo -n "% GF(1) User Manual | Version "; cat VERSION; \
	echo -n "% "; cat AUTHORS; echo; \
	echo -n "% "; stat -c %z gf.md | cut -d" " -f1; \
	echo; cat $(MD_FILE); \
	} | $(PANDOC) -s -t man -o $(MAN_FILE)
	@ echo DONE
	@ echo -n "Creating help file ..."
	@ sed -n '/# SYNOPSIS/,/# INTRODUCTION/p;/# REFERENCES/,//p' $(MD_FILE) | grep -v "# INTRODUCTION" \
	| sed "s/\*\*//g;s/^:   /       /;s/^[^#]/       \0/;s/^# //;s/\[\(.\+\)(\([0-9]\+\))\](\(.\+\))/(\2) \1\n              \3/" > $(HELP_FILE)
	@ echo -e "\nOTHER\n\n       See man $(GF) for more information." >> $(HELP_FILE)
	@ echo DONE

install:
	@ [ -f $(MAN_FILE) ] && [ -f $(HELP_FILE) ] \
	|| { echo "Expected files not found; run 'make' first."; exit 1; }
	@ echo -n "Install man page ..."
	@ [ -d $(MANPATH) ] || mkdir -p $(MANPATH)
	@ cp $(MAN_FILE) $(MANPATH)
	@ echo DONE
	@ echo -n "Register command ..."
	@ cp $(GF) "$(BINPATH)"
	@ echo DONE
	@ echo -n "Create shared folder ..."
	@ [ -d $(DATAPATH) ] || mkdir -p $(DATAPATH)
	@ cp $(HELP_FILE) $(DATAPATH)
	@ cp $(VER_FILE) $(DATAPATH)
	@ echo DONE

uninstall:
	@ echo -n "Remove man page ..."
	@ rm $(MANPATH)/$(MAN_FILE) 2>/dev/null || true
	@ echo DONE
	@ echo -n "Remove command ..."
	@ rm $(BINPATH)/$(GF) 2>/dev/null || true
	@ echo DONE
	@ echo -n "Remove shared folder ..."
	@ rm -rf $(DATAPATH) 2>/dev/null || true
	@ echo DONE

clean:
	@ echo -n "Remove compiled files ..."
	@ rm "$(MAN_FILE)" 2>/dev/null || true
	@ rm "$(HELP_FILE)" 2>/dev/null || true
	@ echo DONE
