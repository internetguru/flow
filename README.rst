NAME
====

Oh My Git Flow

SYNOPSIS
========

gf [-cfhinrvVwy] [--color[=WHEN]] [BRANCH\|TAG\|KEYWORD]

DESCRIPTION
===========

**Oh My Git Flow**\ [1] (hereinafter referred as the 'OMGF') applies **git
flow branching model**\ [2] on current or selected BRANCH, TAG or KEYWORD such
as 'release' or 'hotfix'. If BRANCH does not exist, new feature is created.

It is an alternative to **git-flow cheatsheet**\ [3] command with following
improvements:

-  even simpler usage (no parameters required),

-  pull request support,

-  check and repair project to conform **OMGF** model,

-  automatic **semantic version numbering**\ [4] (file VERSION),

-  version history update support (file CHANGELOG.md),

-  tips how to proceed with development on current state,

-  independent production branches support.

OPTIONS
=======

\-c, --conform
    Repair (initialize) project to be conform with **OMGF** model and proceed.
\--color[=WHEN], --colour[=WHEN]
    Use markers to highlight command status; WHEN is 'always', 'never', or
    'auto'.
\-f, --force
    Move (stash and pop) uncommitted changes.
\-h, --help
    Print help.
\-i, --init
    Same as conform, but do not proceed.
\-n, --dry-run
    Do not run commands; only parse user options.
\-r, --request
    Instead of merging prepare current branch for pull request and push it to
    the origin.
\-v, --verbose
    Verbose mode.
\-V, --version
    Print version number.
\-w, --what-now
    Display what to do on current branch.
\-y, --yes
    Assume yes for all questions.

BASIC FLOW EXAMPLES
===================

Set global options
    -  ``export GF_OPTIONS="--verbose --what-now"``

Initialize **OMGF**
    -  ``gf --init``

Bugfixing on dev...
    -  ``echo "bugfix 1" >> myfile``
    -  ``git add myfile``
    -  ``git commit -m "add bugfix 1"``

Create a feature
    -  ``gf myfeature``
    -  Confirm by typing ``YES`` (or hit Enter)

Developing a feature...
    -  ``echo "new feature code 1" >> myfile``
    -  ``git commit -am "insert myfeature function 1"``
    -  ``echo "new feature code 2" >> myfile``
    -  ``git commit -am "insert myfeature function 2"``

Merge feature
    -  ``gf``
    -  Confirm by typing ``YES`` (or hit Enter)
    -  Insert myfeature description into CHANGELOG.md

Bugfixing on dev...
    -  ``echo "bugfix 2" >> myfile``
    -  ``git commit -am "add bugfix 2"``

Create release
    -  ``gf release``
    -  Confirm by typing ``YES`` (or hit Enter)

Bugfixing on release...
    -  ``echo "release bugfix 1" >> myfile``
    -  ``git commit -am "add release bugfix 1"``
    -  ``gf``
    -  Confirm by typing ``YES`` (or hit Enter)
    -  ``echo "release bugfix 2" >> myfile``
    -  ``git commit -am "add release bugfix 2"``

Merge release
    -  ``gf release``
    -  Confirm by typing ``YES`` (or hit Enter)

Continue on branch dev...

ADVANCED EXAMPLES
=================

Assume YES by default
    -  ``export GF_OPTIONS="$GF_OPTIONS --yes"``

New feature from uncommitted changes
    -  ``echo "feature force" >> myfile``
    -  ``gf feature myfeature``
    -  ...will exit with code 4
    -  ``gf --force myfeature``
    -  ``git commit -am "add feature force"``

Hotfix master branch
    -  ``gf hotfix``
    -  ``echo "hotfix 1" >> myfile``
    -  ``git commit -am "add hotfix 1"``
    -  ``gf``
    -  Insert hotfix description into CHANGELOG.md

Merge conflicting feature
    -  ``gf myfeature``
    -  ...will exit with code 5
    -  Resolve conflict...
    -  ``git add -A``
    -  ``git rebase --continue``
    -  ``gf``

Create release with new MAJOR version
    -  ``gf release``
    -  ``echo 1.0.0 > VERSION``
    -  ``git commit -am "increment major version"``

Restore **OMGF** model (after simulated pull request to master)
    -  ``git checkout master``
    -  ``git merge --no-ff release``
    -  ``gf feature myfeature``
    -  ...will exit with code 3
    -  ``gf --conform myfeature``

Hotfix obsolete stable branch
    -  ``git checkout v0.0.0``
    -  ``gf``
    -  ``echo "hotfix old" >> myfile``
    -  ``git add myfile``
    -  ``git commit -am "add old hotfix"``
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
    see file CHANGELOG.md

EXIT STATUS
===========

0
    No problems occurred.
1
    Generic error code.
2
    Parse or invalid option error.
3
    Git is not conform with **OMGF** model.
4
    Git status is not empty.
5
    Git conflict occurred.

SEE ALSO
========

`OMGF on GitHub[1] <https://github.com/InternetGuru/omgf/>`__

`Git flow model[2] <http://nvie.com/posts/a-successful-git-branching-model/>`__

`Git-flow cheatsheet[3] <http://danielkummer.github.io/git-flow-cheatsheet/>`__

`Semantic Versioning[4] <http://semver.org/>`__

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

If you find this program useful, please **send a donation** to its developers
to support their work. If you use this program at your workplace, please
suggest that the company make a donation. We appreciate contributions of any
size. Donations enable us to spend more time working on this package, and help
cover our infrastructure expenses.

If you’d like to make a donation of any value, please send it to the following
PayPal address:

`PayPal Donation <https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=G6A49JPWQKG7A>`__

Since we aren’t a tax-exempt organization, we can’t offer you a tax deduction.
But for all donations over 50 USD, we’d be happy to recognize your
contribution on the **OMGF** page[1] and on this README file (including manual
page) for the next release.

We are also happy to consider making particular improvements or changes, or
giving specific technical assistance, in return for a substantial donation
over 100 USD. If you would like to discuss this possibility, write us at
info@internetguru.cz.

Another possibility is to pay a software maintenance fee. Again, write us
about this at info@internetguru.cz to discuss how much you want to pay and how
much maintenance we can offer in return.

Thanks for your support!

DONORS
======

`Faculty of Information Technology, CTU Prague <https://www.fit.cvut.cz/en>`__

`WebExpo Conference, Prague <https://webexpo.net/>`__

`DATAMOLE, data mining & machine learning <https://www.datamole.cz/>`__

AUTHORS
=======

-  Pavel Petržela pavel.petrzela@internetguru.cz

-  Jiří Pavelka jiri.pavelka@internetguru.cz
