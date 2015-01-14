#!/usr/bin/env bash
if [ "$1" != "-f" ]
then
  echo "Building Web UI"
  cd www
  pub build --mode=release
  cd ..
fi
dart server/bin/start.dart
