NAME
====

Flow - manage git branching model


SYNOPSIS
========

flow [-cefhinrvVwy] [--color[=WHEN]] [--push] [--pull] [BRANCH]


DESCRIPTION
===========

Advance in a branching model according to the current branch or a branch specified with an argument. For most existing branches, the default action is release. If a given branch does not exist, Flow creates it as a feature or a hotfix depending on the current branch or a keyword (feature/hotfix).

Additionally, Flow handles version incrementing and maintains a changelog. Before proceeding, it verifies the current repository for branching model compliance and offers to correct any detected imperfections.

`Read more about Flow <https://blog.internetguru.io/tags/flow/>`__


OPTIONS
=======

\-c, --conform
    Repair (initialize) project to be conform with git flow branching model and proceed.

\--color[=WHEN], --colour[=WHEN]
    Use markers to highlight command status; WHEN is 'always', 'never', or 'auto'. Empty WHEN sets color to 'always'. Default color value is 'auto'.

\-e, --auto-entry
    Do not show changelog editor and insert general entry instead about the current action.

\-f, --force
    Clear and restore uncommitted changes before proceeding using git stash.

\-h, --help
    Print help.

\-i, --init
    Same as 'conform', but also initialize git repository if not exists and do not proceed with any action.

\-n, --dry-run
    Do not run commands; only parse user options and arguments.

\--pull
    Pull all remote branches.

\--push
    Push all branches.

\-r, --request
    Instead of merging prepare current branch for pull request and push it to the origin.

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

`Flow on GitHub repository <https://github.com/internetguru/flow/>`__


REPORTING BUGS
==============

`Issue tracker <https://github.com/internetguru/flow/issues>`__


AUTHOR
======

Written by Pavel Petrzela and George J. Pavelka.


COPYRIGHT
=========

Copyright © 2016--2023 `Internet Guru <https://www.internetguru.io>`__

This software is licensed under the CC BY-NC-SA license. There is NO WARRANTY, to the extent permitted by law. See the LICENSE file.

For commercial use, a nominal fee may be applicable based on the company size and the nature of their product. In many instances, this could result in no fees being charged at all. Please contact us at info@internetguru.io for further information.

Please do not hesitate to reach out to us for inquiries related to seminars, workshops, training, integration, support, custom development, and additional services. We are more than happy to assist you.


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

    mkdir myflow
    cd myflow
    flow --init --yes

This creates a git repository with key branches and a tag. The default version number is ``0.0.0`` on all branches except for dev, where it is ``0.1.0``. The --yes option serves to skip prompting individual steps.

2. Create and release a feature::

    flow --yes feature
    touch a
    git add a
    git commit -m "Add file a"
    flow --yes --auto-entry

This creates a feature branch from dev and merges it back after changes are made. Without the --yes and the --auto-entry options, Flow prompts for a confirmation and a changelog entry respectively.

3. Fix some bugs on dev and release it::

    touch b
    git add b
    git commit -m "Add file b"
    flow --yes

This makes changes directly on development branch and releases it. No argument is necessary as releasing is the default action for most branches.

Notice the version number ``0.1.0`` from dev branch moves to the staging branch and gets incremented on dev to ``0.2.0``. The stable branch (main) is still ``0.0.0``. You can use the following set of commands to check it::

    git show dev:VERSION
    git show staging:VERSION
    git show main:VERSION

4. Fix some bugs on the staging branch and release::

    touch c
    git add c
    git commit -m "Add file c"
    flow --yes --conform

Ideally, every commit of the staging branch must be merged into dev. The script recognizes the unmerged state and fixes it using the --conform option while advancing with the release.

Note: The staging branch and both production branches ('main' and 'main-0') are now on the same commit. There is also a tag with the newly released version number. This may seem a little far fetched. It will make more sense over time as the project grows.

5. Hotfix the production::

    flow --yes hotfix
    touch d
    git add d
    git commit -m "Add file d"
    flow --yes --auto-entry

This increments the patch version and merges the hotfix to the main branch, creates a tag and advances all attached branches with it. To keep the model compliant, it also merges the main branch into dev.

Note: The git log graph may now look somewhat confusing. It will make much more sense during real development. If you want to see it, use the following command::

    git log --oneline --decorate --color --graph --all

Note: Check out the resulting changelog file if you want. It contains the added feature, hotfix, and all releases. The changelog on the development branch has additionally an 'unreleased' section::

    git show main:CHANGELOG.md
    git diff main:CHANGELOG.md dev:CHANGELOG.md
