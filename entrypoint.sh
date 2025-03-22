#!/usr/bin/env bash

set -euo pipefail

if [[ $GITHUB_EVENT_NAME != 'release' && -z $INPUT_CURRENT_VERSION ]]; then
  echo "Skipping: This should only run on release not '$GITHUB_EVENT_NAME'.";
  exit 0;
fi

git fetch origin +refs/tags/*:refs/tags/*

NEW_TAG=${INPUT_NEW_VERSION:-"${GITHUB_REF/refs\/tags\//}"}
CURRENT_TAG=$INPUT_CURRENT_VERSION && exit_status=$? || exit_status=$?
PATTERN=$INPUT_PATTERN

if [[ -z "$CURRENT_TAG" ]]; then
  CURRENT_TAG=$(git tag --sort=-v:refname | grep -vE "^v[0-9]+$" | head -n 2 | tail -n 1) && exit_status=$? || exit_status=$?
fi

if [[ -n "$INPUT_STRIP_PREFIX" ]]; then
  CURRENT_TAG=${CURRENT_TAG#"$INPUT_STRIP_PREFIX"}
  NEW_TAG=${NEW_TAG#"$INPUT_STRIP_PREFIX"}
fi

if [[ $exit_status -ne 0 ]]; then
  echo "::warning::Initial release detected no updates would be made to specified files."
  echo "::warning::Setting new_version and old_version to $NEW_TAG."

  cat <<EOF >> "$GITHUB_OUTPUT"
is_initial_release=true
new_version=$NEW_TAG
old_version=$NEW_TAG
EOF
  exit 0;
else
  echo "is_initial_release=false" >> "$GITHUB_OUTPUT"
fi

# Get commit hash for current tag if use_tag_commit_hash is true
if [[ "$INPUT_USE_TAG_COMMIT_HASH" == "true" ]]; then
  CURRENT_COMMIT_HASH=$(git rev-parse "$CURRENT_TAG" 2>/dev/null || git rev-parse HEAD)
  NEW_COMMIT_HASH=$(git rev-parse "$NEW_TAG" 2>/dev/null || git rev-parse HEAD)
  CURRENT_PATTERN="$CURRENT_COMMIT_HASH # $CURRENT_TAG"
  NEW_PATTERN="$NEW_COMMIT_HASH # $NEW_TAG"
else
  CURRENT_PATTERN="$PATTERN$CURRENT_TAG"
  NEW_PATTERN="$PATTERN$NEW_TAG"
fi

if [[ "$INPUT_ONLY_MAJOR" == "true" ]]; then
  NEW_MAJOR_TAG=$(echo "$NEW_TAG" | cut -d. -f1)
  CURRENT_MAJOR_TAG=$(echo "$CURRENT_TAG" | cut -d. -f1)

  if [[ "$NEW_MAJOR_TAG" == "$CURRENT_MAJOR_TAG" ]]; then
    echo "Skipping: This will only run on major version release not '$NEW_TAG'.";
    cat <<EOF >> "$GITHUB_OUTPUT"
new_version=$NEW_TAG
old_version=$CURRENT_TAG
major_update=false
EOF
  else
    for path in $INPUT_PATHS
    do
       echo "Replacing major version $CURRENT_MAJOR_TAG with $NEW_MAJOR_TAG for: $path"
       if [[ "$INPUT_USE_TAG_COMMIT_HASH" == "true" ]]; then
         sed -i "s|$CURRENT_PATTERN|$NEW_PATTERN|g" "$path"
       else
         sed -i "s|$PATTERN$CURRENT_MAJOR_TAG\(.[[:digit:]]\)\{0,1\}\(.[[:digit:]]\)\{0,1\}|$PATTERN$NEW_MAJOR_TAG|g" "$path"
       fi
    done

    cat <<EOF >> "$GITHUB_OUTPUT"
new_version=$NEW_MAJOR_TAG
old_version=$CURRENT_TAG
major_update=true
EOF
  fi
else
  NEW_MAJOR_TAG=$(echo "$NEW_TAG" | cut -d. -f1)
  if [[ "$NEW_TAG" == "$NEW_MAJOR_TAG" ]]; then
    echo "::warning::New version $NEW_TAG is a major version, skipping minor and patch version updates. You can set only_major to true to prevent this warning."
  else
    for path in $INPUT_PATHS
    do
       echo "Replacing $CURRENT_TAG with $NEW_TAG for: $path"
       sed -i "s|$CURRENT_PATTERN|$NEW_PATTERN|g" "$path"
    done
  fi

  cat <<EOF >> "$GITHUB_OUTPUT"
new_version=$NEW_TAG
old_version=$CURRENT_TAG
major_update=true
EOF
fi
