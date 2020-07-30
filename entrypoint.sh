#!/usr/bin/env bash

set -e

CURRENT_TAG=${GITHUB_REF/refs\/tags\//}
PREV_TAG=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1  --max-count=1))


for path in ${FILES}
do
   echo path
done

