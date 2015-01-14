#!/usr/bin/env bash
set -e
if [ "$1" != "-f" ]
then
  echo "Building Web UI"
  cd www
  pub build --mode=release
  cd ..
fi
set +e
dart server/bin/start.dart
exit=${?}
if [ ${exit} == 5 ]
then
  ./start.sh
else
  exit ${exit}
fi