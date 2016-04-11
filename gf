#!/bin/bash

: ${CHANGELOG:=CHANGELOG}
: ${VERSION:=VERSION}

function main {

  # defaults and constants
  local line script_name
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

  function git_status_empty {
    [[ -z "$(git status --porcelain)" ]] && return 0
    err "Uncommited changes"
    return 1
  }

  function git_branch_exists {
    git rev-parse --verify "$1" 1>/dev/null 2>/dev/null && return 0
    err "Branch $1 does not exist"
    return 1
  }

  function git_repo_exists {
    [[ -d .git ]] && return 0
    err "Git repository does not exist"
    return 1
  }

  function confirm {
    echo -n "${@:-"Are you sure?"} [$(locale yesstr)/$(locale nostr)] "
    read
    [[ "$REPLY" =~ $(locale yesexpr) ]]
  }

  function err {
    echo "${0}[error]: $@" >&2
    return 1
  }

  # Current branch:
  #
  #  dev
  #   - increment minor version, set patch to 0
  #   - create release-major.minor branch
  #
  #  master, major.minor (eg. 1.10)
  #   - increment patch version
  #   - create hotfix-major.minor.patch branch
  #
  #  hotfix-x or release-x; alias current
  #   - merge dev branch with current
  #   - prompt to merge master with current
  #   - ^ yes: merge master with current, add tag to master
  #   - ^ success: prompt to merge major.minor with master
  #   - ^ yes: merge major.minor with master
  #   - prompt to delete current
  #
  #  feature
  #   - update version history
  #   - merge dev branch with feature
  #   - prompt to delete branch
  function gf {

    git_repo_exists || return 1

    local curbranch major minor patch tag master oIFS

    curbranch=$(git rev-parse --abbrev-ref HEAD) || return 1
    git_status_empty || return 1

    # read version
    oIFS=$IFS
    IFS=.
    read major minor patch < "$VERSION"
    IFS=$oIFS

    master=${major}.$minor

    case ${curbranch%-*} in

      dev|master|$master)
        local branch code header
        # set branch name and increment version
        branch="hotfix-${master}.$((++patch))"
        [[ $curbranch == dev ]] \
          && branch="release-${major}.$((++minor))" \
          && patch=0
        # try create a new branch
        git checkout -b $branch
        code=$?
        # branch already exists, checkout on it
        [[ $code == 128 ]] && git checkout $branch
        # checkout failed
        [[ $code != 0 ]] && return 1
        # update version
        echo ${major}.${minor}.$patch > $VERSION
        # commit changed $VERSION
        [[ $curbranch != dev ]] \
          && git commit -am $branch \
          && return 1
        # write header to $CHANGELOG
        header="${major}.${minor} | $(date "+%Y-%m-%d")"
        printf '\n%s\n\n%s\n' "$header" "$(<$CHANGELOG)" > $CHANGELOG
        # commit $CHANGELOG and run gf on new branch
        git commit -am $branch \
          && gf \
          && git checkout $branch
        ;;

      hotfix)
        tag=${master}.$patch
        ;&

      release)
        [[ -z "$tag" ]] && tag=${master}.0
        ;&

      *)
        # feature
        if [[ -z "$tag" ]]; then
          local tmpfile
          git rebase dev || return 1
          tmpfile="$(mktemp)"
          # prepare message for $CHANGELOG
          {
            echo -e "\n# commits:"
            git log dev..$curbranch --pretty=format:"#   %s"
            echo -e "\n# Please enter the message for your changes. Lines starting"
            echo -e "# with # and empty lines will be ignored."
          } >> "$tmpfile"
          "${EDITOR:-vi}" "$tmpfile"
          # remove comments and empty lines
          sed -i '/^\s*\(#\|$\)/d;/^\s+/d' "$tmpfile"
          # write to $CHANGELOG
          cat "$CHANGELOG" >> "$tmpfile" && mv "$tmpfile" "$CHANGELOG"
          git commit -am "Version history updated"
        fi
        # merge to dev
        git checkout dev \
          && git merge --no-ff $curbranch \
          || return 1
        # not feature, confirm merge branch to master
        [[ -n "$tag" ]] \
          && confirm "Merge branch '$curbranch' into $master?" \
          && git checkout master \
          && ( git checkout $master || git checkout -b $master ) \
          && git merge --no-ff $curbranch \
          && git tag $tag \
          && confirm "Merge branch '$master' into master?" \
          && git checkout master \
          && git merge $master \
          && git checkout $master
        # confirm delete branch, including remote
        if confirm "Delete branch '$curbranch'?"; then
          git branch -r | grep origin/$curbranch$ >/dev/null \
            && git push origin :refs/heads/$curbranch
          git branch -d $curbranch
        fi
    esac
  }

  # Prepare enviroment for gf:
  # - create $VERSION and $CHANGELOG file
  # - create dev branch (from master)
  function gf_init {
    local commit checkout_master
    checkout_master=true
    # init git repo
    git_repo_exists 2>/dev/null || { git init; checkout_master=false; }
    git_status_empty 2>/dev/null || return 1
    commit=false
    # checkout to master if it isn't new pository
    $checkout_master \
      && { git checkout master 2>/dev/null \
      || { echo "Branch master not found"; return 1; }; }
    # create $VERSION file
    [[ ! -f $VERSION ]] \
      && echo 0.0.0 > $VERSION \
      && echo "version file $VERSION created" \
      && commit=true
    # create $CHANGELOG file
    [[ ! -f $CHANGELOG ]] \
      && touch $CHANGELOG \
      && echo "changelog file $CHANGELOG created" \
      && commit=true
    # commit changes
    $commit \
      && git add -A \
      && git commit -am "init git flow"
    # create dev branch
    git_branch_exists dev 2>/dev/null || git branch dev
    git checkout dev
  }

  function gf_help {
    local help_file bwhite nc
    nc=$'\e[m'
    bwhite=$'\e[1;37m'
    help_file="${script_name}.help"
    [ -f $help_file ] || err "Help file not found" || return 1
    cat $help_file | fmt -w $(tput cols) \
    | sed "s/\(^\| \)\(--\?[a-zA-Z]\+\|$script_name\|^[A-Z].\+\)/\1\\$bwhite\2\\$nc/g"
  }

  function gf_version {
    [ -f "VERSION" ] || err "Version file not found" || return 1
    echo -n "GNU gf "
    cat "VERSION"
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
  gf

}

main "$@"