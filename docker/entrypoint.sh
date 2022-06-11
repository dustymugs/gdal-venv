#!/bin/bash

if [ "$1" == version ]; then
  . $USER_VENV/bin/activate

  set -e

  cd /home/pygdal
  git clone https://${GITHUB_TOKEN}:@github.com/dustymugs/pygdal.git pygdal

  cd pygdal
  git remote set-url origin "https://${GITHUB_TOKEN}:@github.com/dustymugs/pygdal.git"

  VERSION="$2"
  BRANCH="v$VERSION"
  MESSAGE="add support for $VERSION"

  git checkout -b "$BRANCH"
  python import.py "$VERSION"
  echo "$VERSION" >> VERSIONS
  git add .
  git commit -m "$MESSAGE"
  git push origin "$BRANCH"
  gh pr create -B master --title "$MESSAGE" --body "Done by deploy docker image"
	gh pr merge -m -b "automated merge" "$BRANCH}"
else
  exec "$@"
fi
