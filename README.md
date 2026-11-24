# Internet Guru Flow

| branch  | status |
| :------------- | :------------- |
| master | ![tests](https://github.com/internetguru/flow/actions/workflows/test.yml/badge.svg?branch=master) |
| dev | ![tests](https://github.com/internetguru/flow/actions/workflows/test.yml/badge.svg?branch=dev) |

Advance in a branching model. Flow acts on the current branch, or on the branch given with `--branch`. Without an argument, it advances that branch; with a NAME, it creates a new feature or hotfix branch NAME on that branch's line.

Additionally, Flow handles version incrementing and maintains a changelog. Before proceeding, it verifies the current repository for branching model compliance and offers to correct any detected imperfections.

- [Usage](#usage)
- [Installation](#installation)
- [Flow options](https://github.com/internetguru/flow/blob/dev/flow.1.rst#options)
- [Usage example](https://github.com/internetguru/flow/blob/dev/flow.1.rst#flow-example)
- [Blog posts on Flow](https://blog.internetguru.io/categories/flow/)

### Branching model automation

- Flow requires *no arguments* and derives the action from the branch it acts on.
- Flow switches between branches accordingly and advises what to do next.
- Flow can create pull requests instead of releasing directly.
- Flow maintains separate production branches for major versions, such as `main-1`.
- Flow supports parallel hotfixing, even for separate production branches.

### Branching model validation

 - Flow validates and automatically *fixes project structures* to conform to the branching model.
 - Flow pulls and pushes all key branches and checks whether local branches are not behind.
 - Flow handles [semantic versioning](https://semver.org/) across all key branches. Read more about [version handling with Flow](https://blog.internetguru.io/2023/04/05/flow-version/).
 - Flow keeps track of a release history with the [Keep a CHANGELOG](https://keepachangelog.com/en/) convention. Read more about [changelog handling with Flow](https://blog.internetguru.io/2023/04/08/flow-changelog/).

### Setup and configuration

 - Flow can initiate a git branching repository in any folder with or without files.
 - Flow can convert any existing git repository to a git branching model.
 - Flow automatically adapts to existing branches, such as 'release' instead of the default 'staging'.

## Usage

```
flow [OPTIONS] [-b BRANCH] [NAME]
```

Flow acts on BRANCH, the current branch by default.

| Acted-on branch | `flow` | `flow NAME` |
| :--- | :--- | :--- |
| `dev` | release a candidate to `staging` | create feature NAME from `dev` |
| `staging` | release to `main` and tag it | error |
| `main` or `main-N` | create hotfix `hotfix-USER` from it | create hotfix NAME from it |
| a feature | merge it into `dev` | create feature NAME from `dev` |
| a hotfix | release it as a patch version | create hotfix NAME from its production branch |

- NAME must not exist yet, locally or on origin. `feature` and `hotfix` are too generic to be a NAME, and key branch names are reserved.
- A feature always needs a NAME; only a hotfix has a default name.
- Several hotfixes can be open at once, also while `staging` is released. Releasing one merges the production branch into it first.

Examples:

```bash
flow login-form            # on dev: create feature 'login-form'
flow                       # on login-form: merge it into dev
flow -b dev                # from any branch: release dev to staging
flow -b main               # from any branch: create hotfix 'hotfix-USER' from main
flow -b main broken-link   # from any branch: create hotfix 'broken-link' from main
flow -b broken-link        # from any branch: release hotfix 'broken-link'
```

See the [options](flow.1.rst#options) and the [usage example](flow.1.rst#flow-example) in the man page.

### Upgrading from Flow 3

Flow 4 no longer takes a branch as the argument; the argument is always a new branch name.

| Flow 3 | Flow 4 |
| :--- | :--- |
| `flow feature` | `flow NAME` on `dev` (a feature needs a name) |
| `flow hotfix` | `flow -b main` to create `hotfix-USER`, `flow -b hotfix-USER` to release it |
| `flow dev`, `flow staging`, `flow main-1` | `flow -b dev`, `flow -b staging`, `flow -b main-1` |
| `flow mybranch` to finish an existing branch | `flow -b mybranch` |

## Installation

Download the [latest release from GitHub](https://github.com/internetguru/flow/releases/latest). You can install as a single file (easiest), with compiled distribution package (useful for system-wide install) or from the source.

### Requirements

- [Bash](https://www.gnu.org/software/bash/), version 3.2 or later
- [Git](https://git-scm.com/), version 1.8.0 or later
- [GNU getopt](http://frodo.looijaard.name/project/getopt)
  - On macOS install with Homebrew ([`gnu-getopt`](http://braumeister.org/formula/gnu-getopt)) or with [MacPorts](https://www.macports.org/) (`getopt`)
- [GNU sed](https://www.gnu.org/software/sed/)
  - On macOS install with Homebrew [`gnu-sed`](http://braumeister.org/formula/gnu-sed)
- [GNU awk](https://www.gnu.org/software/gawk/)
  - On macOS install with Homebrew [`homebrew/dupes/grep`](https://github.com/Homebrew/homebrew-dupes)

### Single file script

1. Place flow.sh into your `$PATH` (e.g. `~/bin`).
2. Make the script executable.
   ```bash
   chmod +x flow.sh
   ```

### Compiled distribution package

1. Extract the archive.
   ```bash
   tar -xvzf flow-*-linux.tar.gz
   ```
2. run `install` script as root; this will proceed a system-wide installation into `/usr/local`.
   ```bash
   cd flow-*-linux
   sudo ./install
   ```

You can override installation paths using environment variables.

- `BINPATH`: where the script will be placed, `/usr/local/bin` by default.
- `SHAREPATH`: where support files will be placed, `/usr/local/share` by default.
- `USRMANPATH`: where manpage will be placed, `$SHAREPATH/man/man1` by default.

This is how to install the script without root permissions.

```bash
BINPATH=~/bin SHAREPATH=~/.local/share ./install
```

### Building from source

You will need the following dependencies:

- GNU Make
- `rst2man` (available in Docutils, e.g. `apt-get install python-docutils` or `pip install docutils`)

```bash
git clone https://github.com/internetguru/flow.git
cd flow
./configure && make && sudo compiled/install
```

You can specify following variables for `make` command which will affect default parameters of `install` script:

- `PREFIX`: Installation prefix, `/usr/local` by default.
- `BINDIR`: Location for `flow` script, `$PREFIX/bin` by default.

For example like this:

```bash
PREFIX=/usr make
```

See the [man page](flow.1.rst) for more information and examples.

### Running unit tests

Testing the script requires a built 'flow' command and [Bash Unit Testing Tool](https://github.com/internetguru/butt) -- AKA the 'butt' command.

```bash
butt ~/flow/test/test.butt
```

## Contributing

Pull requests are welcome. Don't hesitate to contribute.

## License & Commercial Terms

### License

Copyright © 2026 **Internet Guru**

This software is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](http://creativecommons.org/licenses/by-nc-sa/4.0/) license.

> **Disclaimer:** This software is provided "as is", without warranty of any kind, express or implied. In no event shall the authors or copyright holders be liable for any claim, damages or other liability.

### Commercial Use

The standard CC BY-NC-SA license prohibits commercial use. If you wish to use this software in a commercial environment or product, we offer **flexible commercial licenses** tailored to:

* Your company size.
* The nature of your project.
* Your specific integration needs.

**Note:** In many instances (especially for startups or small-scale tools), this may result in no fees being charged at all. Please contact us to obtain written permission or a commercial agreement.

**Contact for Licensing:** [info@internetguru.io](mailto:info@internetguru.io)

### Professional Services

Are you looking to get the most out of this project? We are available for:

* **Custom Development:** Tailoring the software to your specific requirements.
* **Integration & Support:** Helping your team implement and maintain the solution.
* **Training & Workshops:** Seminars and hands-on workshops for your developers.

Reach out to us at [info@internetguru.io](mailto:info@internetguru.io) — we are more than happy to assist you!

## Donation

If you find this script useful, please consider making a donation to support its developers. We appreciate any contributions, no matter how small. Donations help us to dedicate more time and resources to this project, including covering our infrastructure expenses.

[PayPal Donation](https://www.paypal.com/donate/?hosted_button_id=QC7HU967R4PHC)

Please note that we are not a tax-exempt organization and cannot provide tax deductions for your donation. However, for donations exceeding $500, we would like to acknowledge your contribution on project's page and in this file (including the man page).

Thank you for your continued support!

### Honored donors

- [Czech Technical University in Prague](https://www.fit.cvut.cz/en)
- [WebExpo Conference in Prague](https://webexpo.net/)
- [DATAMOLE data mining and machine learning](https://www.datamole.cz/)

## Alternatives

- [git-flow](https://github.com/nvie/gitflow) – The original Vincent Driessen's tools.
- [git-flow (AVH Edition)](https://github.com/petervanderdoes/gitflow-avh) – Maintained fork of the original tools.
  - See also [cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [HubFlow](https://datasift.github.io/gitflow/) – Git Flow for GitHub by DataSift.
- [gitflow4idea](https://github.com/OpherV/gitflow4idea/) – Plugin for JetBrains IDEs.
- [GitKraken](https://www.gitkraken.com/) – Cross-platform Git GUI with [Git Flow operations](https://support.gitkraken.com/repositories/git-flow).
- [SourceTree](https://www.sourcetreeapp.com/) – Git GUI for macOS and Windows with Git Flow support.
- [GitFlow for Visual Studio](https://marketplace.visualstudio.com/items?itemName=vs-publisher-57624.GitFlowforVisualStudio2017)
