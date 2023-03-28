NAME
====

flow - manage git flow branching model


SYNOPSIS
========

flow [-cfhinrvVwy] [--color[=WHEN]] [ACTION [NAME]]


DESCRIPTION
===========

Advance the git flow branching model according to its current state and branch (unless ACTION argument is specified). Maintain the model conformity through merging, semantic versioning, and keeping a changelog.


ARGUMENTS
=========

Default ACTION value is branch name (the part before the first dash if present). Default NAME is current user name (command ``whois``).

feature|dev [NAME]
    Release branch ``feature-NAME`` if currently on it.
    Else checkout the branch if it exists.
    Else create the branch and checkout.

staging|release|rc|preprod
    Release branch dev branch if currently on it.
    Else release the staging branch if on it and is not merged.
    Else checkout the staging branch.

hotfix|main|master|production|prod|live [NAME]
    Release branch ``hotfix-NAME`` if currently on it.
    Else checkout the branch if it exists.
    Else create the branch and checkout.

pull|fetch
    Pull all from the remote repository.

push
    Push all to the remote repository.


OPTIONS
=======

\-c, --conform
    Repair (initialize) project to be conform with git flow branching model and proceed.

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


EXIT CODES
==========

0
    No problems occurred.
1
    Generic error code.
2
    Parse or invalid option error.
3
    Git is not conform with the branching model (fixable).
4
    Git is not conform with the branching model (unfixable).
5
    Git status is not empty AKA uncommitted changes.
6
    Nothing to do (e. g. empty merge).


REPOSITORY
==========

`GitHub repository <https://github.com/internetguru/flow/>`__


AUTHOR
======

Written by Pavel Petrzela and George J. Pavelka.


REPORTING BUGS
==============

`Issue tracker <https://github.com/internetguru/flow/issues>`__


COPYRIGHT
=========

Copyright © 2016--2023 `Internet Guru <https://www.internetguru.io>`__

This software is licensed under the CC BY-NC-SA license. There is NO WARRANTY, to the extent permitted by law. See the LICENSE file.

For commercial use of this software, training, and custom development, please contact the authors at info@internetguru.io


DONATION
========

If you find this script useful, please consider making a donation to support its developers. We appreciate any contributions, no matter how small. Donations help us to dedicate more time and resources to this project, including covering our infrastructure expenses.

`PayPal Donation <https://www.paypal.com/donate/?hosted_button_id=QC7HU967R4PHC>`__

Please note that we are not a tax-exempt organization and cannot provide tax deductions for your donation. However, for donations exceeding $500, we would like to acknowledge your contribution on project's page and in this file (including the man page).

Thank you for your continued support!


HONORED DONORS
==============

`Czech Technical University in Prague <https://www.fit.cvut.cz/en>`__

`WebExpo Conference in Prague <https://webexpo.net/>`__

`DATAMOLE data mining and machine learning <https://www.datamole.cz/>`__


FLOW EXAMPLE
============

1. Initialize the branching model on an empty folder::

    mkdir a
    cd a
    flow --init --yes

This creates a git repository with key branches and a tag. The default version number is ``0.0.0`` on all branches except for dev where it is ``0.1.0``. The --yes option servers to skip prompting individual steps.

2. Create and release a feature::

    flow --yes feature
    touch a
    git add a
    git commit -m "Add file a"
    flow --yes --auto-entry feature

This creates a feature branch from dev and merges it back after changes are made. Without the --yes and the --auto-entry options, it prompts for a confirmation and a changelog entry respectively.

Note: Technically, there is no need to use the 'feature' argument in either of occurrences above. Why? Because the initialization in step 1 finishes on the dev branch, where creating a feature is the default action. From feature branches, the default action is to release it. Use the --what-now option to find out more about individual branches.

3. Fix some bugs on dev and release it::

    touch b
    git add b
    git commit -m "Add file b"
    flow --yes staging

This makes changes and commits directly to dev branch and releases it. This time the 'staging' argument is necessary, because the default action for the dev branch is to create or checkout a feature.

Notice the version number ``0.1.0`` from dev branch moves to the staging branch and gets incremented on dev to ``0.2.0``. Stable branches still have ``0.0.0``. You can use the following set of commands to check it up::

    git show dev:VERSION
    git show staging:VERSION
    git show main:VERSION

4. Fix some bugs on the staging branch and release::

    touch c
    git add c
    git commit -m "Add file c"
    flow --yes --conform

In theory, every commit of the staging branch must be merged into dev. The scriptrecognizes the unmerged state and fix it using the --conform option. At the same time it advances with releasing as a default action on staging branch.

Note: The staging branch, the 'prod-0', and the main are now on the same commit. There is also a tag with the newly released version number. Seems a little too far fetched? It will make more sense over time as the project grows.

5. Hotfix the production::

    flow --yes hotfix
    touch d
    git add d
    git commit -m "Add file d"
    flow --yes --auto-entry

This increments the patch version and merges the hotfix to the main branch, creates a tag and advances all attached branches with it. To keep the model compliant, it also merges the main branch into dev.

Note: The git log now looks like spiders on the wall. It gets a better shape with real data. If you want to see it, you can use the following command::

    git log --oneline --decorate --color --graph --all

