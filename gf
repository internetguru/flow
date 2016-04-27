#!/bin/bash

set -eu

: ${DATAPATH:=.}
: ${CHANGELOG:=CHANGELOG}
: ${VERSION:=VERSION}
: ${DEV:=dev}

function main {

  # defaults and constants
  local line script_name major minor patch master force init
  local -r \
    DONE="[ done ]" \
    SKIPPED="[ skipped ]" \
    FAILED="[ failed ]" \
    PASSED="[ passed ]"

  force=0
  init=0
  stash=0
  script_name="gf"

  # process options
  if ! line=$(
    getopt -n "$0" \
           -o fitvh\? \
           -l force,init,tips,version,help\
           -- "$@"
  )
  then return 1; fi
  eval set -- "$line"

  function err {
    echo "$(basename "${0}")[error]: $@" >&2
    return 1
  }

  function edit {
    local editor
    editor="$(git config --get core.editor)"
    type "$editor" &> /dev/null \
      && { $editor "$1" || return 1; return 0; }
    echo -e "\n\n***"
    echo "* Warning:"
    echo "* - Default git editor not found"
    echo "* - Set defaults by 'git config --global core.editor EDITOR'"
    echo "***"
    cat "$1"
    read
    echo "$REPLY" > "$1"
  }

  function git_status_empty {
    [[ -z "$(git status --porcelain)" ]] && return 0
    err "Uncommited changes" || return 1
  }

  # TODO checkout only to branch
  # make git checkout return only error to stderr
  function git_checkout {
    local out
    out="$(git checkout $@ 2>&1)" \
      || err "$out" || return 1
  }

  # make git checkout return only error to stderr
  function git_merge {
    local out
    out="$(git merge $@ 2>&1)" \
      || err "$out" || return 1
  }

  function git_branch {
    git_checkout $1 2>/dev/null && return 0
    echo -n "Creating branch '$1': "
    git_checkout -b $1 || return 1
    echo $DONE
  }

  function git_branch_exists {
    git rev-parse --verify "$1" >/dev/null 2>&1
  }

  function git_repo_exists {
    [[ -d .git ]]
  }

  function git_commit_diff {
    [[ "$( git rev-parse $1 )" != "$( git rev-parse $2 )" ]]
  }

  function git_current_branch {
    git rev-parse --abbrev-ref HEAD
  }

  function git_stash {
    git_status_empty 2>/dev/null && return 0
    echo -n "Stashing files: "
    git add -A >/dev/null || return 1
    git stash >/dev/null || return 1
    git_status_empty 2>/dev/null \
      && { stash=1; echo $DONE; } \
      || { echo $FAILED; return 1; }
  }

  function git_stash_pop {
    echo -n "Poping stashed files: "
    git stash pop >/dev/null || { echo $FAILED; return 1; }
    echo $DONE
  }

  function confirm {
    echo -n "${@:-"Are you sure?"} [Yes/No] "
    read
    [[ "$REPLY" =~ ^[yY](es)?$ ]] && return 0
    [[ "$REPLY" =~ ^[nN]o?$ ]] && return 1
    confirm "Type"
  }

  function gf_check {
    git_repo_exists \
      || err "Git repository does not exist" \
      || return 2
    { git_branch_exists "$DEV" && git_branch_exists master; } \
      || err "Missing branches '$DEV' or master" \
      || return 2
    [[ $force == 1 ]] && { git_stash || return 1; }
    git_status_empty \
      || return 3
    [[ -f "$VERSION" && -f "$CHANGELOG" ]] \
      || err "Missing working files" \
      || return 2
    [[ -n "$(cat "$VERSION")" ]] \
      || err "Empty '$VERSION' file" \
      || return 2
    [[ "$(cat "$VERSION")" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
      || err "Invalid '$VERSION' file content format" \
      || return 1
  }

  function create_branch {
    # create a new branch
    git_branch_exists $1 \
      && { err "Destination branch '$1' already exists" || return 1; }
    git_branch $1 || return 1
    # updating CHANGELOG and VERSION files
    if [[ $origbranch == "$DEV" ]]; then
      local header
      echo -n "Updating '$CHANGELOG' and '$VERSION' files: "
      header="${major}.${minor} | $(date "+%Y-%m-%d")" || return 1
      printf '\n%s\n\n%s\n' "$header" "$(<$CHANGELOG)" > "$CHANGELOG" || return 1
    else
      echo -n "Updating '$VERSION' file: "
    fi
    echo ${major}.${minor}.$patch > "$VERSION" || return 1
    git commit -am "$1" >/dev/null || return 1
    if [[ $origbranch == "$DEV" ]]; then
      git_checkout "$DEV" \
      && git_merge --no-ff $1 \
      && git_checkout $1 \
      || return 1
    fi
    echo $DONE
  }

  function merge_feature {
    local tmpfile
    git_commit_diff $origbranch "$DEV" \
      && echo -n "Rebasing feature branch to '$DEV': " \
      && { git rebase "$DEV" >/dev/null || return 1; } \
      && echo $DONE
    # message for $CHANGELOG
    echo -n "Updating changelog: "
    tmpfile="$(mktemp)"
    {
      echo -e "\n# Please enter the feature description for '$CHANGELOG'. Lines starting"
      echo -e "# with # and empty lines will be ignored."
      echo -e "#\n# Commits of '$origbranch':\n#"
      echo -e "$1"
      echo -e "#"
    } >> "$tmpfile"
    edit "$tmpfile" || { echo $SKIPPED; return 1; }
    sed -i '/^\s*\(#\|$\)/d;/^\s+/d' "$tmpfile"
    if [[ -n "$(cat "$tmpfile")" ]]; then
      cat "$CHANGELOG" >> "$tmpfile" || return 1
      mv "$tmpfile" "$CHANGELOG" || return 1
      git commit -am "Version history updated" >/dev/null || return 1
      echo $DONE
    else
      echo $SKIPPED
    fi
  }

  function merge_branches {
    echo -n "Merging '$1' into branch '$2': " \
      && git_checkout "$2" \
      && git_merge $1 "${3:---no-ff}" \
      && echo $DONE
    }

  function delete_branch {
    echo -n "Deleting branch '$origbranch': "
    git branch -r | grep origin/$origbranch$ >/dev/null \
      && { git push origin :refs/heads/$origbranch >/dev/null || return 1; }
    git branch -d $origbranch >/dev/null || return 1
    echo $DONE
  }

  # Params:
  #   - $1 from branch
  #
  # Desc:
  #
  #  $DEV
  #   - increment minor version, set patch to 0
  #   - create release-major.minor branch
  #
  #  master, stable (major.minor, eg. 1.10)
  #   - increment patch version
  #   - create hotfix-major.minor.patch branch
  #
  #  hotfix-x or release-x; alias current
  #   - merge current branch into $DEV
  #   - merge current branch into stable
  #   - merge current branch into master (if matches stable)
  #   - create tag
  #   - delete current branch
  #
  #  feature
  #   - update version history
  #   - merge feature branch into $DEV
  #   - delete feature branch
  function gf_run {

    # checkout to given branch or create feature
    if [[ -n "$1" ]]; then
      if git_branch_exists "$1"; then
        echo -n "Checkout branch '$1': "
        [[ "$(git_current_branch)" != "$1" ]] \
          && { git_checkout "$1" || return 1; echo $DONE; } \
          || echo $PASSED
      else
        confirm "* Create feature branch '$1'?" || return 0
        git_checkout $DEV \
          && git_branch "$1" \
          || return 1
        return 0
      fi
    fi

    # set variables
    local origbranch tag
    origbranch="$(git_current_branch)"
    tag=""

    # proceed
    case ${origbranch%-*} in

      HEAD)
        err "No branch detected on current HEAD" || return 1
        ;;

      master)
        git_branch_exists $master || return 2
        git_commit_diff $master master \
          && { err "Cannot hotfix from unmerged master" || return 1; }
        ;&

      $master)
        confirm "* Create hotfix?" || return 0
        create_branch "hotfix-${master}.$((++patch))"
        ;;

      "$DEV")
        confirm "* Create release branch from branch '$DEV'?" || return 0
        patch=0
        create_branch "release-${major}.$((++minor))"
        ;;

      hotfix)
        confirm "* Merge hotfix?" || return 0
        if git_commit_diff $master master; then
          merge_branches $origbranch $master \
            && git tag ${master}.$patch >/dev/null \
            || return 1
        else
          merge_branches $origbranch $master \
            && git tag ${master}.$patch >/dev/null \
            && merge_branches $master master --ff \
            || return 1
        fi
        confirm "* Merge hotfix into '$DEV'?" \
          && { merge_branches $origbranch "$DEV" || return 1; }
        delete_branch
        ;;

      release)
        if confirm "* Create stable branch from release?"; then
          merge_branches $origbranch "$DEV" \
            && git_checkout master \
            && git_branch $master \
            && { git_commit_diff $master master || merge_branches $origbranch master; } \
            && merge_branches master $master --ff \
            && git tag ${master}.0 >/dev/null \
            && delete_branch \
            || return 1
        else
          confirm "* Merge branch release into branch '$DEV'?" || return 0;
          merge_branches $origbranch "$DEV" \
            && git_checkout $origbranch \
            || return 1
        fi
        ;;

      *)
        local commits
        commits="$(git log "$DEV"..$origbranch --pretty=format:"#   %s")"
        [[ -n $commits ]] \
          || err "Nothing to merge - feature branch '$origbranch' is empty" \
          || return 1
        confirm "* Merge feature '$origbranch'?" || return 0
        merge_feature "$commits" \
         && merge_branches $origbranch "$DEV" \
         && delete_branch \
         || return 1
    esac
  }

  function init_files {
    echo -n "Initializing files on branch '$1': "
    [[ ! -f "$VERSION" || -z "$(cat "$VERSION")" ]] \
      && { echo 0.0.0 > "$VERSION" || return 1; }
    [[ ! -f "$CHANGELOG" || -z "$(cat "$CHANGELOG")" ]] \
      && { echo "$CHANGELOG created" > "$CHANGELOG" || return 1; }
    git_status_empty 2>/dev/null && echo $PASSED && return 0
    git add "$VERSION" "$CHANGELOG" >/dev/null \
      && git commit -m "Init gf: create required files" >/dev/null \
      || return 1
    echo $DONE
  }

  # Prepare enviroment for gf:
  # - create $VERSION and $CHANGELOG file
  # - create $DEV branch
  function gf_init {
    # init git repo
    echo -n "Initializing git repository: "
    if git_repo_exists; then
      git_branch master || return 1
      echo $PASSED
    else
      git init >/dev/null || return 1
      git_status_empty 2>/dev/null || {
        git add -A >/dev/null \
        && git commit -m "Comit initial files" >/dev/null \
        || err "Unable to commit existing files" || return 1
      }
      echo $DONE
    fi
    # init files on master and $DEV
    [[ $force == 1 ]] && { git_stash || return 1; }
    git_status_empty || return 3
    init_files master \
      && {
        echo -n "Initializing stable branch $master: "
        git_branch_exists "$master" \
          && echo $PASSED \
          || { git_branch "$master" >/dev/null || return 1; echo $DONE; }
      } \
      && git_branch "$DEV" \
      && init_files "$DEV"
    [[ $stash == 1 ]] && { git_stash_pop || return 1; }
    return 0
  }

  function gf_tips {
    local gcb
    echo "***"
    git_repo_exists || {
      echo "* Not a git repository"
      echo "* - Run gf -i to initialize gf"
      echo "***"
      return 2
    }
    gcb=$(git_current_branch)
    echo -n "* Current branch '$gcb' is considered as "
    case ${gcb%-*} in
      master|$master)
        echo "stable branch."
        echo "* - Run gf to create hotfix or leave :)"
      ;;
      "$DEV")
        echo "developing branch."
        echo "* - Do some bugfixes..."
        echo "* - Run gf MYFEATURE to create new feature."
        echo "* - Run gf to create release branch."
      ;;
      release)
        echo "release branch."
        echo "* - Do some bugfixes..."
        echo "* - Run gf to merge all bugfixes into $DEV (hit No, Yes)."
        echo "* - Run gf to create stable branch (hit Yes)."
      ;;
      hotfix)
        echo "hotfix branch."
        echo "* - Do some hotfixes..."
        echo "* - Run gf to merge hotfix into stable branch and"
        echo "* - and into $DEV is necessary (hit Yes or No)."
      ;;
      *)
        echo "feature branch."
        echo "* - Develop current feature..."
        echo "* - Run gf to merge it into $DEV."
    esac
    echo "***"
  }

  function gf_help {
    local help_file bwhite nc
    nc=$'\e[m'
    bwhite=$'\e[1;37m'
    help_file="$DATAPATH/${script_name}.help"
    [ -f "$help_file" ] || err "Help file not found" || return 1
    cat "$help_file" | fmt -w $(tput cols) \
    | sed "s/\(^\| \)\(--\?[a-zA-Z]\+\|$script_name\|^[A-Z].\+\)/\1\\$bwhite\2\\$nc/g"
  }

  function gf_version {
    local version
    version="$DATAPATH/VERSION"
    [ -f "$version" ] || err "Version file not found" || return 1
    echo -n "GNU gf "
    cat "$version"
  }

  major=0
  minor=0
  patch=0
  [[ -f "$VERSION" ]] && IFS=. read major minor patch < "$VERSION"
  master=${major}.$minor

  # load user options
  while [ $# -gt 0 ]; do
      case $1 in
     -f|--force) force=1; shift ;;
     -t|--tips) gf_tips; return $? ;;
     -i|--init) init=1; shift ;;
     -v|--version) gf_version; return $? ;;
     -h|-\?|--help) gf_help; return $? ;;
      --) shift; break ;;
      *-) echo "$0: Unrecognized option '$1'" >&2; return 1 ;;
       *) break ;;
    esac
  done

  # init gf
  [[ $init == 1 ]] && { gf_init && gf_tips; return $?; }

  # run gf
  local branch
  branch="${1:-}"
  gf_check && gf_run "$branch" && gf_tips || {
    case $? in
      2) err "Initializing gf may help (see man gf)" || return 2 ;;
      3) err "Forcing gf may help (see man gf)" || return 3 ;;
    esac
  }
  [[ $stash == 1 ]] && { git_stash_pop || return 1; }

}

main "$@"