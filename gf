#!/bin/bash

shopt -s extglob
shopt -s nocasematch
set -u

# shellcheck disable=SC2086
: ${GF_DATAPATH:=.}
# shellcheck disable=SC2086
: ${GF_CHANGELOG:=CHANGELOG.md}
# shellcheck disable=SC2086
: ${GF_VERSION:=VERSION}
# shellcheck disable=SC2086
: ${GF_DEV:=dev}
# shellcheck disable=SC2086
: ${GF_ORIGIN:=origin}
# shellcheck disable=SC2086
: ${GF_UPSTREAM:=$GF_ORIGIN}
# shellcheck disable=SC2086
: ${GF_OPTIONS:=}
# shellcheck disable=SC2086
: ${GF_CHANGELOG_HEADER:=# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).}
# shellcheck disable=SC2086
: ${GF_NOPREFIX:=}
: ${COLUMNS:=$(tput cols)}
: ${LINES:=$(tput lines)}

function main {

  function msg_start {
    [[ $verbose -eq 0 ]] && return
    if stdoutpipe || [[ $COLUMNS -lt 41 ]]; then
      echo -n "$1" && return 0
    fi
    echo -n "[ "
    save_cursor_position
    echo " ....  ] $1"
  }

  function msg_end {
    [[ $verbose -eq 0 ]] && return
    if stdoutpipe || [[ $COLUMNS -lt 41 ]]; then
      echo " [ $1 ]" && return 0
    fi
    set_cursor_position
    echo "$1"
  }

  function stdout_silent {
    [[ $verbose == 0 ]] && exec 5<&1 && exec 1>/dev/null
    return 0
  }

  function stdout_verbose {
    [[ $verbose == 0 ]] && exec 1<&5
    return 0
  }

  function err {
    echo "$(basename "${0}")[error]: $*" >&2
    return 1
  }

  function setcolor {
    local c
    c=${1:-always}
    case $c in
      always|never|auto)
        color=$c
        return 0
      ;;
    esac
    return 2
  }

  function stdoutpipe {
    readlink /proc/$$/fd/1 | grep -q "^pipe:"
  }

  function colorize {
    [[ $color == never ]] && echo -n "$1" && return
    [[ $color == auto ]] && stdoutpipe && echo -n "$1" && return
    local c
    c="${2:-$GREEN}"
    tput setaf "$c"
    echo -n "$1"
    tput sgr0
  }

  function clear_stdin {
    while read -r -t 0; do read -r; done
  }

  function save_cursor_position {
    local curpos oldstty
    curpos="1;1"
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" >/dev/tty
    # shellcheck disable=SC2162
    read -d"R" curpos </dev/tty
    stty "$oldstty"
    pos_x=$( echo "${curpos#??}" | cut -d";" -f1 )
    pos_y=$( echo "${curpos#??}" | cut -d";" -f2 )
  }

  function set_cursor_position {
    [[ "$pos_x" == "$LINES" ]] && : $(( pos_x-- ))
    tput cup $(( pos_x-1 )) $(( pos_y-1 ))
  }

  function strtolower {
    echo "$1" | tr '[:upper:]' '[:lower:]'
  }

  function trim {
    echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
  }

  function confirm {
    [[ $yes == 1 ]] && return 0
    if [[ $is_stdin == 0 ]]; then
      stdout_verbose
      echo -n "${1:-"Are you sure?"} [YES/No] "
      save_cursor_position
      clear_stdin
      read -r
      [[ -z "$REPLY" ]] && set_cursor_position && echo "yes"
      stdout_silent
    else
      read -r
    fi
    [[ "$REPLY" =~ ^y(es)?$ || -z "$REPLY" ]] && return 0
    [[ "$REPLY" =~ ^no?$ ]] && return 1
    confirm "Type"
  }

  function git_status_empty {
    [[ -z "$(git status --porcelain)" ]] \
      || err "Uncommitted changes"
  }

  # make git return only error to stderr
  function git_checkout {
    local out
    out="$(git checkout "$@" 2>&1)" \
      || err "$out"
  }

  # make git return only error to stderr
  function git_fetch {
    msg_start "Fetching $*"
    local out
    out="$(git fetch --update-head-ok "$@" 2>&1)" \
      || err "$out" \
      || return 1
    msg_end "$DONE"
  }

  # make git return only error to stderr
  function git_tag {
    local out
    out="$(git tag "$@" 2>&1)" \
      || err "$out"
  }

  # make git return only error to stderr
  function git_merge {
    local out
    out="$(git merge "$@" 2>&1)" \
      || err "$out"
  }

  function git_push {
    msg_start "Pushing $*"
    local out
    out="$(git push "$@" 2>&1)" \
      || err "$out" \
      || return 1
    msg_end "$DONE"
  }

  function git_checkout_branch {
    msg_start "Creating branch '$1'"
    git_checkout -b "$1" || return 1
    msg_end "$DONE"
  }

  function git_branch_create {
    local to
    to="${2:-HEAD}"
    msg_start "Creating branch '$1' on '$to'"
    git branch "$1" "$to"
    msg_end "$DONE"
  }

  function git_branch_exists {
    git rev-parse --verify "$1" >/dev/null 2>&1 && return 0
    git rev-parse --verify "$GF_ORIGIN/$1" >/dev/null 2>&1 \
      && git branch "$1" "$GF_ORIGIN/$1" >/dev/null 2>&1 || return 1
  }

  function git_tag_exists {
    git tag | grep -q "^$1"
  }

  function git_tag_here {
    git tag --points-at HEAD | grep -q "^$1$"
  }

  function git_repo_exists {
    [[ -d .git ]]
  }

  function git_remote_exists {
    git config remote."$GF_ORIGIN".url >/dev/null \
      || err "Remote url for '$GF_ORIGIN' does not exist" \
      || return 1
  }

  function git_remote_branch_exists {
    msg_start "Checking if '$gf_branch' exists on remote '$GF_ORIGIN'"
    git ls-remote --heads "$GF_ORIGIN" | grep -q "$REFSHEADS/$gf_branch"$ \
      || err "Remote branch '$gf_branch' does not exist" \
      || return 1
    msg_end "$DONE"
  }

  function git_commit_diff {
    [[ "$( git rev-parse "$1" )" != "$( git rev-parse "$2" )" ]]
  }

  function git_version_diff {
    [[ "$(git show "$1":"$GF_VERSION" | cut -d. -f1-2)" != "$2" ]]
  }

  function git_current_branch {
    git rev-parse --abbrev-ref HEAD
  }

  function git_stash {
    git_status_empty 2>/dev/null && return 0
    msg_start "Stashing files"
    git add -A >/dev/null || return 1
    git stash >/dev/null || return 1
    if git_status_empty 2>/dev/null; then
      stashed=1
      msg_end "$DONE"
    else
      msg_end "$FAIL"
      return 1
    fi
  }

  function git_stash_pop {
    [[ $stashed == 0 ]] && return 0
    msg_start "Popping stashed files"
    git stash pop >/dev/null || { msg_end "$FAIL"; return 1; }
    msg_end "$DONE"
  }

  function git_has_commits {
    git log >/dev/null 2>&1
  }

  function merge_branches {
    local prev_branch
    prev_branch="$(git_current_branch)"
    msg_start "Merging '$1' into branch '$2'" \
      && git_checkout "$2" \
      && { git_merge "$1" "${3:---no-ff}" || return 5; } \
      && git_checkout "$prev_branch" \
      && msg_end "$DONE"
  }

  function delete_gf_branch {
    if git_remote_branch_exists >/dev/null 2>&1; then
      msg_start "Deleting remote branch '$gf_branch'"
      local out
      out="$(git push "$GF_ORIGIN" ":$REFSHEADS/$gf_branch" 2>&1)" \
        || err "$out" \
        || return 1
      msg_end "$DONE"
    fi
    msg_start "Deleting local branch '$gf_branch'"
    git branch -d "$gf_branch" >/dev/null || return 1
    msg_end "$DONE"
  }

  function load_version {
    [[ -f "$GF_VERSION" ]] \
      || err "Version file not found" \
      || return 3
    [[ -n "$(cat "$GF_VERSION")" ]] \
      || err "Version file is empty" \
      || return 3
    [[ "$(cat "$GF_VERSION")" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
      || err "Invalid version file content format" \
      || return 1
    IFS=. read -r major minor patch < "$GF_VERSION" \
      || err "Unable to load version" \
      || return 1
    master=$prefix$major.$minor
    gf_branch="$(git_current_branch)"
  }

  function master_last_change {
    git cherry -v "$GF_DEV" master | tail -n1 | cut -d" " -f2
  }

  # $1 filepath
  # $2 default content
  # $3 allow empty file
  function init_file {
    [[ -f "$1" ]] && return 0
    [[ -z "$1" && $3 == 1 ]] && return 0
    local or_empty_msg
    or_empty_msg=
    [[ $3 == 0 ]] && or_empty_msg=" or empty"
    [[ $conform == 1 ]] \
      || err "Missing$or_empty_msg file '$1'" \
      || return 3
    local message
    message="Initializing '$1' file"
    msg_start "$message"
    echo "$2" > "$1" || return 1
    git add "$1" >/dev/null \
      && git commit -m "$message" >/dev/null \
      || return 1
    msg_end "$DONE"
  }

  function initial_commit {
    git_status_empty 2>/dev/null && return 0
    msg_start "Initial commit"
    git add -A >/dev/null \
      && git commit -m "Commit initial files" >/dev/null \
      || err "Unable to commit existing files" \
      || return 1
    msg_end "$DONE"
  }

  # 1) validate repository existence
  # 2) validate repository consistency:
  # - at least one commit
  # - master branch
  function validate_git_repository {
    if ! git_repo_exists; then
      [[ $conform == 0 ]] && { err "Git repository does not exist" || return 3; }
      msg_start "Initializing git repository"
      git init >/dev/null || return 1
      msg_end "$DONE"
    fi
    if ! git_has_commits; then
      [[ $conform == 0 ]] && { err "Git repository without commits" || return 3; }
      initial_commit || return $?
    elif ! git_branch_exists master; then
      [[ $conform == 0 ]] && { err "Missing branch 'master'" || return 3; }
      git_branch_create master || return 1
    fi
  }

  # validate $GF_VERSION and $GF_HANGELOG files
  function validate_gf_files {
    init_file "$GF_VERSION" "0.0.0" 0 \
      && init_file "$GF_CHANGELOG" "$GF_CHANGELOG_HEADER" 1 \
      && load_version \
      || return $?
  }

  # validate tag on ($)master
  function validate_master_tag {
    if ([[ $1 == master ]] || [[ $1 == "$master" ]]) && ! git_tag_here "$master.$patch"; then
      [[ $conform == 0 ]] && { err "Missing tag '$master.$patch' on current HEAD" || return 3; }
      git_tag "$master.$patch";
    fi
  }

  # 1) validate $GF_DEV branch
  # 2) validate $GF_DEV is up to date with master
  function validate_dev {
    if ! git_branch_exists "$GF_DEV"; then
      [[ $conform == 0 ]] && { err "Missing branch '$GF_DEV'" || return 3; }
      git_branch_create dev master || return 1
    fi
    local last_change
    last_change="$(master_last_change)"
    if [[ -n "$last_change" ]] && ! git branch --contains "$last_change" | grep -q "$GF_DEV"; then
      [[ $conform == 0 ]] && { err "Branch master is not merged with '$GF_DEV'" || return 3; }
      merge_branches "$last_change" "$GF_DEV" || return $?
    fi
  }

  # validate git status
  function validate_status_empty {
    if [[ $force == 1 ]]; then
      git_stash || return $?
    else
      git_status_empty || return 4
    fi
  }

  function validate_changelog_heading {
    grep -qE "^# " "$GF_CHANGELOG" && return 0
    [[ "$conform" == 1 ]] \
      || err "File $GF_CHANGELOG missing '# Heading'" \
      || return 3
    local msg
    msg="Add default heading to $GF_CHANGELOG"
    msg_start "$msg"
    echo -e "$GF_CHANGELOG_HEADER\n$(cat "$GF_CHANGELOG")" > "$GF_CHANGELOG" \
      && git commit -am "$msg" >/dev/null \
      || return 1
    msg_end "$DONE"
  }

  function gf_validate {
    validate_git_repository || return $?
    validate_gf_files || return $?
    validate_master_tag "$gf_branch" || return $?
    validate_dev || return $?
    validate_status_empty || return $?
    validate_changelog_heading || return $?
    # load and validate user params
    [[ $arg_count -gt 2 ]] \
      && { err "Wrong number of parameters" || return 1; }
    if [[ $arg_count -eq 2 ]]; then
      par_kw="$par1"
      par_name="$par2"
      is_gf_keyword "$par_kw" \
        || err "Parameter '$par_kw' is not a valid keyword" \
        || return 1
    elif [[ $arg_count == 1 ]]; then
      if is_gf_keyword "$par1"; then par_kw="$par1"
      else par_name="$par1"; fi
    fi
    [[ -z "$par_name" ]] && return 0
    git check-ref-format "$REFSHEADS/$par_name" \
      || err "Invalid branch name format" \
      || return 1
  }

  function is_gf_keyword {
    [[ "$1" == "$HOTFIX" || "$1" == "$RELEASE" || "$1" == "$FEATURE" || "$1" == "$PULL" || "$1" == "$PUSH" ]]
  }

  # Get free branch name (increment suffix)
  # Eg. when branch "$HOTFIX-john" and "$HOTFIX-john-1" already exists
  # then for param "$HOTFIX-john" return "$HOTFIX-john-2"
  function get_branch_name {
    local count
    local branch
    branch="$1"
    count="${2:-}"
    [[ -z "$count" ]] \
      && ! git_branch_exists "$branch" \
      && echo "$branch" \
      && return
    [[ -z "$count" ]] && count=1
    git_branch_exists "$branch-$count" \
      && get_branch_name "$branch" $(( ++count )) \
      || echo "$branch-$count"
  }

  function prefix_branch {
    local kw name
    kw="${1:-}"
    name="${2:-}"
    [[ -n "$kw" ]] \
      || err "prefix_branch: missing kw param" \
      || return 1
    [[ "$name" == "$kw-"* ]] \
      && echo "$name" \
      && return
    # [[ "$name" == "$kw" ]] ?
    [[ -z "$name" ]] && name="$(id -u -n | tr '[:upper:]' '[:lower:]')"
    get_branch_name "$kw-$name"
  }

  function create_stable_branch {
    git_commit_diff "$gf_branch" master \
      || { git_checkout master; return $?; }
    if git_branch_exists "$master"; then
      git_commit_diff "$gf_branch" "$master" \
        || { git_checkout "$master"; return $?; }
    fi
    git_checkout_branch "$master" || return 1
  }

  # gf [kw] [name]
  #   gf:
  #     according to current branch:
  #       stable  => create hotfix
  #       dev     => create feature
  #       feature => merge feature into dev
  #       release => merge release into dev
  #       hotfix  => merge release into stable
  #               => stable == master ? merge release into dev
  #   gf kw:
  #     according to kw:
  #       hotfix  => create "hotfix-$USER(-[0-9]+)"
  #       release => on release branch
  #                    ? merge release into stable and dev
  #                    : switch on release (create if not exists)
  #       feature => create "feature-$USER(-[0-9]+)"
  #   gf name, gf kw name:
  #     kw := according to current branch:
  #       stable  => hotfix
  #       dev     => feature
  #       feature => feature
  #       release => hotfix
  #       hotfix  => hotfix
  #     switch or create "kw-name" branch
  function gf_process {
    # explicit init
    [[ $init == 1 ]] \
      && git_checkout "$GF_DEV" \
      && return 0
    local branch_name
    # action according to current branch
    if [[ $arg_count -eq 0 ]]; then
      case "${gf_branch%%-*}" in
        HEAD|master|$prefix+([0-9]).+([0-9]))
          branch_name="$(prefix_branch "$HOTFIX" "$(strtolower "$(whoami)")" )"
          gf_hotfix "$branch_name"
        ;;
        $GF_DEV)
          branch_name="$(prefix_branch "$FEATURE" "$(strtolower "$(whoami)")" )"
          gf_feature "$branch_name"
        ;;
        $FEATURE) gf_merge_feature "$gf_branch" ;;
        $RELEASE) gf_merge_release ;;
        $HOTFIX) gf_merge_hotfix "$gf_branch" ;;
        *) err "Current branch '$gf_branch' is not recognized" || return 1 ;;
      esac
      return $?
    fi
    # action according to given kw
    if [[ $arg_count -eq 1 && -n "$par_kw" ]]; then
      branch_name="$(prefix_branch "$par_kw" "$(strtolower "$(whoami)")" )"
      case "$par_kw" in
        $HOTFIX) gf_hotfix "$branch_name" ;;
        $RELEASE)
          if [[ "$gf_branch" == "$RELEASE" ]]; then
            gf_release_release
            return $?
          fi
          gf_release
        ;;
        $FEATURE) gf_feature "$branch_name";;
        $PULL) gf_pull ;;
        $PUSH) gf_push ;;
      esac
      return $?
    fi
    # action according to given name and kw
    if [[ -z "$par_kw" ]]; then
      case "${gf_branch%%-*}" in
        HEAD|master|$prefix+([0-9]).+([0-9])|$RELEASE|$HOTFIX) par_kw="$HOTFIX" ;;
        $GF_DEV|$FEATURE) par_kw="$FEATURE" ;;
        *) err "Current branch '$gf_branch' is not recognized" || return 1 ;;
      esac
      branch_name="$par_kw-$par_name"
    else
      branch_name="$(prefix_branch "$par_kw" "$par_name")"
    fi
    case "$par_kw" in
      $HOTFIX) gf_hotfix "$branch_name" ;;
      $FEATURE) gf_feature "$branch_name";;
      *) err "'$par_kw' with second parameter is not supported" || return 1 ;;
    esac
    return $?
  }

  function gf_checkout {
    local branch
    branch="$1"
    msg_start "Checkout '$branch'"
    [[ "$(git_current_branch)" == "$branch" ]] && msg_end "$SKIP" && return 0
    git_checkout "$branch" || return $?
    msg_end "$DONE"
  }

  function gf_confirm_checkout {
    confirm "* '$1' already exists, checkout?" || return 0
    gf_checkout "$1"
  }

  function gf_release {
    if git_branch_exists "$RELEASE"; then
      gf_confirm_checkout "$RELEASE"
      return $?
    fi
    # dev and master has no diff, nothing to do
    [[ -n "$(git diff "$GF_DEV" master)" ]] \
      || err "Branch '$GF_DEV' is same as branch 'master', nothing to do" \
      || return 1
    confirm "* Create branch '$RELEASE' from branch '$GF_DEV'?" || return 0
    git_checkout_branch "$RELEASE"
  }

  function gf_feature {
    local feature_name
    feature_name="$1"
    if git_branch_exists "$feature_name"; then
      gf_confirm_checkout "$feature_name"
      return $?
    fi
    confirm "* Create branch '$feature_name' from branch '$GF_DEV'?" || return 0
    git_checkout_branch "$feature_name"
  }

  function gf_hotfixable {
    git_commit_diff "$master.$patch" HEAD \
      && { err "Required tag $master.$patch not detected on current HEAD" || return 1; }
  }

  function gf_hotfix {
    local hotfix_name
    hotfix_name="$1"
    if git_branch_exists "$hotfix_name"; then
      gf_confirm_checkout "$hotfix_name"
      return $?
    fi
    local to
    to="$( git tag | grep -e ^"$master". | sort -V | tail -n1 )"
    [ -z "$to" ] && to="master"
    confirm "* Create hotfix '$hotfix_name' from '$to'?" || return 0
    gf_checkout "$to" \
      && load_version \
      || return $?
    if [[ "$gf_branch" != master ]]; then
      create_stable_branch || return $?
    fi
    git_checkout_branch "$hotfix_name" || return $?
  }

  function gf_merge_release {
    confirm "* Merge '$RELEASE' branch into '$GF_DEV'?" || return 0
    merge_branches "$gf_branch" "$GF_DEV" || return $?
  }

  function gf_release_release {
    local confirm_suffix
    [[ $request == 1 ]] && confirm_suffix="$pr_suffix" || confirm_suffix=
    confirm "* Create stable branch from release$confirm_suffix?" || return 0
    merge_branches master "$gf_branch" || return $?
    if ! git_version_diff "$GF_DEV" "$major.$minor"; then
      ((minor++))
      patch=0
      gf_commit_version \
        && load_version \
        || return $?
    fi
    gf_update_changelog_header || return $?
    [[ $request == 1 ]] && { gf_request master; return $?; }
    git_checkout master \
      && merge_branches "$gf_branch" "$GF_DEV" \
      && merge_branches "$gf_branch" master \
      && git_tag "$master".0 \
      && delete_gf_branch \
      && git_checkout "$GF_DEV" \
      || return $?
  }

  function gf_get_compare_url {
    url="$(git config remote."$GF_ORIGIN".url)"
    url="$(trim_url "$url")"
    case "$url" in
      *"$GITHUB"*) echo "https://$url/compare/$1...$2" ;;
      *"$BITBUCKET"*) echo "https://$url/compare/$2..$1" ;;
      *) echo "" ;;
    esac
  }

  function gf_update_changelog_header {
    local header tmpfile compare_url prev_tag
    msg_start "Updating version history header"
    header="## [$major.$minor.$patch] - $(date "+%Y-%m-%d")"
    prev_tag="$(git tag | sort -V | tail -n1 )"
    compare_url="$(gf_get_compare_url "$prev_tag" "$master.$patch" )"
    [[ -n "$compare_url" ]] \
      && compare_url="[$major.$minor.$patch]: $compare_url" \
      || compare_url="[$major.$minor.$patch]: $prev_tag..$master.$patch"
    tmpfile="$(mktemp)"
    awk -v header="$header" -v compare_url="$compare_url" '
      BEGIN {
        write=1
        write_url=1
      }
      write == 1 && /^## / {
        print header
        write=0
        if($0 ~ "^## \\[?Unreleased\\]?") { next }
        print ""
      }
      write_url == 1 && /^\[/ && ! /^\[?Unreleased\]?/ {
        print compare_url
        write_url=0
      }
      {print}
      ENDFILE {
        if(write==1) { print header }
        if(write_url==1) { print compare_url }
      }
      ' "$GF_CHANGELOG" > "$tmpfile"
    cat "$tmpfile" > "$GF_CHANGELOG"
    git commit -am "Update $GF_CHANGELOG header" >/dev/null || return 1
    msg_end "$DONE"
  }

  function gf_write_changelog_line {
    local tmpfile compare_url
    tmpfile="$(mktemp)"
    compare_url="$(gf_get_compare_url "$GF_DEV" master)"
    [[ -n "$compare_url" ]] \
      && compare_url="[Unreleased]: $compare_url" \
      || compare_url="[Unreleased]: $GF_DEV..master"
    awk -v keyword="$1" -v next_keywords="$2" -v message="$3" -v compare_url="$compare_url" '
      function print_unreleased () { print "## [Unreleased]" }
      function print_keyword () { print "### " keyword }
      function print_message () { print " - " message }
      BEGIN {
        write=1
        unreleased=0
        write_url=1
      }
      /^## \[?Unreleased\]?/ { unreleased=1 }
      write == 1 && unreleased == 0 && /^## / && ! /^## \[?Unreleased\]?/ {
        print_unreleased()
        print_keyword()
        print_message()
        print ""
        write=0
      }
      write == 1 && $0 ~ "^## " next_keywords && ! /^## \[?Unreleased\]?/ {
        print_keyword()
        print_message()
        print ""
        write=0
      }
      /^\[?Unreleased\]?/ { write_url=0 }
      write_url == 1 && /^\[/ {
        print compare_url
        write_url=0
      }
      {print}
      write == 1 && $0 == "### " keyword {
        print_message()
        write=0
      }
      ENDFILE {
        if(write == 1) {
          print ""
          if(unreleased == 0) { print_unreleased() }
          print_keyword()
          print_message()
        }
        if(write_url==1) { print compare_url }
      }
    ' "$GF_CHANGELOG" > "$tmpfile"
    cat "$tmpfile" > "$GF_CHANGELOG"
  }

  function gf_update_changelog {
    local commits
    commits="$(git log "$GF_DEV".."$gf_branch" --pretty=format:"*   %h %s")"
    echo
    echo "***"
    echo "* Please enter the $gf_branch description for $GF_CHANGELOG."
    echo "*"
    echo "* Keywords:"
    echo "*   ${CHANGELOG_KEYWORDS[*]}"
    echo "*"
    echo "* Commits of '$gf_branch':"
    echo "$commits"
    echo "*"
    REPLY=
    stdout_verbose
    if [[ $is_stdin == 0 ]]; then
      echo "Type \"Keyword: Message\" (default ${CHANGELOG_KEYWORDS[$1]}) or press Enter to skip: "
      clear_stdin
    fi
    local message keyword next_keywords i found
    while read -e -r message; do
      [[ -z "$message" ]] && break
      history -s "$message"
      keyword="$(trim "$(echo "$message" | cut -sd':' -f1)")"
      next_keywords=
      found=0
      i=
      if [[ -n "$keyword" ]]; then
        for i in "${!CHANGELOG_KEYWORDS[@]}"; do
          [[ "${CHANGELOG_KEYWORDS[i]}" != "$keyword"* ]] && continue
          keyword="${CHANGELOG_KEYWORDS[i]}"
          found=1
          break
        done
        if [[ "$found" == 0 ]]; then
          echo "'$keyword' is not a valid keyword"
          continue
        fi
      else
        i=$1
        keyword="${CHANGELOG_KEYWORDS[$1]}"
      fi
      for ((index="$i+1"; index < ${#CHANGELOG_KEYWORDS[@]}; index++)); do
        next_keywords="$next_keywords|^### ${CHANGELOG_KEYWORDS[index]}"
      done
      [[ "$found" == 1 ]] && message="$(echo "$message" | cut -d':' -f2-)"
      gf_write_changelog_line "$keyword" "$next_keywords" "$(trim "$message")"
    done
    stdout_silent
    msg_start "Updating version history"
    if ! git_status_empty 2>/dev/null; then
      git commit -am "Update $GF_CHANGELOG" >/dev/null || return 1
      msg_end "$DONE"
    else
      msg_end "$SKIP"
    fi
  }

  function gf_merge_feature {
    [[ -n "$(git log "$GF_DEV".."$gf_branch")" ]] \
      || err "Nothing to merge - feature branch '$gf_branch' is empty" \
      || return 1
    local confirm_suffix
    [[ $request == 1 ]] && confirm_suffix="$pr_suffix" || confirm_suffix=
    confirm "* Merge feature '$gf_branch' into '$GF_DEV'$confirm_suffix?" || return 0
    merge_branches "$GF_DEV" "$gf_branch" \
      && gf_update_changelog 0 \
      || return $?
    [[ $request == 1 ]] \
      && { gf_request "$GF_DEV"; return $?; }
    merge_branches "$gf_branch" "$GF_DEV" \
      && git_checkout "$GF_DEV" \
      && delete_gf_branch \
      || return $?
  }

  function gf_prepare_to_merge {
    local ver
    ver="$(git show "$1":"$GF_VERSION")"
    # get and commit VERSION from master
    msg_start "Updating version number from '$1'"
    if [[ "$ver" != "$major.$minor.$patch" ]]; then
      echo "$ver" > "$GF_VERSION"
      git commit -am "Update $GF_VERSION from '$1'" >/dev/null || return 1
      msg_end "$DONE"
    else
      msg_end "$SKIP"
    fi
    load_version
    merge_branches "$1" "$gf_branch"
  }

  function gf_commit_version {
    msg_start "Increment version number to '$major.$minor.$patch'"
    echo "$major.$minor.$patch" > "$GF_VERSION"
    git commit -am "Increment version number" >/dev/null || return 1
    msg_end "$DONE"
  }

  function gf_merge_hotfix {
    local confirm_suffix into
    [[ $request == 1 ]] && confirm_suffix="$pr_suffix" || confirm_suffix=
    # master -> merge hotfix into master and dev
    if ! git_version_diff master "$major.$minor"; then
      into=master
      confirm "* Merge hotfix into master and '$GF_DEV'$confirm_suffix?" || return 0
    else
      into="$master"
      confirm "* Merge hotfix into stable branch '$master'$confirm_suffix?" || return 0
    fi
    [[ -n "$(git log "$into".."$gf_branch")" ]] \
      || err "Nothing to merge - hotfix branch '$gf_branch' is empty" \
      || return 1
    gf_prepare_to_merge "$into" \
      && patch=$((patch+1)) \
      && gf_commit_version \
      && gf_update_changelog 4 \
      && gf_update_changelog_header \
      || return $?
    [[ $request == 1 ]] && { gf_request master; return $?; }
    merge_branches "$gf_branch" "$into" \
      && git_checkout "$into" \
      && git_tag "$master.$patch" \
      || return $?
    if [[ "$into" == master ]]; then
      merge_branches "$gf_branch" "$GF_DEV" || return $?
      if git_branch_exists "$RELEASE"; then
        merge_branches "$gf_branch" "$RELEASE" || return $?
      fi
    fi
    delete_gf_branch
  }

  function gf_pull {
    git_remote_exists \
      && git_fetch --tags \
      && git_fetch "$GF_ORIGIN" "$GF_DEV:$GF_DEV" \
      && git_fetch "$GF_ORIGIN" master:master \
      || return $?
    git_branch_exists "$RELEASE" \
      && { git_fetch "$GF_ORIGIN" "$RELEASE:$RELEASE" || return $?; }
    local stable
    for stable in $(git branch -r | grep 'origin/' | grep -o 'v[0-9]\+\.[0-9]\+'); do
      git_branch_exists "$stable" || continue
      git_fetch "$GF_ORIGIN" "$stable:$stable" || return $?
    done
  }

  function gf_push {
    git_remote_exists \
      && git_push --tags \
      && git_push "$GF_ORIGIN" "$GF_DEV" \
      && git_push "$GF_ORIGIN" master \
      || return $?
    git_branch_exists "$RELEASE" \
      && { git_push "$GF_ORIGIN" "$RELEASE" || return $?; }
    for stable in $(git branch -r | grep 'origin/' | grep -o 'v[0-9]\+\.[0-9]\+'); do
      git_branch_exists "$stable" \
        && { git_push "$GF_ORIGIN" "$stable" || return $?; }
    done
  }

  function gf_request {
    git_remote_exists \
      && { [[ "$GF_ORIGIN" != "$GF_UPSTREAM" ]] || git_push "$GF_ORIGIN" "$1"; } \
      && git_push "$GF_ORIGIN" "$gf_branch" \
      && gf_request_url "$1" \
      || return $?
  }

  function trim_url {
    local url
    url="${1#https://}"
    echo "$url" | grep -q ":" \
      && url="${url#*@}" \
      && url="${url/://}" \
      && url="${url/.git/}"
    echo "$url"
  }

  function gf_request_url {
    local url upstream_url to
    to="${1:-$GF_DEV}"
    url="$(git config remote."$GF_ORIGIN".url)"
    url="$(trim_url "$url")"
    upstream_url="$(git config remote."$GF_UPSTREAM".url)"
    upstream_url="$(trim_url "$upstream_url")"
    stdout_verbose
    echo -n "Pull request URL: "
    case "$url" in
      *"$GITHUB"*)
        # shellcheck disable=SC1003
        [[ "$url" == "$upstream_url" ]] \
          && echo "https://$url/compare/$to...$gf_branch?expand=1" \
          || echo "https://$upstream_url/compare/$to...$(echo "$url" | cut -d'/' -f2)%3A$gf_branch?expand=1"
      ;;
      *"$BITBUCKET"*)
        # shellcheck disable=SC1003
        [[ "$url" == "$upstream_url" ]] \
          && echo "https://$url/compare/$gf_branch..$(echo "$url" | cut -d'/' -f2-3)%3A$to" \
          || echo "https://$url/compare/$gf_branch..$(echo "$upstream_url" | cut -d'/' -f2-3)%3A$to"
      ;;
      *)
        err "unknown - remote server name not recognized"
        stdout_silent
        return 1
      ;;
    esac
    stdout_silent
  }

  function gf_what_now {
    [[ $what_now == 0 ]] && return 0
    stdout_verbose
    echo "***"
    git_repo_exists || {
      echo "* Not a git repository"
      echo "* - Run 'gf --init' to initialize OMGF"
      echo "***"
      return 3
    }

    local gcb
    gcb=$(git_current_branch)
    echo -n "* Current branch '$gcb' is considered as "
    case $gcb in
      HEAD|master|$prefix+([0-9]).+([0-9]))
        if gf_hotfixable 2>/dev/null; then
          echo "hotfixable stable branch."
          echo "* - Run 'gf' to create hotfix or leave :)"
        elif [[ $gcb == HEAD ]]; then
          echo "unknown."
          git_status_empty 2>/dev/null && echo "* - Checkout to existing branch"
        else
          #statements
          echo "stable branch (being) hotfixed."
          echo "* - Run 'gf' to finish current hotfix or create new one."
        fi
      ;;
      "$GF_DEV")
        echo "developing branch."
        echo "* - Do some bugfixes..."
        echo "* - Run 'gf MYFEATURE' to create new feature."
        echo "* - Run 'gf release' to create release branch."
      ;;
      release)
        echo "release branch."
        echo "* - Do some bugfixes..."
        echo "* - Run 'gf' to merge only into '$GF_DEV'."
        echo "* - Run 'gf release' to create stable branch."
      ;;
      hotfix-+([0-9]).+([0-9]).+([0-9]))
        echo "hotfix branch."
        echo "* - Do some hotfixes..."
        echo "* - Run 'gf' to merge hotfix into stable branch."
      ;;
      *)
        echo "feature branch."
        echo "* - Develop current feature..."
        echo "* - Run 'gf' to merge it into '$GF_DEV'."
    esac
    if ! git_status_empty 2>/dev/null; then
      echo "*"
      echo "* - Local changes detected; see 'git status' for more info"
    fi
    echo "***"
    stdout_silent
  }

  # variables
  local line script_name master force conform yes verbose dry what_now color prefix pos_x pos_y init request is_stdin gf_branch major minor patch pr_suffix stashed
  what_now=0
  dry=0
  stashed=0
  verbose=0
  yes=0
  script_name="gf"
  prefix="$([ -z "$GF_NOPREFIX" ] && echo v)"
  major=0
  minor=0
  patch=0
  master=${prefix}0.0
  color=auto
  pos_x=1
  pos_y=1
  [ -t 0 ]
  is_stdin=$?
  pr_suffix=" (push and get pull request URL)"

  # process options
  # shellcheck disable=SC2086
  # shellcheck disable=SC2048
  if ! line=$(
    IFS=" " getopt -n "$0" \
           -o cfhinrvVwy\? \
           -l conform,color::,colour::,force,help,init,dry-run,request,verbose,version,what-now,yes \
           -- $GF_OPTIONS $*
  )
  then gf_usage; return 2; fi
  eval set -- "$line"

  # load user options
  force=0
  conform=0
  init=0
  request=0
  while [ $# -gt 0 ]; do
    case $1 in
     -c|--conform) conform=1; shift ;;
     --color|--colour) shift; setcolor "$1" || { gf_usage; return 2; }; shift ;;
     -f|--force) force=1; shift ;;
     -h|-\?|--help) gf_usage; return $? ;;
     -i|--init) init=1; conform=1; shift ;;
     -n|--dry-run) dry=1; shift ;;
     -r|--request) request=1; shift;;
     -v|--verbose) verbose=1; shift ;;
     -V|--version) gf_version; return $? ;;
     -w|--what-now) what_now=1; shift ;;
     -y|--yes) yes=1; shift ;;
      --) shift; break ;;
      *-) echo "$script_name: Unrecognized option '$1'" >&2; gf_usage; return 2 ;;
       *) break ;;
    esac
  done

  # constants
  # TODO $GF_{HOTFIX,RELEASE,FEATURE} ?
  local -r \
    RED=1 \
    GREEN=2 \
    BLUE=4 \
    GITHUB="github.com" \
    BITBUCKET="bitbucket.org" \
    HOTFIX="hotfix" \
    RELEASE="release" \
    FEATURE="feature" \
    PULL="pull" \
    PUSH="push" \
    CHANGELOG_KEYWORDS=(Added Changed Deprecated Removed Fixed Security)
  local -r \
    REFSHEADS="refs/heads" \
    DONE="$(colorize "  ok  " $GREEN)" \
    FAIL="$(colorize " fail " $RED)" \
    SKIP="$(colorize " skip " $BLUE)"

  # proceed params
  local par1 par2 par_kw par_name arg_count
  par1="${1:-}"
  par2="${2:-}"
  par_kw=
  par_name=
  arg_count=$#

  # silent output by default
  stdout_silent
  # dry run
  [[ $dry == 1 ]] && { gf_what_now; return 0; }

  # shellcheck disable=SC2015
  gf_validate && gf_process && git_stash_pop && gf_what_now || {
    case $? in
      1) err "Generic error occurred (see REPORTING BUGS)."; return 1 ;;
      3) err "Git is not conform with OMGF model (see conform option)."; return 3 ;;
      4) err "Git status is not empty (see force option)."; return 4 ;;
      5) err "Git conflict occurred (see 'git status')."; gf_what_now; return 5 ;;
    esac
  }

}

main "$@"