#!/usr/bin/env bash

set -e

if [[ $GITHUB_EVENT_NAME != 'release' ]]; then
  echo "Skipping: This should only run on release not '$GITHUB_EVENT_NAME'.";
  exit 0;
fi

FILES=$2
NEW_TAG=${GITHUB_REF/refs\/tags\//}
CURRENT_TAG=${3:-$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1  --max-count=1))}

if [[ -z $CURRENT_TAG ]]; then
  echo "Unable to determine where changes need to be updated."
  echo "Please create a initial release before running this action."
  exit 0;
fi

for path in ${FILES}
do
   echo "Replacing $CURRENT_TAG with $NEW_TAG for: $path"
   sed -i "s|$CURRENT_TAG|$NEW_TAG|g" "$path"
done

