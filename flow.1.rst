NAME
====

Flow - manage git branching model


SYNOPSIS
========

flow [-cefhinrvVwy] [-b BRANCH] [--branch=BRANCH] [-l[WHEN]] [--changelog[=WHEN]] [--color[=WHEN]] [--push] [--pull] [NAME]


DESCRIPTION
===========

Advance in a branching model. Flow acts on the current branch, or on the branch given with the --branch option.

Without NAME, Flow advances that branch:

- dev: create or increment the release candidate on staging,
- staging: release to the production branch (main) and tag the version,
- production branch (main or main-N): create hotfix 'hotfix-USER' from it,
- hotfix: release it as a patch version,
- any other branch: merge it as a feature into dev.

With NAME, Flow creates a new branch NAME on the line of that branch: a feature from dev when it acts on dev or on a feature, a hotfix from the production branch when it acts on a production branch or on a hotfix. NAME must not exist yet, locally or on origin. Names 'feature' and 'hotfix' are rejected as too generic, names of key branches are reserved, and no branch can be created from staging. NAME cannot be combined with --pull, --push, --init or --what-now, and --branch cannot be combined with --pull, --push or --init.

Flow tells a hotfix from a feature by where it forks: a hotfix forks from a tagged production commit, a feature from dev. Update a feature by merging dev into it, never the production branch. Several hotfixes can be open at once; releasing one first merges the production branch into it.

Releasing staging stops while a hotfix of the production branch is open, locally or on origin. Release or delete the hotfix first.

Additionally, Flow handles version incrementing and maintains a changelog. Before proceeding, it verifies the current repository for branching model compliance and offers to correct any detected imperfections.

`Read more about Flow <https://blog.internetguru.io/tags/flow/>`__


OPTIONS
=======

\-b BRANCH, --branch=BRANCH
    Act on BRANCH instead of the current branch. BRANCH must exist; key branch aliases such as 'master' or 'develop' resolve to the key branches.

\-c, --conform
    Repair (initialize) project to be conform with git flow branching model and proceed.

\-l[WHEN], --changelog[=WHEN]
    Prompt for a changelog entry when merging a feature or a hotfix; WHEN is 'always', 'never', or 'auto'. With 'auto', Flow prompts only if the branch adds no entry to the changelog itself (on a hotfix branch, write it under an '[Unreleased]' heading). With 'never', Flow adds no entry. Empty WHEN sets the value to 'always'. Default value is 'auto'. Option --auto-entry inserts a general entry wherever Flow would prompt.

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
    Instead of merging prepare the acted-on branch for pull request and push it to the origin.

\-v, --verbose
    Verbose mode.

\-V, --version
    Print version number.

\-w, --what-now
    Display what to do on the acted-on branch.

\-y, --yes
    Assume yes for all questions.


EXIT CODES
==========

0
    No problems occurred.
1
    Generic error code.
2
    Parse or invalid option or argument error, e.g. NAME already exists.
3
    Nonconforming, fixable with --conform / --init.
4
    Nonconforming, cannot be fixed automatically, e.g. an open hotfix blocks releasing staging.
5
    Uncommitted changes.
6
    Nothing to do, e. g. empty merge.
7
    Unexpected merge conflicts.

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

    flow --yes myfeature
    touch a
    git add a
    git commit -m "Add file a"
    flow --yes --auto-entry

This creates feature branch 'myfeature' from dev and merges it back after changes are made. A feature always needs a name. Without the --yes and the --auto-entry options, Flow prompts for a confirmation and a changelog entry respectively, unless the branch already adds a changelog entry.

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

    flow --yes --branch main
    touch d
    git add d
    git commit -m "Add file d"
    flow --yes --auto-entry

The first command creates hotfix branch 'hotfix-USER' from main and switches to it, the same as plain ``flow`` run on main. Running ``flow --yes login-fix`` on main would name it 'login-fix' instead. Releasing the hotfix increments the patch version and merges the hotfix to the main branch, creates a tag and advances all attached branches with it. To keep the model compliant, it also merges the main branch into dev.

Note: The git log graph may now look somewhat confusing. It will make much more sense during real development. If you want to see it, use the following command::

    git log --oneline --decorate --color --graph --all

Note: Check out the resulting changelog file if you want. It contains the added feature, hotfix, and all releases. The changelog on the development branch has additionally an 'unreleased' section::

    git show main:CHANGELOG.md
    git diff main:CHANGELOG.md dev:CHANGELOG.md
