#!/usr/bin/env bash

set -e

if [[ $GITHUB_EVENT_NAME != 'release' && -z "$4" ]]; then
  echo "Skipping: This should only run on release not '$GITHUB_EVENT_NAME'.";
  exit 0;
fi

TOKEN=$1
REPOSITORY=$6


git remote set-url origin "https://$TOKEN@github.com/$REPOSITORY"

git fetch origin +refs/tags/*:refs/tags/*

FILES=$2
CURRENT_TAG=${3:-$(git describe --abbrev=0 --tags "$(git rev-list --tags --skip=1  --max-count=1)" || true)}
NEW_TAG=${4:-"${GITHUB_REF/refs\/tags\//}"}
PATTERN=$5

if [[ -z $CURRENT_TAG ]]; then
  echo "::warning::Unable to determine where changes need to be updated"
  echo "::warning::Please create a initial release before running this action."
  echo "::set-output name=new_version::$NEW_TAG"
  echo "::set-output name=old_version::$NEW_TAG"
  exit 0;
fi

for path in ${FILES}
do
   echo "Replacing $CURRENT_TAG with $NEW_TAG for: $path"
   sed -i "s|$PATTERN$CURRENT_TAG|$PATTERN$NEW_TAG|g" "$path"
done

echo "::set-output name=new_version::$NEW_TAG"
echo "::set-output name=old_version::$CURRENT_TAG"
