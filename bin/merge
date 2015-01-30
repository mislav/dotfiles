#!/usr/bin/env bash
# Usage: merge [<BRANCH>]
#
# Sophisticated git merge with integrated CI check and automatic cleanup upon
# completion.
#
# When BRANCH is specified, merge it into the current branch. When blank, merge
# current branch into the main branch (default: master).
#
# - Fast-forwards BRANCH to latest version (if applicable)
# - Checks if BRANCH passed CI
# - Fast-forwards target branch to latest version
# - Merges BRANCH into target branch
# - Pushes target branch upstream
# - Deletes BRANCH both locally and on its remote.
#
# Depends on: hub v1.10.6

set -e

branch="$1"
upstream_name=origin
upstream_branch=""

symbolic_full_name() {
  local output
  if output="$(git rev-parse --symbolic-full-name "$@" 2>/dev/null)"; then
    echo "${output#refs/remotes/}"
  else
    return 1
  fi
}

current_branch="$(git symbolic-ref -q HEAD)"
current_branch="${current_branch#refs/heads/}"
if main_branch="$(symbolic_full_name "$upstream_name")"; then
  main_branch="${main_branch#*/}"
else
  main_branch=master
fi

# previously checked-out branch
[ "$branch" = "-" ] && branch="$(symbolic_full_name '@{-1}')"

if [ -n "$branch" ]; then
  branch="${branch#refs/heads/}"
  target_branch="$current_branch"
else
  branch="$current_branch"
  target_branch="$main_branch"
fi

if [ "$branch" = "$target_branch" ]; then
  echo "Refusing to merge '$branch' into itself!" >&2
  exit 1
fi

if upstream="$(symbolic_full_name "${branch}@{u}")"; then
  upstream_remote="${upstream%%/*}"
  upstream_branch="${upstream#*/}"
fi

if [ -n "$upstream_branch" ]; then
  git fetch -q "$upstream_remote" "$upstream_branch"
fi

if ! output="$(hub ci-status "$branch" 2>&1)"; then
  echo "hub ci-status: $output" >&2
  exit 1
fi

git fetch -q "$upstream_name" "$target_branch"
git checkout -q "$target_branch"
git merge --ff-only @{u}

into=""
[ "$target_branch" = "$main_branch" ] || into=" into $target_branch"
git merge --no-ff "$branch" -m "Merge branch '${upstream_branch:-$branch}'${into}" --edit
git push "$upstream_name" "$target_branch"

git branch -d "$branch"

if [ -n "$upstream_branch" ]; then
  git branch -dr "${upstream_remote}/${upstream_branch}"
  git push "$upstream_remote" --delete "$upstream_branch"
fi
