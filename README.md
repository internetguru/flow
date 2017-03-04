# Oh My Git Flow

[![Build Status](https://travis-ci.org/InternetGuru/omgf.svg?branch=master)](https://travis-ci.org/InternetGuru/omgf)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> TODO short description

[Oh My Git Flow][omgf] (hereinafter referred as the 'OMGF') applies [git flow branching model][model] according to KEYWORD and NAME parameters. Both parameters are
optional (TODO see PARAMETERS below).

OMGF is an alternative to [git-flow cheatsheet][cheatsheet] command with following improvements:
-  even simpler usage (no parameters are required),
-  push and pull all main branches,
-  pull request support,
-  validate and repair project to conform the model,
-  automatic [semantic version numbering][semver] (file VERSION),
-  version history update support (file CHANGELOG.md),
-  version history follows [Keep a CHANGELOG][keepachangelog] principle,
-  tips how to proceed with development on current state,
-  independent production branches support,
-  parallel hotfix branches support.

Basic OMGF feature list:
- creating and merging standard branches,
- creating standard tags.


## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [Donations](#donations)
  - [Donors](#donors)
- [License](#license)

## Install

> TODO short description

### Single file script

```shell
TODO single file url
```

### From distribution package

```shell
./install
./uninstall
```

### From source

```shell
./configure && make && compiled/install
```

## Usage

> TODO short description

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
[license]: https://raw.githubusercontent.com/InternetGuru/omgf/master/LICENSE
[model]: http://nvie.com/posts/a-successful-git-branching-model/
[cheatsheet]: http://danielkummer.github.io/git-flow-cheatsheet/
[semver]: http://semver.org/
[keepachangelog]: http://keepachangelog.com/en/0.3.0/
