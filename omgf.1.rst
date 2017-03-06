NAME
====

Oh My Git Flow

SYNOPSIS
========

omgf [-cfhinrvVwy] [--color[=WHEN]] [KEYWORD] [NAME]

DESCRIPTION
===========

**Oh My Git Flow**\ [1] (hereinafter referred as the 'OMGF') applies **git
flow branching model**\ [2] according to KEYWORD and NAME. Both parameters are
optional (see PARAMETERS below).

OMGF is an alternative to **git-flow cheatsheet**\ [3] command with following
improvements:

-  even simpler usage (no parameters are required),

-  push and pull all main branches,

-  pull request support,

-  validate and repair project to conform the model,

-  automatic **semantic version numbering**\ [4] (file VERSION),

-  version history update support (file CHANGELOG.md),

-  version history follows **Keep a CHANGELOG**\ [5] principle,

-  tips how to proceed with development on current state,

-  independent production branches support,

-  parallel hotfix branches support.

Basic OMGF feature list:

- creating and merging standard branches,

- creating standard tags.

PARAMETERS
==========

NO PARAM
--------

on stable branch
    create new ``hotfix-$USER(-[0-9]+)?``
on dev branch
    create new ``feature-$USER(-[0-9]+)?``
on feature branch
    merge feature into dev
on release branch
    merge release into dev
on hotfix branch of newest stable branch
    merge hotfix into stable, dev and release (if exists)
on hotfix branch of other stable branch
    merge hotfix into stable

PARAM KEYWORD
-------------

hotfix
    create new ``hotfix-$USER(-[0-9]+)?``
release on release branch
    merge release into stable and dev
release on another branch
    switch to or create release
feature
    create new ``feature-$USER(-[0-9]+)?``

PARAM [KEYWORD] NAME
--------------------

on stable branch
    default KEYWORD = hotfix
on dev branch
    default KEYWORD = feature
on feature branch
    default KEYWORD = feature
on release branch
    default KEYWORD = hotfix
on hotfix branch
    default KEYWORD = hotfix
if KEYWORD is hotfix and NAME matches v#.#
    same as ``omgf hotfix`` on stable branch v#.#
else
    switch to or create ``KEYWORD-NAME`` branch

OPTIONS
=======

\-c, --conform
    Repair (initialize) project to be conform with **OMGF** model and proceed.
\--color[=WHEN], --colour[=WHEN]
    Use markers to highlight command status; WHEN is 'always', 'never', or
    'auto'. Empty WHEN sets color to 'always'. Default color value is 'auto'.
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

Set default options as alias
    -  ``alias gf="omgf --verbose --what-now"``

Initialize **OMGF**
    -  ``gf --init``

Bugfixing on dev...
    -  ``echo "bugfix 1" >> myfile``
    -  ``git add myfile``
    -  ``git commit -m "add bugfix 1"``

Create a feature
    -  ``gf``
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

Assume YES by default as alias
    -  ``alias gf="omgf --verbose --yes"``

New feature from uncommitted changes
    -  ``echo "feature force" >> myfile``
    -  ``gf feature myfeature``
    -  ...will exit with code 4
    -  ``gf --force feature myfeature``
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
    -  ``gf``

Create release with new MAJOR version
    -  ``gf release``
    -  ``echo 1.0.0 > VERSION``
    -  ``git commit -am "increment major version"``

Restore **OMGF** model (after merge pull request - release to master)
    -  ``gf feature myfeature``
    -  ...will exit with code 3
    -  ``gf --conform feature myfeature``

Hotfix obsolete stable branch
    -  ``gf hotfix v0.0``
    -  ``echo "hotfix old" >> myfile``
    -  ``git add myfile``
    -  ``git commit -am "add old hotfix"``
    -  ``gf``

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

`Keep a CHANGELOG[5] <http://keepachangelog.com/en/0.3.0/>`__

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
