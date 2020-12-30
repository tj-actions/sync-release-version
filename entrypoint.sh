#!/usr/bin/env bash

set -e

if [[ $GITHUB_EVENT_NAME != 'release' && -z "$4" ]]; then
  echo "Skipping: This should only run on release not '$GITHUB_EVENT_NAME'.";
  exit 0;
fi

FILES=$2
CURRENT_TAG=${3:-$(git describe --abbrev=0 --tags "$(git rev-list --tags --skip=1  --max-count=1)")}
NEW_TAG=${4:-"${GITHUB_REF/refs\/tags\//}"}
PREFIX=$5
COMMIT=$6

if [[ -z $CURRENT_TAG ]]; then
  echo "Unable to determine where changes need to be updated."
  echo "Please create a initial release before running this action."
  exit 0;
fi

for path in ${FILES}
do
   echo "Replacing $CURRENT_TAG with $NEW_TAG for: $path"
   sed -i "s|$PREFIX$CURRENT_TAG|$PREFIX$NEW_TAG|g" "$path"
done

git config user.name github-actions
git config user.email github-actions@github.com
git fetch --depth=1 origin "${GITHUB_BASE_REF}:${GITHUB_BASE_REF}"

if [[ $(git status --porcelain) ]]; then
  if [[  "$COMMIT" != "true" ]]; then
    echo "::warning::Uncommited changes found"
    git status
  else
    # Changes
    echo "Committing changes..."
    git stash
    git branch "upgrade-to-$NEW_TAG" "${GITHUB_BASE_REF}"
    git checkout "upgrade-to-$NEW_TAG"
    git stash pop
    git commit -am "Updraded from $CURRENT_TAG -> $NEW_TAG"
  fi
else
  echo "No changes made."
  exit 0
fi


echo "::set-output name=new_version::$NEW_TAG"
echo "::set-output name=old_version::$CURRENT_TAG"
