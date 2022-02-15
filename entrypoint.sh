#!/usr/bin/env bash

set -e

if [[ $GITHUB_EVENT_NAME != 'release' && -z "$4" ]]; then
  echo "Skipping: This should only run on release not '$GITHUB_EVENT_NAME'.";
  exit 0;
fi

SERVER_URL=$(echo "$GITHUB_SERVER_URL" | awk -F/ '{print $3}')

echo "Setting up 'temp_sync_release_version' remote..."

git ls-remote --exit-code temp_sync_release_version 1>/dev/null 2>&1 && exit_status=$? || exit_status=$?

if [[ $exit_status -ne 0 ]]; then
  echo "No 'temp_sync_release_version' remote found"
  echo "Creating 'temp_sync_release_version' remote..."
  git remote remove temp_sync_release_version 2>/dev/null || true
  git remote add temp_sync_release_version "https://${INPUT_TOKEN}@${SERVER_URL}/${GITHUB_REPOSITORY}"
else
  echo "Found 'temp_changed_files' remote"
fi

git fetch temp_sync_release_version +refs/tags/*:refs/tags/*

FILES=$INPUT_FILES
TAG=$(git describe --abbrev=0 --tags "$(git rev-list --tags --skip=1  --max-count=1 2>&1)" 2>&1) && exit_status=$? || exit_status=$?
NEW_TAG=${4:-"${GITHUB_REF/refs\/tags\//}"}
PATTERN=$INPUT_PATTERN

if [[ $exit_status -ne 0 ]]; then
  echo "::warning::Initial release detected no updates would be made to specified files."
  echo "::warning::Setting new_version and old_version to $NEW_TAG."
  echo "::set-output name=is_initial_release::true"
  echo "::set-output name=new_version::$NEW_TAG"
  echo "::set-output name=old_version::$NEW_TAG"
  exit 0;
else
  echo "::set-output name=is_initial_release::false"
fi

CURRENT_TAG=${3:-"$TAG"}

for path in ${FILES}
do
   echo "Replacing $CURRENT_TAG with $NEW_TAG for: $path"
   sed -i "s|$PATTERN$CURRENT_TAG|$PATTERN$NEW_TAG|g" "$path"
done

echo "::set-output name=new_version::$NEW_TAG"
echo "::set-output name=old_version::$CURRENT_TAG"
