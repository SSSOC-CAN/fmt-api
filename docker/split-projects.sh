#!/bin/bash

set -e -x

ls -la build
rm -rf build/fmtd
mv build/all build/fmtd
cp build/fmtd/fmtd.html build/fmtd/index.html
