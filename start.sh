#!/usr/bin/env bash
echo "Building Web UI"
cd www
pub build --mode=release
cd ..
dart server/bin/start.dart

