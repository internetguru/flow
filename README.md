# NAME

gf

# SYNOPSIS

gf [-ifvh] [BRANCH]

# DESCRIPTION

**gf** automatically create (and merge) git flow branches from current or given BRANCH. If BRANCH does not exist, then gf create new feature (from dev).

**gf** implements **git flow model**(1) similarly to **git-flow command**(2) with following improvements:

* even simpler usage (with no parameters),

* automatic **version number**(3) incrementation (file VERSION),

* automatic version history update (file CHANGELOG),

* independent production branches support.

# OPTIONS

-i, --init
: Initialize current folder to be compatible with git flow model.

-f, --force
: Stash (and pop) uncommited changes.

-v, --version
: Print version number.

-h, --help
: Print help.

# INTRODUCTION

**Git flow model** is based on two main branches, _master_ and _dev_:

dev
: * new features or fixes (bugfix)

master
: * main production branch
* also another independent production branches

Temporary branches:

hotfix-#.#.#
: * fixes on production branch

feature
: * develop new feature
* name of brach should reflect functionality of the feature

release-#.#
: * testing functionality before merge or move to production

# EXAMPLES

## Complete flow example

Init repository
: * ``gf -i``

Bugfix (0+)
: * ``echo "bugfix" >> flow``
* ``git add flow``
* ``git commit -am "add file flow"``

Create feature
: * ``gf example``

Develop (1+)
: * ``echo "new feature example" >> flow``
* ``git commit -am "flow: add new feature example"``

Merge feature
: * ``gf``

Bugfix (0+)
: * ``echo "bugfix 2" >> flow``
* ``git commit -am "flow: add bugfix 2"``

Create release
: * ``gf``

Bugfix (0+)
: * ``echo "bugfix 3" >> flow``
* ``git commit -am "flow: add bugfix 3"``
* ``gf`` (only to dev)

Merge release
: * ``gf``

Create hotfix
: * ``gf``

Hotfix (1+)
: * ``echo "hotfix" >> flow``
* ``git commit -am "flow: add hotfix"``

Merge hotfix
: * ``gf``

Go to step 2

## Advanced flow examples

Init on existing repository
: * ``gf -i``
* ``echo 1.12.0 > VERSION``
* ^ add real project version number
* ``git commit -am "fix version number"``

New feature with local changes
: * ``gf myfeature``
* ^ exit with status code 3 (see below)
* ``gf -f myfeature``
* ^ move local changes to new feature

Merge old feature (with rebase)
: * ``gf myfeature``
* ^ automatic rebase to develop branch

Merge release conflicting with develop
: * ``gf release-#.#``
* ^ exit on branch dev with error (standard git merge conflict message)
* … resolve conflicts and commit …
* ``gf release-#.#``
* ^ success

Try to use gf on corrupted repository
: * ``gf``
* ^ exit with stus code 2 (see below)
* ``gf -i``
* ^ may help to fix repository

# INSTALL

From dist package
: 1. ``tar xzf package_name.tar.gz``
2. ``cd package_name``
3. ``./install``, resp. ``./uninstall``

From source
: 1. ``git clone git@bitbucket.org:igwr/gf.git``
2. ``cd gf``
3. ``./configure && make``
4. ``compile/install``, resp. ``compile/uninstall``

# HISTORY

Actual version
: file VERSION

Actual change log
: file CHANGELOG

# AUTHORS

* Pavel Petržela <pavel@petrzela.eu>

* Jiří Pavelka <j.pavelka@seznam.cz>

# EXIT STATUS

0
: No problems occurred.

1
: Generic error code.

2
: Initial check failed; initializing gf may help.

3
: Git status check failed; forcing gf may help.

# SEE ALSO

[**git flow model**(1)](http://nvie.com/posts/a-successful-git-branching-model/)

[**git-flow cheatsheet**(2)](http://danielkummer.github.io/git-flow-cheatsheet/)

[**Semantic Versioning**(3)](http://semver.org/)

# REPORTING BUGS

[**Issue tracker**](https://bitbucket.org/igwr/gf/issues)

# COPYRIGHT

* Copyright (C) 2016 Czech Technical University in Prague

* License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

* This is free software: you are free to change and redistribute it.

* There is NO WARRANTY, to the extent permitted by law.
