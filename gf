#!/bin/bash

set -eu

: ${DATAPATH:=.}
: ${CHANGELOG:=CHANGELOG}
: ${VERSION:=VERSION}
: ${DEV:=dev}

function main {

  # defaults and constants
  local ec line script_name
  local -r DONE="[ done ]" SKIPPED="[ skipped ]" FAILED="[ failed ]"
  script_name="gf"

  # process options
  if ! line=$(
    getopt -n "$0" \
           -o ivh\? \
           -l init,version,help\
           -- "$@"
  )
  then return 1; fi
  eval set -- "$line"

  function err {
    echo "$(basename "${0}")[error]: $@" >&2
    return 1
  }

  function git_status_empty {
    [[ -z "$(git status --porcelain)" ]] && return 0
    err "Uncommited changes" || return 1
  }

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

  function confirm {
    echo -n "${@:-"Are you sure?"} [$(locale yesstr)/$(locale nostr)] "
    read
    [[ "$REPLY" =~ $(locale yesexpr) ]]
  }

  function gf_check {
    git_repo_exists \
      || err "Git repository does not exist" \
      || return 2
    { git_branch_exists "$DEV" && git_branch_exists master; } \
      || err "Missing branches '$DEV' or master" \
      || return 2
    git_status_empty \
      || return 1
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

  function create_temp_branch {
    local branch
    # set branch name and increment version
    branch="hotfix-${master}.$((++patch))"
    [[ $origbranch == "$DEV" ]] \
      && branch="release-${major}.$((++minor))" \
      && patch=0
    [[ $patch == 0 ]] \
      && { confirm "* Create release branch from branch '$DEV'?" || return 0; } \
      || { confirm "* Create hotfix?" || return 0; }
    [[ $origbranch == master ]] \
      && { git_branch $master || return 1; }
    # create a new branch
    git_branch_exists $branch \
      && { err "Destination branch '$branch' already exists" || return 1; }
    git_branch $branch || return 1
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
    git commit -am "$branch" >/dev/null || return 1
    if [[ $origbranch == "$DEV" ]]; then
      git_checkout "$DEV" \
      && git_merge --no-ff $branch \
      && git_checkout $branch \
      || return 1
    fi
    echo $DONE
  }

  function merge_feature {
    local commits
    commits="$(git log "$DEV"..$origbranch --pretty=format:"#   %s")"
    [[ -n $commits ]] \
      || err "Nothing to merge - feature branch '$origbranch' is empty" \
      || return 1
    confirm "* Merge feature '$origbranch'?" || return 0
    local tmpfile
    [[ -n "$(git log $origbranch.."$DEV")" ]] \
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
      echo -e "$commits"
      echo -e "#"
    } >> "$tmpfile"
    "${EDITOR:-vi}" "$tmpfile"
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

  function origbranch_into {
    echo -n "Merging '$origbranch' into branch '$1': " \
      && git_checkout $1 \
      && git_merge --no-ff $origbranch \
      && echo $DONE
  }

  function merge_branches {
    echo -n "Merging '$1' into branch '$2': " \
      && git_checkout "$2" \
      && git_merge $1 \
      && echo $DONE
    }

  function delete_branch {
    echo -n "Deleting branch '$origbranch': "
    git branch -r | grep origin/$origbranch$ >/dev/null \
      && { git push origin :refs/heads/$origbranch >/dev/null || return 1; }
    git branch -d $origbranch >/dev/null || return 1
    echo $DONE
  }

  # Current branch:
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

    # set variables
    local origbranch major minor patch tag master
    origbranch="$(git rev-parse --abbrev-ref HEAD)"
    tag=""
    IFS=. read major minor patch < "$VERSION"
    master=${major}.$minor

    # proceed
    case ${origbranch%-*} in

      HEAD)
        err "No branch detected on current HEAD" || return 1
        ;;

      "$DEV"|master|$master)
        create_temp_branch
        ;;

      hotfix)
        confirm "* Merge hotfix?" || return 0
        if [[ -z "$(git log $master..master)" ]]; then
          origbranch_into "$DEV" \
            && origbranch_into $master \
            && git tag ${master}.$patch >/dev/null \
            && merge_branches $master master \
            || return 1
        else
          confirm "* Merge hotfix into '$DEV'?" \
            && { origbranch_into "$DEV" || return 1; }
          origbranch_into $master \
            && git tag ${master}.$patch >/dev/null \
            || return 1
        fi
        delete_branch
        ;;

      release)
        if confirm "* Create stable branch from release?"; then
          origbranch_into "$DEV" \
            && git_checkout master \
            && git_branch $master \
            && { [[ -n "$(git log $master..master)" ]] || origbranch_into master; } \
            && merge_branches master $master \
            && git tag ${master}.0 >/dev/null \
            && delete_branch \
            || return 1
        else
          confirm "* Merge branch release into branch '$DEV'?" || return 0;
          origbranch_into "$DEV" \
            && git_checkout $origbranch \
            || return 1
        fi
        ;;

      *)
        merge_feature
        origbranch_into "$DEV"
        delete_branch
    esac
  }

  function init_files {
    echo -n "Initializing files on branch '$1': "
    [[ ! -f "$VERSION" || -z "$(cat "$VERSION")" ]] \
      && { echo 0.0.0 > "$VERSION" || return 1; }
    [[ ! -f "$CHANGELOG" || -z "$(cat "$CHANGELOG")" ]] \
      && { echo "$CHANGELOG created" > "$CHANGELOG" || return 1; }
    git_status_empty 2>/dev/null && echo $SKIPPED && return 0
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
    git_repo_exists \
      && { git_branch master || return 1; } \
      || { git init >/dev/null || return 1; }
    echo $DONE
    # init files on master and $DEV
    git_status_empty \
      && init_files master \
      && git_branch "$DEV" \
      && init_files "$DEV"
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

  # load user options
  while [ $# -gt 0 ]; do
      case $1 in
     -i|--init) gf_init; return $? ;;
     -v|--version) gf_version; return $? ;;
     -h|-\?|--help) gf_help; return $? ;;
      --) shift; break ;;
      *-) echo "$0: Unrecognized option '$1'" >&2; return 1 ;;
       *) break ;;
    esac
  done

  # run gf
  gf_check && gf_run || {
    ec=$?
    [[ $ec == 2 ]] \
      && { err "Initializing gf may help (see man gf)" || return $ec; }
  }

}

main "$@"