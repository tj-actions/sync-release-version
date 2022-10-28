#!/usr/bin/env bash

set -e

if [[ $GITHUB_EVENT_NAME != 'release' && -z $INPUT_CURRENT_VERSION ]]; then
  echo "Skipping: This should only run on release not '$GITHUB_EVENT_NAME'.";
  exit 0;
fi

git fetch origin +refs/tags/*:refs/tags/*

NEW_TAG=${INPUT_NEW_VERSION:-"${GITHUB_REF/refs\/tags\//}"}
CURRENT_TAG=$INPUT_CURRENT_VERSION && exit_status=$? || exit_status=$?
PATTERN=$INPUT_PATTERN

if [[ -z "$CURRENT_TAG" ]]; then
  TAG=$(git describe --abbrev=0 --tags "$(git rev-list --tags --skip=1  --max-count=1 2>&1)" 2>&1) && exit_status=$? || exit_status=$?
  CURRENT_TAG=$TAG
fi

if [[ $exit_status -ne 0 ]]; then
  echo "::warning::Initial release detected no updates would be made to specified files."
  echo "::warning::Setting new_version and old_version to $NEW_TAG."
  echo "::set-output name=is_initial_release::true"
  echo "::set-output name=new_version::$NEW_TAG"
  echo "::set-output name=old_version::$NEW_TAG"
  git remote remove temp_sync_release_version 2>/dev/null || true
  exit 0;
else
  echo "::set-output name=is_initial_release::false"
fi

if [[ "$INPUT_ONLY_MAJOR" == "true" ]]; then
  NEW_MAJOR_TAG=$(echo "$NEW_TAG" | cut -d. -f1)
  CURRENT_MAJOR_TAG=$(echo "$CURRENT_TAG" | cut -d. -f1)

  if [[ "$NEW_MAJOR_TAG" == "$CURRENT_MAJOR_TAG" ]]; then
    echo "Skipping: This will only run on major version release not '$NEW_TAG'.";
    echo "::set-output name=major_update::false"
  else
    for path in $INPUT_PATHS
    do
       echo "Replacing major version $CURRENT_MAJOR_TAG with $NEW_MAJOR_TAG for: $path"
       sed -i "s|$PATTERN$CURRENT_MAJOR_TAG\(.[[:digit:]]\)\{0,1\}\(.[[:digit:]]\)\{0,1\}|$PATTERN$NEW_MAJOR_TAG|g" "$path"
    done

    if [[ -z "$GITHUB_OUTPUT" ]]; then
      echo "::set-output name=new_version::$NEW_MAJOR_TAG"
      echo "::set-output name=old_version::$CURRENT_TAG"
      echo "::set-output name=major_update::true"
    else
      echo "new_version=$NEW_MAJOR_TAG" >> "$GITHUB_OUTPUT"
      echo "old_version=$CURRENT_TAG" >> "$GITHUB_OUTPUT"
      echo "major_update=true" >> "$GITHUB_OUTPUT"
    fi
  fi
else
  for path in $INPUT_PATHS
  do
     echo "Replacing $CURRENT_TAG with $NEW_TAG for: $path"
     sed -i "s|$PATTERN$CURRENT_TAG|$PATTERN$NEW_TAG|g" "$path"
  done
  
  if [[ -z "$GITHUB_OUTPUT" ]]; then
    echo "::set-output name=new_version::$NEW_TAG"
    echo "::set-output name=old_version::$CURRENT_TAG"
  else
    echo "new_version=$NEW_TAG" >> "$GITHUB_OUTPUT"
    echo "old_version=$CURRENT_TAG" >> "$GITHUB_OUTPUT"
  fi
fi
