#!/bin/bash

shopt -s extglob
set -u

: ${GF_DATAPATH:=.}
: ${GF_CHANGELOG:=CHANGELOG}
: ${GF_VERSION:=VERSION}
: ${GF_DEV:=dev}
: ${GF_ORIGIN:=origin}
: ${GF_OPTIONS:=}
: ${GF_NOPREFIX:=}
: ${COLUMNS:=$(tput cols)}
: ${LINES:=$(tput lines)}

function main {

  function msg_start {
    echo -n "[ "
    save_cursor_position
    echo " ....  ] $1"
  }

  function msg_end {
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
    echo "$(basename "${0}")[error]: $@" >&2
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
    IFS=. read major minor patch < "$GF_VERSION" \
      || err "Unable to load version" \
      || return 1
    master=$prefix$major.$minor
  }

  function edit {
    local editor
    editor="$(git config --get core.editor)"
    stdout_verbose
    if type "$editor" &> /dev/null; then
      $editor "$1"
    else
      echo
      cat "$1"
      echo
      echo -n "Type message or press Enter to skip: "
      clear_stdin
      read
      echo "$REPLY" > "$1"
    fi
    stdout_silent
  }

  function git_status_empty {
    [[ -z "$(git status --porcelain)" ]] \
      || err "Uncommited changes"
  }

  # TODO checkout only to branch
  # make git return only error to stderr
  function git_checkout {
    local out
    out="$(git checkout $@ 2>&1)" \
      || err "$out"
  }

  # make git return only error to stderr
  function git_tag {
    local out
    out="$(git tag $@ 2>&1)" \
      || err "$out"
  }

  # make git return only error to stderr
  function git_merge {
    local out
    out="$(git merge $@ 2>&1)" \
      || err "$out"
  }

  function git_branch {
    git_checkout $1 2>/dev/null && return 0
    msg_start "Creating branch '$1'"
    git_checkout -b $1 || return 1
    msg_end "$DONE"
  }

  function git_branch_exists {
    git rev-parse --verify "$1" >/dev/null 2>&1 && return 0
    git rev-parse --verify "$GF_ORIGIN/$1" >/dev/null 2>&1 \
      && git branch "$1" "$GF_ORIGIN/$1" >/dev/null 2>&1 || return 1
  }

  function git_tag_exists {
    git show-ref --tags | egrep -q "$REFSTAGS/$1$" >/dev/null 2>&1
  }

  function git_repo_exists {
    [[ -d .git ]]
  }

  function git_commit_diff {
    [[ "$( git rev-parse $1 )" != "$( git rev-parse $2 )" ]]
  }

  function git_version_diff {
    [[ "$(git show $1:"$GF_VERSION" | cut -d. -f1-2)" != "$2" ]]
  }

  function git_current_branch {
    git rev-parse --abbrev-ref HEAD
  }

  function git_stash {
    git_status_empty 2>/dev/null && return 0
    [[ $force == 0 ]] && return 0
    msg_start "Stashing files"
    git add -A >/dev/null || return 1
    git stash >/dev/null || return 1
    git_status_empty 2>/dev/null \
      && { stashed=1; msg_end "$DONE"; } \
      || { msg_end "$FAILED"; return 1; }
  }

  function git_stash_pop {
    [[ $stashed == 0 ]] && return 0
    msg_start "Poping stashed files"
    git stash pop >/dev/null || { msg_end "$FAILED"; return 1; }
    msg_end "$DONE"
  }

  function git_has_commits {
    git log >/dev/null 2>&1
  }

  function clear_stdin {
    while read -r -t 0; do read -r; done
  }

  function save_cursor_position {
    stdout_verbose
    local curpos oldtty
    curpos="1;1"
    oldtty=$( stty -g )
    stty -echo
    echo -n $'\e[6n'
    read -d R curpos
    stty $oldtty
    pos_x=$( echo "${curpos#??}" | cut -d";" -f1 )
    pos_y=$( echo "${curpos#??}" | cut -d";" -f2 )
    stdout_silent
  }

  function set_cursor_position {
    [[ $pos_x == $LINES ]] && : $(( pos_x-- ))
    tput cup $(( pos_x-1 )) $(( pos_y-1 ))
  }

  function confirm {
    [[ $verbose == 0 && $yes == 1 ]] && return 0
    stdout_verbose
    echo -n "${@:-"Are you sure?"} [YES/No] "
    save_cursor_position
    [[ $yes == 1 ]] && echo "yes" && return 0
    clear_stdin
    read -r
    [[ -z "$REPLY" ]] && set_cursor_position && echo "yes"
    stdout_silent
    [[ "$REPLY" =~ ^[yY](es)?$ || -z "$REPLY" ]] && return 0
    [[ "$REPLY" =~ ^[nN]o?$ ]] && return 1
    confirm "Type"
  }

  function master_last_change {
    git log master --no-merges -n1 --format="%h"
  }

  function init_file {
    if [[ ! -f "$1" || -z "$(cat "$1")" ]]; then
      [[ $conform == 1 ]] \
        || err "Missing or empty file '$1'" \
        || return 3
      msg_start "Initializing '$1' file on branch '$2'"
      echo "$3" > "$1" || return 1;
      msg_end "$DONE"
    fi
  }

  function init_files {
    init_file "$GF_VERSION" "$1" "0.0.0" || return $?
    init_file "$GF_CHANGELOG" "$1" "$GF_CHANGELOG created" || return $?
    git_status_empty 2>/dev/null && return 0
    msg_start "Commiting new files"
    git add "$GF_VERSION" "$GF_CHANGELOG" >/dev/null \
      && git commit -m "Init gf: create required files" >/dev/null \
      || return 1
    msg_end "$DONE"
  }

  function initial_commit {
    git_status_empty 2>/dev/null || {
      msg_start "Initial commit"
      git add -A >/dev/null \
        && git commit -m "Commit initial files" >/dev/null \
        || err "Unable to commit existing files" \
        || return 1
      msg_end "$DONE"
    }
  }

  function gf_validate {
    local curbranch
    curbranch=""
    if ! git_repo_exists; then
      [[ $conform == 0 ]] && { err "Git repository does not exist" || return 3; }
      msg_start "Initializing git repository"
      git init >/dev/null || return 1
      msg_end "$DONE"
    fi
    if ! git_branch_exists master; then
      [[ $conform == 0 ]] && { err "Missing branch 'master'" || return 3; }
      git_branch master || return 1
    fi
    if git_has_commits; then
      curbranch="$(git_current_branch)"
      local errout
      errout="$(git_status_empty 2>&1)"
      [[ $? != 0 && $force == 0 ]] \
        && { echo "$errout" >&2 && return 4; }
      git_stash || return $?
      git_checkout master >/dev/null
    else
      [[ $conform == 0 ]] && { err "Git repository without commits" || return 3; }
      initial_commit || return $?
    fi
    init_files master \
      && load_version \
      || return $?
    if ! git_tag_exists $master.$patch; then
      [[ $conform == 0 ]] && { err "Missing tag '$master.$patch' on branch 'master'" || return 3; }
      git_tag $master.$patch;
    fi
    if ! git_branch_exists "$GF_DEV"; then
      [[ $conform == 0 ]] && { err "Missing branch '$GF_DEV'" || return 3; }
      git_branch dev || return 1
    fi
    git_checkout dev >/dev/null \
      && init_files dev \
      && load_version \
      || return $?
    if ! git branch --contains $(master_last_change) | grep "$GF_DEV" >/dev/null; then
      [[ $conform == 0 ]] && { err "Branch master is not merged with '$GF_DEV'" || return 3; }
      msg_start "Merging last changes from 'master' into '$GF_DEV'"
      merge_branches $(master_last_change) "$GF_DEV" || return $?
      msg_end "$DONE"
    fi
    git_checkout "$curbranch" || return $?
    [[ -z "$curbranch" ]] && curbranch="$(git_current_branch)"
    [[ -z "$origbranch" ]] && { origbranch="$curbranch"; return $?; }
    git check-ref-format "$REFSHEADS/$origbranch" \
      || err "Invalid branchname format" \
      || return 1
    git_branch_exists "$origbranch" \
      || [[ ! "$origbranch" =~ ^(hotfix|release|master).+ ]] \
      || err "Feature branch cannot start with hotfix, release or master" \
      || return 1
  }

  function gf_checkout {
    [[ "$(git_current_branch)" == "$1" ]] \
      && origbranch="$(git_current_branch)" \
      && return 0
    # assume checkout to tag or branch
    msg_start "Checkout '$1'"
    git_checkout "$1" \
      && gf_validate \
      && load_version \
      || return $?
    origbranch="$(git_current_branch)"
    msg_end "$DONE"
  }

  function gf_prepare {
    # checkout to given branch or create feature
    if git_branch_exists "$origbranch"; then
      gf_checkout "$origbranch" || return $?
    else
      # predefined checkout kws
      case "$origbranch" in
        $prefix+([0-9]).+([0-9]))
          git_branch_exists "$origbranch.0" \
            || err "Stable branch '$origbranch' does not exist" \
            || return 1
          git_checkout "$origbranch.0" || return $?
          ;&
        hotfix)
          # already on hotfix?
          load_version || return $?
          [[ "$(git_current_branch)" == "hotfix-$major.$minor.$patch" ]] \
            && origbranch="hotfix-$major.$minor.$patch" \
            && return 0
          # get appropriate stable branch or 'master'
          local to
          to="$( git tag | grep -e ^$master. | sort -V | tail -n1 )"
          [ -z "$to" ] && to="master"
          gf_checkout "$to" || return $?
          # hotfix already exists
          git_branch_exists "hotfix-$major.$minor.$((patch+1))" \
            && { gf_checkout "hotfix-$major.$minor.$((patch+1))" || return $?; }
          return 0 ;;
        release) gf_checkout dev || return $?; return 0 ;;
      esac
      # -> or create feature branch
      newfeature=1
      confirm "* Create feature branch '$origbranch'?" || return 0
      git_checkout "$GF_DEV" \
        && git_branch "$origbranch" \
        || return 1
    fi
  }

  function create_branch {
    # create a new branch
    git_branch_exists $1 \
      && { err "Destination branch '$1' already exists" || return 1; }
    git_branch $1 || return 1
    # updating GF_CHANGELOG and GF_VERSION files
    if [[ $origbranch == "$GF_DEV" ]]; then
      local header
      msg_start "Updating '$GF_CHANGELOG' and '$GF_VERSION' files"
      header="$major.$minor | $(date "+%Y-%m-%d")" || return 1
      printf '\n%s\n\n%s\n' "$header" "$(<$GF_CHANGELOG)" > "$GF_CHANGELOG" || return 1
    else
      msg_start "Updating '$GF_VERSION' file"
    fi
    echo $major.$minor.$patch > "$GF_VERSION" || return 1
    msg_end "$DONE"
    git commit -am "$1" >/dev/null || return 1
    if [[ $origbranch == "$GF_DEV" ]]; then
      merge_branches $1 "$GF_DEV" \
      && git_checkout $1 \
      || return $?
    fi
  }

  function merge_feature {
    local tmpfile commits
    git_commit_diff $origbranch "$GF_DEV" \
      && msg_start "Rebasing feature branch to '$GF_DEV'" \
      && { git rebase "$GF_DEV" >/dev/null || return 5; } \
      && msg_end "$DONE"
    commits="$(git log "$GF_DEV"..$origbranch --pretty=format:"#   %s")"
    # message for $GF_CHANGELOG
    if [[ -n "$commits" ]]; then
      tmpfile="$(mktemp)"
      {
        echo -e "\n# Please enter the feature description for '$GF_CHANGELOG'. Lines starting"
        echo -e "# with # and empty lines will be ignored."
        echo -e "#\n# Commits of '$origbranch':\n#"
        echo -e "$commits"
        echo -e "#"
      } >> "$tmpfile"
      edit "$tmpfile"
      sed -i '/^\s*\(#\|$\)/d;/^\s+/d' "$tmpfile"
    fi
    msg_start "Updating changelog"
    if [[ -n "$commits" && -n "$(cat "$tmpfile")" ]]; then
      cat "$GF_CHANGELOG" >> "$tmpfile" || return 1
      mv "$tmpfile" "$GF_CHANGELOG" || return 1
      git commit -am "Version history updated" >/dev/null || return 1
      msg_end "$DONE"
    else
      msg_end "$PASSED"
    fi
  }

  function merge_branches {
    msg_start "Merging '$1' into branch '$2'" \
      && git_checkout "$2" \
      && { git_merge $1 "${3:---no-ff}" || return 5; } \
      && msg_end "$DONE"
  }

  function delete_branch {
    msg_start "Deleting remote branch '$origbranch'"
    if git branch -r | grep $GF_ORIGIN/$origbranch$ >/dev/null; then
      local out
      out="$(git push $GF_ORIGIN :$REFSHEADS/$origbranch 2>&1)" \
        || err "$out" \
        || return 1
      msg_end "$DONE"
    else
      msg_end "$PASSED"
    fi
    msg_start "Deleting local branch '$origbranch'"
    git branch -d $origbranch >/dev/null || return 1
    msg_end "$DONE"
  }

  function create_stable_branch {
    git_commit_diff $origbranch master \
      || { git_checkout master; return $?; }
    if git_branch_exists $master; then
      git_commit_diff $origbranch $master \
        || { git_checkout $master; return $?; }
    fi
    git_branch "$master" || return 1
  }

  function gf_hotfixable {
    git_commit_diff $master.$patch HEAD \
      && { err "Required tag $master.$patch not detected on current HEAD" || return 1; }
    git_tag_exists "$master.$((patch+1))" \
      && { err "Current branch is already hotfixed" || return 1; }
    git_branch_exists "hotfix-$major.$minor.$((patch+1))" \
      && { err "Current branch is being hotfixed" || return 1; }
    return 0
  }

  # Origbranch:
  #
  #  $GF_DEV
  #   - increment minor version, set patch to 0
  #   - create release branch
  #
  #  newest tag on stable branch (eg. v1.10.1)
  #   - create stable branch
  #   - continue master
  #  master
  #   - increment patch version
  #   - create hotfix branch
  #
  #  hotfix (eg. hotfix-1.10.2)
  #   - merge hotfix branch into stable branch
  #   - merge hotfix branch into $GF_DEV (if hotfixing master)
  #   - create tag
  #   - delete hotfix branch
  #
  #  release
  #   - merge release branch into master
  #   - merge release branch into $GF_DEV
  #   - create tag
  #   - delete release branch
  #
  #  feature
  #   - update version history
  #   - merge feature branch into $GF_DEV
  #   - delete feature branch
  #
  function gf_run {
    local tag
    tag=""
    case $origbranch in
      HEAD|master|$prefix+([0-9]).+([0-9]))
        gf_hotfixable || return 1
        confirm "* Create hotfix $master.$((patch+1))?" || return 0
        [[ $origbranch != master ]] && {
          create_stable_branch || return $?
          origbranch=$(git_current_branch)
        }
        create_branch "hotfix-$major.$minor.$((++patch))"
        ;;
      "$GF_DEV")
        if ! git_commit_diff "$GF_DEV" master; then
          err "Branch '$GF_DEV' is same as branch 'master', nothing to do" || return 1
        fi
        confirm "* Create release branch from branch '$GF_DEV'?" || return 0
        patch=0
        ((minor++))
        create_branch release
        ;;
      hotfix-+([0-9]).+([0-9]).+([0-9]))
        # master -> merge + confirm merge to dev
        if ! git_version_diff master $major.$minor; then
          confirm "* Merge hotfix into master and '$GF_DEV'?" || return 0
          merge_branches $origbranch master \
            && git_tag $master.$patch \
            && merge_branches $origbranch "$GF_DEV" \
            || return $?
        # not master -> merge only to stable branch
        else
          confirm "* Merge hotfix into stable branch '$master'?" || return 0
          merge_branches $origbranch $master \
            && git_tag $master.$patch \
            || return $?
        fi
        delete_branch
        ;;
      release)
        if confirm "* Create stable branch from release?"; then
          git_checkout master \
            && merge_branches $origbranch master \
            && git_tag $master.0 \
            && merge_branches $origbranch "$GF_DEV" \
            && delete_branch \
            || return $?
        else
          confirm "* Merge release branch into '$GF_DEV'?" || return 0
          merge_branches $origbranch "$GF_DEV" \
            && git_checkout $origbranch \
            || return $?
        fi
        ;;
      *)
        [[ -n "$(git log "$GF_DEV"..$origbranch)" ]] \
          || err "Nothing to merge - feature branch '$origbranch' is empty" \
          || return 1
        confirm "* Merge feature '$origbranch' into '$GF_DEV'?" || return 0
        merge_feature \
         && merge_branches $origbranch "$GF_DEV" \
         && delete_branch \
         || return $?
    esac
  }

  function gf_what_now {
    [[ $what_now == 0 ]] && return 0
    stdout_verbose
    local gcb
    echo "***"
    git_repo_exists || {
      echo "* Not a git repository"
      echo "* - Run 'gf -i' to initialize gf"
      echo "***"
      return 3
    }

    gcb=$(git_current_branch)
    echo -n "* Current branch '$gcb' is considered as "
    case $gcb in
      HEAD)
        if ! gf_hotfixable; then
          echo "unknown."
          echo "* - Checkout to existing branch"
        fi
      ;&
      master|$prefix+([0-9]).+([0-9]))
        if gf_hotfixable 2>/dev/null; then
          echo "hotfixable stable branch."
          echo "* - Run 'gf' to create hotfix or leave :)"
        else
          echo "stable branch (being) hotfixed."
          echo "* - Run 'gf hotfix' to finish current hotfix or create new one."
        fi
      ;;
      "$GF_DEV")
        echo "developing branch."
        echo "* - Do some bugfixes..."
        echo "* - Run 'gf MYFEATURE' to create new feature."
        echo "* - Run 'gf' to create release branch."
      ;;
      release)
        echo "release branch."
        echo "* - Do some bugfixes..."
        echo "* - Run 'gf' to create stable branch."
        echo "* - Hit [No-Yes] to merge only into '$GF_DEV'."
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

  function gf_usage {
    local usage_file shift_left
    usage_file="$GF_DATAPATH/${script_name}.usage"
    [ -f "$usage_file" ] \
      || err "Usage file not found" \
      || return 1
    head -n1 "$usage_file"
    echo
    shift_left=0
    [[ $COLUMNS -gt 1 ]] && shift_left=5 && export MANWIDTH=$((COLUMNS+$shift_left))
    echo "$(tail -n+2 "$usage_file")" | man --nj --nh -l - | sed "1,2d;/^[[:space:]]*$/d;\$d;s/^ \{$shift_left\}//"
  }

  function gf_version {
    local version
    version="$GF_DATAPATH/VERSION"
    [ -f "$version" ] \
      || err "Version file not found" \
      || return 1
    echo -n "GNU gf "
    cat "$version"
  }

  # variables
  local line script_name major minor patch master force conform yes verbose dry what_now stashed color prefix pos_x pos_y
  what_now=0
  dry=0
  verbose=0
  stashed=0
  yes=0
  script_name="gf"
  major=0
  minor=0
  patch=0
  prefix="$([ -z $GF_NOPREFIX ] && echo v)"
  master=${prefix}0.0
  color=auto
  pos_x=1
  pos_y=1

  # process options
  if ! line=$(
    IFS=" " getopt -n "$0" \
           -o fcwynvVh\? \
           -l force,conform,what-now,dry-run,yes,color::,colour::,verbose,version,help \
           -- $GF_OPTIONS $*
  )
  then gf_usage; return 2; fi
  eval set -- "$line"

  # load user options
  force=0
  conform=0
  while [ $# -gt 0 ]; do
    case $1 in
     -f|--force) force=1; shift ;;
     -c|--conform) conform=1; shift ;;
     -w|--what-now) what_now=1; shift ;;
     -y|--yes) yes=1; shift ;;
     --color|--colour) shift; setcolor "$1" || { gf_usage; return 2; }; shift ;;
     -n|--dry-run) dry=1; shift ;;
     -v|--verbose) verbose=1; shift ;;
     -V|--version) gf_version; return $? ;;
     -h|-\?|--help) gf_usage; return $? ;;
      --) shift; break ;;
      *-) echo "$script_name: Unrecognized option '$1'" >&2; gf_usage; return 2 ;;
       *) break ;;
    esac
  done

  # constants
  local -r \
    RED=1 \
    GREEN=2 \
    BLUE=4
  local -r \
    REFSHEADS="refs/heads" \
    REFSTAGS="refs/tags" \
    DONE="$(colorize "  ok  " $GREEN)" \
    FAILED="$(colorize "failed" $RED)" \
    PASSED="$(colorize "passed" $BLUE)"

  # proceed options
  local origbranch newfeature
  newfeature=0
  origbranch="${1:-}"
  stdout_silent
  [[ $dry == 1 ]] && { gf_what_now; return 0; }

  # run gf
  gf_validate && gf_prepare && {
    if [[ $newfeature == 0 ]]; then load_version && gf_run; fi
    } && git_stash_pop && gf_what_now || {
    case $? in
      1) err "Generic error occured (see REPORTING BUGS in man gf)"; return 1 ;;
      3) err "Initializing gf may help (see OPTIONS in man gf)"; return 3 ;;
      4) err "Forcing gf may help (see OPTIONS in man gf)"; return 4 ;;
      5) err "Conflict occured (see git status)"; gf_what_now; return 5 ;;
    esac
  }

}

main "$@"
