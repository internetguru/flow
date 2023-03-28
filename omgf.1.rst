NAME
====

Oh My Git Flow


SYNOPSIS
========

omgf [-cfhinrvVwy] [--color[=WHEN]] [KEYWORD [NAME]]


DESCRIPTION
===========

**Oh My Git Flow**\ [1] (AKA 'OMGF') maintains the **git flow branching model**\ [2] including versioning and keeping a changelog (using editor or STDIN). It advances the model according to the current state, branch, and arguments.

OMGF is an alternative to the *git-flow cheatsheet*\ [3] command with the following features:

* It has a simple usage and **requires no arguments** (has a decision tree).

* It validates and automatically **fixes projects** to conform to the branching model.

* It can initiate a git flow branching on an empty foler or an existing git repository.

* It can convert an existing repository into a git flow branching model.

* It helps to pull and push all main branches.

* It supports **merge requests** (pull requests) for GitHub and GitLab.

* It controls **semantic versioning**\ [4] in a ``VERSION`` file.

* It keeps track of release history following the **Keep a CHANGELOG**\ [5] convention.

* It shows information and what to do on the current branch.

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
    omgf --init --yes

This creates a git repository with key branches and a tag. The default version number is ``0.0.0`` on all branches except for dev where it is ``0.1.0``. The --yes option servers to skip prompting individual steps.

2. Create and release a feature::

    omgf --yes feature
    touch a
    git add a
    git commit -m "Add file a"
    omgf --yes --auto-entry feature

This creates a feature branch from dev and merges it back after changes are made. Without the --yes and the --auto-entry options, it prompts for a confirmation and a changelog entry respectively.

Note: Technically, there is no need to use the 'feature' argument in either of occurrences above. Why? Because the OMGF initialization in step 1 finishes on the dev branch, where creating a feature is the default action. From feature branches, the default action is to release it. Use the --what-now option to find out more about individual branches.

3. Fix some bugs on dev and release it::

    touch b
    git add b
    git commit -m "Add file b"
    omgf --yes staging

This makes changes and commits directly to dev branch and releases it. This time the 'staging' argument is necessary, because the default action for the dev branch is to create or checkout a feature.

Notice the version number ``0.1.0`` from dev branch moves to the staging branch and gets incremented on dev to ``0.2.0``. Stable branches still have ``0.0.0``. You can use the following set of commands to check it up::

    git show dev:VERSION
    git show staging:VERSION
    git show main:VERSION

4. Fix some bugs on the staging branch and release::

    touch c
    git add c
    git commit -m "Add file c"
    omgf --yes --conform

In theory, every commit of the staging branch must be merged into dev. The scriptrecognizes the unmerged state and fix it using the --conform option. At the same time it advances with releasing as a default action on staging branch.

Note: The staging branch, the 'prod-0', and the main are now on the same commit. There is also a tag with the newly released version number. Seems a little too far fetched? It will make more sense over time as the project grows.

5. Hotfix the production::

    omgf --yes hotfix
    touch d
    git add d
    git commit -m "Add file d"
    omgf --yes --auto-entry

This increments the patch version and merges the hotfix to the main branch, creates a tag and advances all attached branches with it. To keep the model compliant, it also merges the main branch into dev.

Note: The git log now looks like spiders on the wall. It gets a better shape with real data. If you want to see it, you can use the following command::

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

[1] `OMGF on GitHub <https://github.com/internetguru/omgf/>`__

[2] `Git flow model <https://nvie.com/posts/a-successful-git-branching-model/>`__

[3] `Git flow cheatsheet <https://danielkummer.github.io/git-flow-cheatsheet/>`__

[4] `Semantic Versioning <https://semver.org/>`__

[5] `Keep a CHANGELOG <https://keepachangelog.com/en/0.3.0/>`__


REPORTING BUGS
==============

`Issue tracker <https://github.com/internetguru/omgf/issues>`__


COPYRIGHT
=========

Copyright (C) 2016--2023 `Internet Guru <https://www.internetguru.io>`__


LICENSE
=======

This software is licensed under the CC BY-NC-SA license. Visit the following link for details.

`Creative Commons Attribution-NonCommercial-ShareAlike <https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode>`__

For commercial use of this software, training, and custom development, please contact us at info@internetguru.io


DONATION
========

If you find this script useful, please consider making a donation to support its developers. We appreciate any contributions, no matter how small. Donations help us to dedicate more time and resources to this project, including covering our infrastructure expenses.

`PayPal Donation <https://www.paypal.com/donate/?hosted_button_id=QC7HU967R4PHC>`__

Please note that we are not a tax-exempt organization and cannot provide tax deductions for your donation. However, for donations exceeding $500, we would like to acknowledge your contribution on our OMGF page [1] and in this README file (including the manual page) for a specified period of time.

Thank you for your continued support!


HONORED DONORS
==============

`Faculty of Information Technology, CTU Prague <https://www.fit.cvut.cz/en>`__

`WebExpo Conference, Prague <https://webexpo.net/>`__

`DATAMOLE, data mining & machine learning <https://www.datamole.cz/>`__


AUTHORS
=======

-  Pavel Petrzela, paulo@internetguru.io

-  George J. Pavelka, george@internetguru.io
