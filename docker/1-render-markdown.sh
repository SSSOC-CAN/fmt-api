#!/bin/bash

set -e -x

docker pull sssocpaulcote/fmt-api

docker run \
  --rm \
  -e WS_ENABLED \
  -e FMTD_FORK \
  -e FMTD_COMMIT \
  -v $PWD/build:/tmp/work/build \
  -v $PWD/templates:/tmp/work/templates \
  -v $PWD/source:/tmp/work/source \
  sssocpaulcote/fmt-api \
  ./update.sh
