# NAME

gf

# SYNOPSIS

gf [-iftvh] [BRANCH]

# DESCRIPTION

**gf** automatically creates (and merges) git flow branches from current or given BRANCH. If BRANCH does not exist, then gf creates new feature (from branch dev).

**gf** implements **git flow model**(1) similarly to **git-flow command**(2) with following improvements:

* even simpler usage (no parameters required),

* automatic **version number**(3) incrementation (file VERSION),

* version history update support (file CHANGELOG),

* independent production branches support.

# OPTIONS

-i, --init
: Initialize current folder.

-f, --force
: Move (stash and pop) uncommitted changes.

-t, --tips
: Display tips for current branch.

-y, --yes
: Assume yes for all questions.

-n, --dry-run
: Do not run commands; only parse user options.

-v, --verbose
: Verbose mode.

-V, --version
: Print version number.

-h, --help
: Print help.

# BASIC FLOW EXAMPLES

Initialize **gf**
: * ``gf -i``

Bugfixing on dev...
: * ``echo "bugfix 1" >> myfile``
* ``git add myfile``
* ``git commit -m "add bugfix 1"``

Create a feature
: * ``gf myfeature``

Developing a feature...
: * ``echo "new feature code 1" >> myfile``
* ``git commit -am "insert myfeature function 1"``
* ``echo "new feature code 2" >> myfile``
* ``git commit -am "insert myfeature function 2"``

Merge feature
: * ``gf``
* Insert myfeature description into CHANGELOG.

Bugfixing on dev...
: * ``echo "bugfix 2" >> myfile``
* ``git commit -am "add bugfix 2"``

Create release
: * ``gf``

Bugfixing on release...
: * ``echo "release bugfix 1" >> myfile``
* ``git commit -am "add release bugfix 1"``
* ``gf`` (only to dev)
* ``echo "release bugfix 2" >> myfile``
* ``git commit -am "add release bugfix 2"``
* ``gf`` (only to dev)

Merge release
: * ``gf``

Continue with bugfixing on dev...

# ADVANCED EXAMPLES

Hotfix master branch
: * ``gf master``
* ``echo "hotfix 1" >> myfile``
* ``git commit -am "add hotfix 1"``
* ``gf``

Hotfix previous release
: * ``gf master-0.1.0``
* ``echo "hotfix 2" >> myfile``
* ``git commit -am "add hotfix 2"``
* ``gf``

Initialize **gf** on existing project with version number
: * ``echo 1.12.0 > VERSION``
* ``gf -i``

New feature from uncommitted changes
: * ``gf -f myfeature``

Merge conflicting release
: * ``gf release``
* Exits with standard git merge conflict message.
* Resolve conflicts...
* ``gf``

# INSTALL

From dist package
: ``./install``, resp. ``./uninstall``

Tip: Specify destination directories
: E.g. ``MANPATH=/usr/share/man/man1 ./install``

Make dist files into ``compiled`` folder
: ``./configure && make``

Make dist package from source
: ``./configure && make dist``

Tip: Specify variables
: E.g. ``./configure && PREFIX=/usr SYSTEM=babun make dist``

# HISTORY

Actual version
: see file VERSION

Actual change log
: see file CHANGELOG

# AUTHORS

* Pavel Petržela <pavel.petrzela@internetguru.cz>

* Jiří Pavelka <jiri.pavelka@internetguru.cz>

# EXIT STATUS

0
: No problems occurred.

1
: Generic error code.

2
: Parse or invalid option error.

3
: Initial check failed; initializing gf may help.

4
: Git status check failed; forcing gf may help.

5
: Conflict occured; git status may help.

# SEE ALSO

[**git flow model**(1)](http://nvie.com/posts/a-successful-git-branching-model/)

[**git-flow cheatsheet**(2)](http://danielkummer.github.io/git-flow-cheatsheet/)

[**Semantic Versioning**(3)](http://semver.org/)

# REPORTING BUGS

[**Issue tracker**](https://github.com/InternetGuru/gf/issues)

# COPYRIGHT

* Copyright (C) 2016 [InternetGuru](https://www.internetguru.cz)

* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

* This is free software: you are free to change and redistribute it.

* There is NO WARRANTY, to the extent permitted by law.
