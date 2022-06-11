#!/bin/bash

if [ "$1" == version ]; then
  . $USER_VENV/bin/activate

  cd /home/pygdal
  git clone https://${GITHUB_TOKEN}:@github.com/dustymugs/pygdal.git pygdal
  cd pygdal

  VERSION="$2"
  git checkout -b "v$VERSION"
  python import.py "$2"
  git add .

  message = "add support for v$VERSION"
  git commit -m "$message"
  gh pr create -B master -t "$message"
else
  exec "$@"
fi
