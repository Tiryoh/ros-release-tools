#!/usr/bin/env bash
set -eu

INPUT_VERSION=$1
echo release ${INPUT_VERSION}

# Check duplication
if find . | grep CHANGELOG.rst | xargs grep ${INPUT_VERSION} ||
   git branch -a | grep release-${INPUT_VERSION} ||
   git ls-remote --exit-code origin ${INPUT_VERSION}; then
  echo "Release already exists. Nothing to do." >&2
  exit 0
fi
update=false
if git ls-remote --exit-code origin release-${INPUT_VERSION}; then
  update=true
  echo "Release candidate branch already exists. Updating." >&2
  ORIGIN_BRANCH=`git rev-parse --abbrev-ref HEAD`
fi

# Fetch all history to generate changelog
git fetch --tags --prune

# Update Changelog
if find . | grep CHANGELOG.rst; then
    catkin_generate_changelog
else
    catkin_generate_changelog --all
fi

if ${update}
then
  # Store updated CHANGELOGs
  git stash

  # Update release candidate branch
  git checkout release-${INPUT_VERSION}
  if git merge --no-edit ${ORIGIN_BRANCH} | (grep "Already up to date.")
  then
    echo "Release already updated. Nothing to do." >&2
    exit 0
  fi

  # Overwrite CHANGELOGs
  git checkout stash@{0} $(find . -name CHANGELOG.rst)
else
  git checkout -b release-${INPUT_VERSION}
fi

git add $(find . -name CHANGELOG.rst)
git commit -m "docs: Update changelog"

# Bump up version
catkin_prepare_release -y --no-push --version ${INPUT_VERSION}
git tag -d ${INPUT_VERSION}
