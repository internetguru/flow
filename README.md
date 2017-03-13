# Oh My Git Flow _(OMGF)_

[![Build Status](https://travis-ci.org/InternetGuru/omgf.svg?branch=master)](https://travis-ci.org/InternetGuru/omgf)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Use Git Flow with ease – maintain branches, semantic versioning, releases, and changelog with a single command.

Oh My Git Flow (aka _OMGF_) is the simplest way to use [Git Flow branching model][model]. When you run OMGF in a git repository, the tool will check the current state of your repo and executes appropriate commands.

OMGF can:
- initialize new or existing Git repository for Git Flow,
- automatically create and merge feature, hotfix and release branches,
- create version tags for releases,
- maintain a [semantic version numbering][semver] for releases and `VERSION` file,
- push and pull all main branches,
- give you a pull request link,
- help you maintain a human-readable `CHANGELOG.md` file following the [Keep a CHANGELOG][keepachangelog] format,
- recommend you how to proceed with development from the current state,
- maintain multiple hotfix branches,
- maintain independent production branches.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Installation](#installation)
  - [Single file script](#single-file-script)
  - [Compiled distribution package](#compiled-distribution-package)
  - [Building from source](#building-from-source)
- [Setup](#setup)
- [Usage](#usage)
- [Alternatives](#alternatives)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [Donation](#donation)
  - [Donors](#donors)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Installation

Download the [latest release from GitHub](https://github.com/InternetGuru/omgf/releases/latest).

You can install OMGF as a single file (easiest), with compiled distribution package (useful for system-wide install) or from source.

### Single file script

1. Place `omgf.sh` into your `$PATH` (e.g. `~/bin`),
2. make the script executable:
   ```
   chmod +x omgf.sh
   ```
3. optionally rename the file to `omgf` or `gf` (unless you wish to [setup alias](#setup-alias)).

### Compiled distribution package

1. Extract `omgf-*-linux.tar.gz`,
2. run `./install` script as root; this will install OMGF system-wide into `/usr/local`

You can also override installation paths using environment variables:

- `BINPATH`: where `omgf` script will be placed; `/usr/local/bin` by default
- `SHAREPATH`: where folder for support files will be placed;  `/usr/local/share` by default
- `USRMANPATH`: where manpage will be placed; `$SHAREPATH/man/man1` by default.

For example to install OMGF without root permissions, use this:

```shell
BINPATH=~/bin SHAREPATH=~/.local/share ./install
```

### Building from source

You will need the following dependencies:

- GNU Make
- `rst2man` (available in Docutils, e.g. `apt-get install python-docutils` or `pip install docutils`)

```shell
git clone https://github.com/InternetGuru/omgf.git
cd omgf
./configure        # Checks for build dependencies
make               # Creates distribution package into compiled/
compiled/install   # Installs distribution
```

You can specify following variables for make command which will affect default parameters of `install` script:

- `PREFIX`: Installation prefix; `/usr/local` by default
- `BINDIR`: Location for `omgf` script; `$PREFIX/bin` by default

## Setup

It is generally useful to alias `omgf` to `gf` in your shell to set default parameters.

Place the following in your shell configuration file (e.g. `~/.bash_aliases`, `~/.bashrc` or `~/.zshrc`):
```
alias gf="omgf --what-now"
```

You can find more options in the [man page][man], though the generally useful defaults are:

* `--request`: Current branch won't be merged but prepared for a pull request and pushed to origin.
* `--what-now`: OMGF will display what you can do on current branch after performing an operation.
* `--yes`: OMGF won't ask you to confirm operations (only recommended for advanced users).

## Usage

The following examples assume you have `omgf` alias to `gf` (see [Setup](#setup)).

Initialize Git Flow in the existing repo:
```shell
gf --init
```

```
***
* Current branch 'dev' is considered as developing branch.
* - Do some bugfixes...
* - Run 'omgf MYFEATURE' to create new feature.
* - Run 'omgf release' to create release branch.
***
```
</details>

On `dev` branch, start a feature branch:
```shell
gf my-new-feature
```
```
* Create branch 'feature-my-new-feature' from branch 'dev'? [YES/No] y
***
* Current branch 'feature-my-new-feature' is considered as feature branch.
* - Develop current feature...
* - Run 'omgf' to merge it into 'dev'.
***
```

Develop new feature:
```
$ echo "new feature code" > myfile
$ git add myfile
$ git commit -m "insert myfeature function"
```

Merge feature branch to `dev` with entry to Changelog:
```shell
gf
```
```
* Merge feature 'feature-my-new-feature' into 'dev'? [YES/No] y

***
* Please enter the feature-my-new-feature description for CHANGELOG.md.
*
* Keywords:
*   Added (default), Changed, Deprecated, Removed, Fixed, Security
*
* Commits of 'feature-my-new-feature':
*   f0690b5 insert myfeature function
*
Type "Keyword: Message", empty line to end:
My new feature
f: Project was empty
```

On `dev`, start a release branch:
```shell
gf release
```
```
* Create branch 'release' from current HEAD? [YES/No] y
***
* Current branch 'release' is considered as release branch.
* - Do some bugfixes...
* - Run 'omgf' to merge only into 'dev'.
* - Run 'omgf release' to create stable branch.
***
```

Make a stable release from `release` branch:
```shell
gf release
```
```
gf release
* Create stable branch from release? [YES/No] y
***
* Current branch 'dev' is considered as developing branch.
* - Do some bugfixes...
* - Run 'omgf MYFEATURE' to create new feature.
* - Run 'omgf release' to create release branch.
***
```

<details>
<summary>Resulting Git history graph</summary>
```
*   Merge branch 'release' into dev  (HEAD -> dev)
|\  
| | *   Merge branch 'release'  (tag: v0.1.0, master)
| | |\  
| | |/  
| |/|   
| * | Update CHANGELOG.md header 
| * | Increment version number 
|/ /  
* |   Merge branch 'feature-my-new-feature' into dev 
|\ \  
| |/  
|/|   
| * Update CHANGELOG.md 
| * insert myfeature function 
|/  
* Initializing 'CHANGELOG.md' file  (tag: v0.0.0)
* Initializing 'VERSION' file 
```
</details>

See the [man page][man] for more information and examples.

## Alternatives

- [git-flow](https://github.com/nvie/gitflow) – The original Vincent Driessen's tools.
- [git-flow (AVH Edition)](https://github.com/petervanderdoes/gitflow-avh) – Maintained fork of the original tools.
  - See also [cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [HubFlow](https://datasift.github.io/gitflow/) – Git Flow for GitHub by DataSift.
- [gitflow4idea](https://github.com/OpherV/gitflow4idea/) – Plugin for JetBrains IDEs.
- [GitKraken](https://www.gitkraken.com/) – Cross-platform Git GUI with [Git Flow operations](https://support.gitkraken.com/repositories/git-flow).
- [SourceTree](https://www.sourcetreeapp.com/) – Git GUI for macOS and Windows with Git Flow support.
- [GitFlow for Visual Studio](https://marketplace.visualstudio.com/items?itemName=vs-publisher-57624.GitFlowforVisualStudio2017)

## Maintainers

-  Pavel Petržela pavel.petrzela@internetguru.cz
-  Jiří Pavelka jiri.pavelka@internetguru.cz

## Contributing

Pull requests are welcome, don't hesitate to contribute.

When editing the README file, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## Donation

If you find this program useful, please **send a donation** to its developers to support their work. If you use this program at your workplace, please suggest that the company make a donation. We appreciate contributions of any size. Donations enable us to spend more time working on this package, and help cover our infrastructure expenses.

If you’d like to make a donation of any value, please send it to the following PayPal address:

[PayPal Donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=G6A49JPWQKG7A)

Since we aren’t a tax-exempt organization, we can’t offer you a tax deduction. But for all donations over 50 USD, we’d be happy to recognize your contribution on this README file (including manual page) for the next release.

We are also happy to consider making particular improvements or changes, or giving specific technical assistance, in return for a substantial donation over 100 USD. If you would like to discuss this possibility, write us at info@internetguru.cz.

Another possibility is to pay a software maintenance fee. Again, write us about this at info@internetguru.cz to discuss how much you want to pay and how much maintenance we can offer in return.

Thanks for your support!

### Donors

- [Faculty of Information Technology, CTU Prague](https://www.fit.cvut.cz/en)
- [WebExpo Conference, Prague](https://webexpo.net/)
- [DATAMOLE, data mining & machine learning](https://www.datamole.cz/)

## License

GNU General Public License version 3, see the [LICENSE file](LICENSE).


[omgf]: https://github.com/InternetGuru/omgf
[latest]: https://github.com/InternetGuru/omgf/releases/latest
[man]: https://github.com/InternetGuru/omgf/blob/master/omgf.1.rst
[model]: http://nvie.com/posts/a-successful-git-branching-model/
[cheatsheet]: http://danielkummer.github.io/git-flow-cheatsheet/
[semver]: http://semver.org/
[keepachangelog]: http://keepachangelog.com/en/0.3.0/
