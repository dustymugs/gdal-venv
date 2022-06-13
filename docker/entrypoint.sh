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
  MESSAGE="Add GDAL $VERSION"

  ARCHIVE="v$VERSION.tar.gz"
  URL="https://github.com/OSGeo/gdal/archive/$ARCHIVE"
  LOCAL="/tmp/$ARCHIVE"
  wget $URL -O $LOCAL

  git checkout -b "$BRANCH"
  python import.py "$VERSION"
  echo "$VERSION" >> VERSIONS
  git add .
  git commit -m "$MESSAGE"
  git push origin "$BRANCH"
  gh pr create -B master --title "$MESSAGE" --body "Done by deploy docker image"
  gh pr merge -m -b "automated merge" "$BRANCH"

  cd /tmp
  mkdir gdal
  tar xf $LOCAL -C gdal --strip-components=1
  cd gdal
  if [ -d ./gdal ]; then
    cd gdal
  fi
  if [ -f ./CMakeLists.txt ]; then
    mkdir build
    cd build
    cmake ..
    cmake --build .
  else
    ./autogen.sh
    ./configure
    make
  fi
  export PATH="$(pwd)/apps:$PATH"

  cd /home/pygdal/pygdal
  publish $VERSION
else
  exec "$@"
fi
