#!/bin/bash

set -e -x

docker build \
  -t sssocpaulcote/fmt-api \
  docker/

docker push sssocpaulcote/fmt-api
