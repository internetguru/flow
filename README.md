# NAME

gf

# SYNOPSIS

gf [-ivh] [BRANCH]

# DESCRIPTION

**gf** automatically create (and merge) git flow branches from current or given BRANCH. If BRANCH does not exist, then gf create new feature (from dev).

**gf** implements **git flow model**(1) similarly to **git-flow command**(2) with following improvements:

* even simpler usage (with no parameters),

* automatic version number(3) incrementation (file VERSION),

* automatic version history update (file CHANGELOG),

* independent production branches support.

# OPTIONS

-i, --init
: Initialize current folder to be compatible with git flow model.

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
* for automatic creation run ``gf`` on production branch

feature
: * develop new feature
* name of brach should reflect functionality of the feature
* for creation run ``git checkout -b feature_name`` on branch _dev_

release-#.#
: * testing functionality before merge or move to production
* for automatic creation run ``gf``  on branch _dev_

# EXAMPLES

## Init new repository

1. ``cd project_folder``
2. ``gf --init``

## New feature

1. ``git checkout dev``
2. ``git checkout -b feature_name``
3. … some commits …
4. ``gf``

## New release

1. ``git checkout dev``
2. ``gf``

## Bugfix on release

1. ``git checkout release-#.#``
2. … fixes followed by commits …
3. ``gf `` (merge only to dev)

## Release to production

1. ``git checkout release-#.#``
2. ``gf``

## Hotfix

1. ``git checkout master``
2. ``gf``
3. … fixes followed by commits …
4. ``gf``

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