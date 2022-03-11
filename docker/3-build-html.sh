#!/bin/bash

set -e -x

docker pull sssocpaulcote/fmt-api

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

docker run \
  --rm \
  -v $PWD/build:/tmp/work/build \
  -v $PWD/source:/tmp/work/source \
  sssocpaulcote/fmt-api \
  bundle exec middleman build --verbose --clean

echo "Docker built as root, need to give file permissions back to the user"
sudo chown -R $USER build
$SCRIPT_DIR/split-projects.sh
