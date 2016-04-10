#-------------------------------------------------------------------------------
# Variables to setup through environment
#-------------------------------------------------------------------------------

# Specify default values.
prefix    := /usr/local
destdir   :=
# Fallback to defaults but allow to get the values from environment.
PREFIX    ?= $(prefix)
DESTDIR   ?= $(destdir)

#-------------------------------------------------------------------------------
# Installation paths
#-------------------------------------------------------------------------------

PANDOC      := pandoc
GF          := gf
MD_FILE     := $(GF).md
MAN_FILE    := $(GF).1
HELP_FILE   := $(GF).help
DESTPATH    := $(DESTDIR)$(PREFIX)
BINPATH     := $(DESTPATH)/bin
DATAPATH    := $(DESTPATH)/share/$(GF)
MANPATH     := $(DATAPATH)/man/man1

#-------------------------------------------------------------------------------
# Recipes
#-------------------------------------------------------------------------------

default:
	@ echo -n "Creating man file ..."
	@ $(PANDOC) -s -t man $(MD_FILE) -o $(MAN_FILE)
	@ echo DONE
	@ echo -n "Creating help file ..."
	@ sed -n '/# SYNOPSIS/,/# INTRODUCTION/p;/# REFE/,//p' $(MD_FILE) | grep -v "# INTRODUCTION" \
	| sed "s/\*\*//g;s/^:   /       /;s/^[^#]/       \0/;s/^# //;s/\[\(.\+\)(\([0-9]\+\))\](\(.\+\))/(\2) \1\n              \3/;s/,$$/,\n/" > $(HELP_FILE)
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
