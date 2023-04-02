# Internet Guru Flow

| branch  | status |
| :------------- | :------------- |
| master | ![tests](https://github.com/internetguru/flow/actions/workflows/test.yml/badge.svg?branch=master) |
| dev | ![tests](https://github.com/internetguru/flow/actions/workflows/test.yml/badge.svg?branch=dev) |

Advance in [git flow branching model](http://nvie.com/posts/a-successful-git-branching-model/) with ease! Maintain branches, semantic versioning, releases, and changelog with a single command.

### Git flow automation

- It has a simple usage that *requires no arguments* picking a default action for you.
- It takes you across branches with the flow and advises what to do next.
- It creates GitHub pull requests instead of releasing directly when asked.
- It maintains separate production branches for major versions, such as 'prod-1'.
- It supports parallel hotfixing, even for separate production branches.

### Branching model validation

- It validates and automatically *fixes projects* to conform to the branching model.
- It pulls and pushes all key model branches and checks whether local branches are not behind.
- It handles [semantic versioning](https://semver.org) across all key branches.
- It keeps track of a release history with the [Keep a CHANGELOG](https://keepachangelog.com/en) convention.

### Setup and configuration

- It can initiate a git flow branching repository on any selected folder.
- It can convert an existing git repository into a git flow branching model.
- It automatically adapts to pre-existing branches, such as 'release' instead of the default 'staging'.


## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Installation](#installation)
  - [Requirements](#requirements)
  - [Single file script](#single-file-script)
  - [Compiled distribution package](#compiled-distribution-package)
  - [Building from source](#building-from-source)
- [Contributing](#contributing)
- [Copyright](#copyright)
- [Donation](#donation)
  - [Honored donors](#honored-donors)
- [Alternatives](#alternatives)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Installation

Download the [latest release from GitHub](https://github.com/internetguru/flow/releases/latest). You can install as a single file (easiest), with compiled distribution package (useful for system-wide install) or from the source.


### Requirements

- [Bash](https://www.gnu.org/software/bash/), version 3.2 and later
- [Git](https://git-scm.com/), version 1.8.0 and later
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
./configure && make && compiled/install
```

You can specify following variables for `make` command which will affect default parameters of `install` script:

- `PREFIX`: Installation prefix, `/usr/local` by default.
- `BINDIR`: Location for `flow` script, `$PREFIX/bin` by default.

For example like this:

```bash
PREFIX=/usr make
```

See the [man page](flow.1.rst) for more information and examples.


## Contributing

Pull requests are welcome. Don't hesitate to contribute.


## Copyright

Copyright © 2016--2023 [Internet Guru](https://www.internetguru.io)

This software is licensed under the CC BY-NC-SA license. There is NO WARRANTY, to the extent permitted by law. See the [LICENSE](LICENSE) file.

For commercial use of this software, training, and custom development, please contact the authors at info@internetguru.io


## Donation

If you find this script useful, please consider making a donation to support its developers. We appreciate any contributions, no matter how small. Donations help us to dedicate more time and resources to this project, including covering our infrastructure expenses.

- [PayPal Donation](https://www.paypal.com/donate/?hosted_button_id=QC7HU967R4PHC)

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
