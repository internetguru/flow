NAME
====

Oh My Git Flow

SYNOPSIS
========

gf [-fciwrynvVh] [--color[=WHEN]] [BRANCH\|TAG\|KEYWORD]

DESCRIPTION
===========

**Oh My Git Flow**\ (1) (hereinafter referred as the 'OMGF') applies **git
flow branching model**\ (2) on current or selected BRANCH, TAG or
KEYWORD (such as 'release' or 'hotfix'). If BRANCH does not exist, new
feature is created.

It is an alternative to **git-flow cheatsheet**\ (3) command with
following improvements:

-  even simpler usage (no parameters required),

-  check and repair project to conform **OMGF**,

-  automatic **semantic version numbering**\ (4) (file VERSION),

-  version history update support (file CHANGELOG),

-  tips how to proceed with development on current state,

-  independent production branches support.

OPTIONS
=======

\-c, --conform
    Repair (initialize) project to be conform with **OMGF** and proceed.
\-i, --init
    Same as conform, but do not proceed.
\-f, --force
    Move (stash and pop) uncommitted changes.
\-w, --what-now
    Display what to do on current branch.
\-r, --request
    Instead of merging prepare current branch for pull request and push
    it to the origin.
\-y, --yes
    Assume yes for all questions.
\--color[=WHEN], --colour[=WHEN]
    Use markers to highlight command status; WHEN is 'always', 'never',
    or 'auto'
\-n, --dry-run
    Do not run commands; only parse user options.
\-v, --verbose
    Verbose mode.
\-V, --version
    Print version number.
\-h, --help
    Print help.

BASIC FLOW EXAMPLES
===================

Set global options
    -  ``export GF_OPTIONS="--verbose --what-now"``

Initialize **gf**
    -  ``gf --init``

Bugfixing on dev...
    -  ``echo "bugfix 1" >> myfile``
    -  ``git add myfile``
    -  ``git commit -m "add bugfix 1"``

Create a feature
    -  ``gf myfeature``

Developing a feature...
    -  ``echo "new feature code 1" >> myfile``
    -  ``git commit -am "insert myfeature function 1"``
    -  ``echo "new feature code 2" >> myfile``
    -  ``git commit -am "insert myfeature function 2"``

Merge feature
    -  ``gf``
    -  Insert myfeature description into CHANGELOG.

Bugfixing on dev...
    -  ``echo "bugfix 2" >> myfile``
    -  ``git commit -am "add bugfix 2"``

Create release
    -  ``gf``

Bugfixing on release...
    -  ``echo "release bugfix 1" >> myfile``
    -  ``git commit -am "add release bugfix 1"``
    -  ``gf`` (only to dev)
    -  ``echo "release bugfix 2" >> myfile``
    -  ``git commit -am "add release bugfix 2"``

Merge release
    -  ``gf``

Continue with bugfixing on dev...

ADVANCED EXAMPLES
=================

Hotfix master branch
    -  ``gf master``
    -  ``echo "hotfix 1" >> myfile``
    -  ``git commit -am "add hotfix 1"``
    -  ``gf``

Restore git flow model (after pull request to master)
    -  ``git checkout dev``
    -  ``git reset --hard HEAD~1``
    -  ``gf`` (will exit with code 3)
    -  ``gf -c``

Hotfix previous release
    -  ``gf v0.0``
    -  ``echo "hotfix old" >> myfile``
    -  ``git add myfile``
    -  ``git commit -am "add old hotfix"``
    -  ``gf``

Initialize **gf** on existing project with version number
    -  ``echo 1.12.0 > VERSION``
    -  ``gf --init``

New feature from uncommitted changes
    -  ``git checkout dev``
    -  ``echo "feature x" >> myfile``
    -  ``gf myfeature`` (will exit with code 4)
    -  ``gf -f myfeature``
    -  ``git commit -am "add feature x"``

Merge conflicting release
    -  ``gf release`` (will exit with code 5)
    -  Resolve conflicts...
    -  ``gf``

INSTALL
=======

From dist package
-----------------

``./install``, resp. ``./uninstall``

Tip: Specify destination directories
    E.g. ``MANPATH=/usr/share/man/man1 ./install``

From source
-----------

``./configure && make && compiled/install``

Make dist package from source
    ``./configure && make dist``
Tip: Specify variables
    E.g. ``./configure && PREFIX=/usr SYSTEM=babun make dist``
Tip: Install rst2man
    ``apt-get install python-docutils`` or
    ``pip install docutils``

HISTORY
=======

Actual version
    see file VERSION
Actual change log
    see file CHANGELOG

EXIT STATUS
===========

0
    No problems occurred.
1
    Generic error code.
2
    Parse or invalid option error.
3
    Git model is not conform with **OMGF**.
4
    Git status is not empty.
5
    Git conflict occurred.

SEE ALSO
========

`OMGF on GitHub(1) <https://github.com/InternetGuru/omgf/>`__

`Git flow model(2) <http://nvie.com/posts/a-successful-git-branching-model/>`__

`Git-flow cheatsheet(3) <http://danielkummer.github.io/git-flow-cheatsheet/>`__

`Semantic Versioning(4) <http://semver.org/>`__

REPORTING BUGS
==============

`Issue tracker <https://github.com/InternetGuru/omgf/issues>`__

COPYRIGHT
=========

Copyright (C) 2016 `InternetGuru <https://www.internetguru.cz>`__

`License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>`__

This is free software: you are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.

DONATION
========

We appreciate contributions of any size -- donations enable us to spend
more time working on the project, and help cover our infrastructure
expenses.

If you'd like to make a small donation, please visit URL below and do it
through PayPal. Since our project isn't a tax-exempt organization, we
can't offer you a tax deduction, but for all donations over 50 USD, we'd
be happy to recognize your contribution on URL below.

`PayPal Donation <https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=G6A49JPWQKG7A>`__

`Oh My Git Flow <https://www.internetguru.cz/omgf>`__

We are also happy to consider making particular improvements or changes,
or giving specific technical assistance, in return for a substantial
donation over 100 USD. If you would like to discuss this possibility,
write to us at info@internetguru.cz.

Another possibility is to pay a software maintenance fee. Again, write
to us about this at info@internetguru.cz to discuss how much you want to
pay and how much maintenance we can offer in return. If you pay more
than 50 USD, we can give you a document for your records.

Thanks for your support!

AUTHORS
=======

-  Pavel Petržela pavel.petrzela@internetguru.cz

-  Jiří Pavelka jiri.pavelka@internetguru.cz
