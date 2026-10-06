# Flow

`flow` is a single Bash script; `flow.1.rst` is its man page and `test/test.butt` its tests
(run with [butt](https://github.com/internetguru/butt): `butt test/test.butt`).

## Branches, versions and changelog

This repository is managed by [Flow](https://github.com/internetguru/flow). Follow the
`ig-flow` and `ig-changelog` skills from
[internetguru/laravel-scripts](https://github.com/internetguru/laravel-scripts/tree/main/resources/boost/skills)
for branches, commits, releases, `VERSION` and `CHANGELOG.md`. If you don't have them,
download them first and read them:

```bash
for s in ig-flow ig-changelog; do
  mkdir -p ~/.claude/skills/$s
  curl -fsSL "https://raw.githubusercontent.com/internetguru/laravel-scripts/main/resources/boost/skills/$s/SKILL.md" \
    -o ~/.claude/skills/$s/SKILL.md
done
```
