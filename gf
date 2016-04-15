#!/bin/bash

: ${DATAPATH:=.}
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

  function git_branch_empty {
    [[ -n "$(git log --first-parent --no-merges $1 ^master)" ]] \
      && return 0
    err "Branch $1 is empty"
    return 1
  }

  function confirm {
    echo -n "${@:-"Are you sure?"} [$(locale yesstr)/$(locale nostr)] "
    read
    [[ "$REPLY" =~ $(locale yesexpr) ]]
  }

  function err {
    echo "$(basename "${0}")[error]: $@" >&2
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

    # init check
    git_repo_exists || return 2
    git_branch_exists dev || return 2
    git_branch_exists master || return 2
    git_status_empty || return 1
    [[ -f "$VERSION" && -f "$CHANGELOG" ]] \
      || err "Missing working files" \
      || return 2

    # set variables
    local curbranch major minor patch tag master oIFS iprod_msg prod_msg
    curbranch=$(git rev-parse --abbrev-ref HEAD)
    oIFS=$IFS
    IFS=.
    read major minor patch < "$VERSION"
    IFS=$oIFS
    master=${major}.$minor

    # proceed
    case ${curbranch%-*} in

      dev|master|$master)
        local branch code header
        # set branch name and increment version
        branch="hotfix-${master}.$((++patch))"
        [[ $curbranch == dev ]] \
          && branch="release-${major}.$((++minor))" \
          && patch=0
        confirm "Create $branch from $curbranch?" || return 1
        # try create a new branch
        git checkout -b $branch
        code=$?
        # branch already exists, checkout on it
        [[ $code == 128 ]] && git checkout $branch
        # checkout failed
        [[ $code != 0 ]] && return 1
        # update version
        echo ${major}.${minor}.$patch > "$VERSION"
        # commit changed $VERSION
        [[ $curbranch != dev ]] \
          && git commit -am $branch \
          && return 1
        # write header to $CHANGELOG
        header="${major}.${minor} | $(date "+%Y-%m-%d")"
        printf '\n%s\n\n%s\n' "$header" "$(<$CHANGELOG)" > "$CHANGELOG"
        # commit $CHANGELOG and $VERSION
        git commit -am "$branch"
        ;;

      hotfix)
        tag=${master}.$patch
        iprod_msg="Merge $curbranch into production branch $master?"
        ;&

      release)
        [[ -z "$tag" ]] && tag=${master}.0
        [[ -z "$iprod_msg" ]] && iprod_msg="Merge $curbranch into separete production branch $master?"
        ;&

      *)
        # feature
        if [[ -z "$tag" ]]; then
          git_branch_empty $curbranch || return 1
          confirm "Merge feature $curbranch into dev?" || return 1
          local tmpfile
          git rebase dev || return 1
          tmpfile="$(mktemp)"
          # prepare message for $CHANGELOG
          {
            echo -e "\n# Changelog messages"
            echo -e "# ----------------"
            echo -e "# commits:"
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
        else
          confirm "Merge feature $curbranch into dev?" || return 1
        fi
        # merge to dev
        git checkout dev \
          && git merge --no-ff $curbranch \
          || return 1
        # not feature, confirm merge branch to master
        local rcode1 rcode2
        rcode1=0
        rcode2=0
        prod_msg="Merge $curbranch into master?"
        if [[ -n "$tag" ]]; then
          confirm "$iprod_msg"
          rcode1=$?
          [[ $rcode1 == 0 ]] \
            && git checkout master \
            && ( git checkout $master 2>/dev/null || git checkout -b $master ) \
            && git merge --no-ff $curbranch \
            && git tag $tag
          confirm "$prod_msg"
          rcode2=$?
          [[ $rcode2 == 0 ]] \
            && git checkout master \
            && git merge $master \
            && git checkout $master
        fi
        # exit if not merge release or hotfix
        [[ $rcode1 == 1 && $rcode2 == 1 ]] && return 0
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
  # - create dev branch
  function gf_init {
    # init git repo
    git_repo_exists 2>/dev/null
    if [ $? == 1 ]; then
      git init || return 1
    else
      git checkout master 2>/dev/null \
        || git checkout -b master \
        || return 1
    fi
    git_status_empty || return 1
    # create $VERSION file
    [[ ! -f "$VERSION" ]] \
      && echo 0.0.0 > "$VERSION" \
      && echo "version file $VERSION created"
    # create $CHANGELOG file
    [[ ! -f "$CHANGELOG" ]] \
      && echo "$CHANGELOG created" | tee "$CHANGELOG"
    git add "$VERSION" "$CHANGELOG" \
      && git commit -m "init version and changelog files"
    # create and checkout dev branch
    git checkout dev 2>/dev/null \
      || git checkout -b dev \
      || return 1
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
  gf

}

main "$@"