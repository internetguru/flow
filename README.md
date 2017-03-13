# Oh My Git Flow

[![Build Status](https://travis-ci.org/InternetGuru/omgf.svg?branch=master)](https://travis-ci.org/InternetGuru/omgf)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Use Git Flow with ease. OMGF helps you maintain branches, semantic versioning, releases, and changelog file with a single command.

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
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
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

## Usage

> See [man page][man] for more informations and examples.

```shell
# Set default options
alias gf="omgf --verbose --what-now"

# Initialize OMGF
gf --init

# Create a feature
gf

# Develop new feature
echo "new feature code" >> myfile
git add myfile
git commit -m "insert myfeature function"

# Merge feature
gf
```

## Maintainers

-  Pavel Petržela pavel.petrzela@internetguru.cz
-  Jiří Pavelka jiri.pavelka@internetguru.cz

## Contribute

Pull requests are wellcome, don't hesitate contribute.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

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

GNU Public License version 3, see [LICENSE][license]


[omgf]: https://github.com/InternetGuru/omgf
[latest]: https://github.com/InternetGuru/omgf/releases/latest
[license]: https://raw.githubusercontent.com/InternetGuru/omgf/master/LICENSE
[man]: https://github.com/InternetGuru/omgf/blob/master/omgf.1.rst
[model]: http://nvie.com/posts/a-successful-git-branching-model/
[cheatsheet]: http://danielkummer.github.io/git-flow-cheatsheet/
[semver]: http://semver.org/
[keepachangelog]: http://keepachangelog.com/en/0.3.0/
