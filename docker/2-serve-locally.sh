#!/bin/bash

set -e -x

docker pull sssocpaulcote/fmt-api

docker run \
  --rm \
  -p 4567:4567 \
  -v $PWD/source:/tmp/work/source \
  sssocpaulcote/fmt-api \
  bundle exec middleman server
