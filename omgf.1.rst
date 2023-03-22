NAME
====

Oh My Git Flow


SYNOPSIS
========

omgf [-cfhinrvVwy] [--color[=WHEN]] [KEYWORD [NAME]]


DESCRIPTION
===========

**Oh My Git Flow**\ [1] (AKA 'OMGF') maintains the **git flow branching model**\ [2] including versioning and keeping a changelog. It advances the model according to the current state, branch, and optional arguments.

OMGF is an alternative to the *git-flow cheatsheet*\ [3] command with the following features:

* It has a simpler usage and does not require arguments.

* It validates and automatically **fixes projects** to conform to the branching model.

* It can initiate a new repository on an empty or existing folder.

* It can convert an existing repository into a git flow branching model.

* It helps pull and push all main branches.

* It supports pull requests for GitHub and GitLab.

* It controls **semantic versioning**\ [4] in a ``VERSION`` file.

* It keeps track of release history following the **Keep a CHANGELOG**\ [5] convention.

* It shows tips on how to advance based on the current state, branch, and arguments.

* It maintains separate production branches for major versions, such as ``prod-1``.

* It supports parallel hotfix branches even for separate production branches.

* It adapts to pre-existing branches, such as ``master`` instead of the default ``main``.


ARGUMENTS
=========

Argument KEYWORD determines the action. Default KEYWORD value is branch name, the part before first dash. E.g. ``dev`` branch results to ``dev``, ``feature-abc-1`` results to ``feature`` KEYWORD. Default NAME (where applicable) is current user name, command ``whois``.

Supported KEYWORDS and associated actions:

feature|dev [NAME]
    Release branch ``feature-NAME`` if currently on it.
    Else checkout the branch if it exists.
    Else create the branch and checkout.

staging
    Release branch ``dev`` if currently on it.
    Else release branch ``staging`` if on it and is not merged.
    Else checkout the ``staging`` branch.

hotfix|main|prod [NAME]
    Release branch ``hotfix-NAME`` if currently on it.
    Else checkout the branch if it exists.
    Else create the branch and checkout.

pull
    Pull all from the remote repository.

push
    Push all to the remote repository.


OPTIONS
=======

\-c, --conform
    Repair (initialize) project to be conform with **OMGF** model and proceed.

\--color[=WHEN], --colour[=WHEN]
    Use markers to highlight command status; WHEN is 'always', 'never', or 'auto'. Empty WHEN sets color to 'always'. Default color value is 'auto'.

\-e, --auto-entry
    Do not show changelog editor and insert general entry instead about the current action.

\-h, --help
    Print help.

\-i, --init
    Same as 'conform', but also initialize git repository if not exists and do not proceed to action.

\-n, --dry-run
    Do not run commands; only parse user options and arguments.

\-r, --request
    Instead of merging prepare current branch for pull request and push it to the origin.

\-s, --stash
    Temporary remove (stash and pop) uncommitted changes.

\-v, --verbose
    Verbose mode.

\-V, --version
    Print version number.

\-w, --what-now
    Display what to do on current branch.

\-y, --yes
    Assume yes for all questions.


FLOW EXAMPLE
============

1. Initialize the branching model on an empty folder::

    mkdir a
    cd a
    omgf --init

There are now several branches and even a tag in your git repository. The default version number is ``0.0.0`` on all branches except for ``dev`` where it is ``0.1.0``. See for yourself.

2. Create and release a feature::

    omgf feature
    touch a
    git add a
    git commit -m "Add file a"
    omgf feature

You will be prompted to confirm and insert a changelog description. This will also list the feature commits as a reminder. How handy.

Note: Technically, there is no need to use the ``feature`` argument in either cases from the example above. Why? Because the initialization finishes on the ``dev`` branch, where ``feature`` is the default value.

3. Fix some bugs on ``dev`` and release to ``staging`` branch::

    touch b
    git add b
    git commit -m "Add file b"
    omgf staging

You will be prompted to confirm the release. You can suppress the confirmation using the ``--yes`` option.

Note: This time the ``staging`` argument is necessary, because the default action for the ``dev`` branch is to create or checkout a feature.

Notice the version number from ``dev`` gets to ``staging`` branch, ``dev`` version is incremented to ``0.2.0`` and stable branches still have ``0.0.0``. Isn't it cool?

4. Fix some bugs on the ``staging`` branch and release to stable branches::

    touch c
    git add c
    git commit -m "Add file c"
    omgf --yes

No prompt, no unnecessary argument as the flow is currently on ``staging`` branch. We are getting advanced.

Note: The ``staging`` branch, the ``prod-0``, and the ``main`` are all on the same commit. It may seem far fetched. There is also a tag with the newly released version number.

5. Hotfix the production::

    omgf hotfix
    touch c
    git add c
    git commit -m "Add file c"
    omgf

You will be prompted to release the hotfix and to describe it in a changelog. You have seen this before, haven't you?

Note: The git log now looks like a drunk spider's web. It will make much more sense over time unless you have some experience already. If you still want to see it, you can use the following command::

    git log --oneline --decorate --color --graph --all


EXIT CODES
==========

0
    No problems occurred.
1
    Generic error code.
2
    Parse or invalid option error.
3
    Git is not conform with the branching model, probably fixable with OMGF.
4
    Git is not conform with the branching model, unfixable with OMGF.
5
    Git status is not empty AKA uncommitted changes.
6
    Nothing to do (e. g. empty merge).


SEE ALSO
========

[1] `OMGF on GitHub <https://github.com/InternetGuru/omgf/>`__

[2] `Git flow model <https://nvie.com/posts/a-successful-git-branching-model/>`__

[3] `Git flow cheatsheet <https://danielkummer.github.io/git-flow-cheatsheet/>`__

[4] `Semantic Versioning <https://semver.org/>`__

[5] `Keep a CHANGELOG <https://keepachangelog.com/en/0.3.0/>`__


REPORTING BUGS
==============

`Issue tracker <https://github.com/InternetGuru/omgf/issues>`__


COPYRIGHT
=========

Copyright (C) 2016--2023 `Internet Guru <https://www.internetguru.io>`__

`License GPLv3 <https://www.gnu.org/licenses/gpl-3.0.html>`__ or later

This is a free software. You are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.


DONATION
========

If you find this program useful, please **send a donation** to its developers
to support their work. If you use this program at your workplace, please
suggest that the company make a donation. We appreciate contributions of any
size. Donations enable us to spend more time working on this package, and help
cover our infrastructure expenses.

If you'd like to make a donation of any value, please send it to the following
PayPal address:

`PayPal Donation <https://www.paypal.com/cgi-bin/webscr?cmd=__s-xclick&hosted__button__id=G6A49JPWQKG7A>`__

Since we aren't a tax-exempt organization, we can't offer you a tax deduction.
But for all donations over 50 USD, we'd be happy to recognize your
contribution on the **OMGF** page[1] and on this README file (including manual
page) for the next release.

We are also happy to consider making particular improvements or changes, or
giving specific technical assistance, in return for a substantial donation
over 100 USD. If you would like to discuss this possibility, write us at
info@internetguru.io.

Another possibility is to pay a software maintenance fee. Again, write us
about this at info@internetguru.io to discuss how much you want to pay and how
much maintenance we can offer in return.

Thanks for your support!


DONORS
======

`Faculty of Information Technology, CTU Prague <https://www.fit.cvut.cz/en>`__

`WebExpo Conference, Prague <https://webexpo.net/>`__

`DATAMOLE, data mining & machine learning <https://www.datamole.cz/>`__


AUTHORS
=======

-  Pavel Petrzela, paulo@internetguru.io

-  George J. Pavelka, george@internetguru.io
