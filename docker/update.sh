#!/bin/bash

set -e

function compile() {
  echo "Using ${COMPONENT} repo URL ${REPO_URL} and commit ${CHECKOUT_COMMIT}"

  PROTO_DIR=$PROTO_ROOT_DIR/$COMPONENT
  LOCAL_REPO_PATH=/tmp/$COMPONENT
  if [[ ! -d $LOCAL_REPO_PATH ]]; then
    git clone $REPO_URL $LOCAL_REPO_PATH
  fi

  # Update the repository to the respective CHECKOUT_COMMIT and install the binary.
  pushd $LOCAL_REPO_PATH
  COMMIT=$(git rev-parse HEAD)
  git reset --hard HEAD
  git pull
  git checkout $CHECKOUT_COMMIT
  COMMIT=$(git rev-parse HEAD)
  eval $GOOS_CMD
  eval $GOARCH_CMD
  eval $GOPATH_CMD
  eval $INSTALL_CMD
  # eval $MV_EXE_CMD
  # which fmtd
  # which fmtcli
  popd

  # Copy over all proto and json files from the checked out lnd source directory.
  mkdir -p $PROTO_DIR
  rsync -a --prune-empty-dirs --include '*/' --include '*.proto' --include '*.json' --exclude '*' $LOCAL_REPO_PATH/$PROTO_SRC_DIR/ $PROTO_DIR/

  pushd $PROTO_DIR
  proto_files=$(find . -name '*.proto' -not -name $EXCLUDE_PROTOS)
  protoc -I. -I/usr/local/include \
    --doc_out=json,generated.json:. $proto_files
  popd

  # Render the new docs.
  cp templates/${COMPONENT}_header.md $APPEND_TO_FILE
  export PROTO_DIR PROTO_SRC_DIR WS_ENABLED COMMIT REPO_URL COMMAND COMPONENT APPEND_TO_FILE GRPC_PORT REST_PORT EXCLUDE_SERVICES
  ./render.py
  cat templates/${COMPONENT}_footer.md >> $APPEND_TO_FILE
}

# Generic options.
WS_ENABLED="${WS_ENABLED:-true}"
FMTD_FORK="${FMTD_FORK:-SSSOC-CAN}"
FMTD_COMMIT="${FMTD_COMMIT:-main}"
PROTO_ROOT_DIR="build/protos"

# Remove previously generated templates.
rm -rf $PROTO_ROOT_DIR
rm -rf source/*.html.md

########################
## Compile docs for fmtd
########################
REPO_URL="https://github.com/${FMTD_FORK}/fmtd"
CHECKOUT_COMMIT=$FMTD_COMMIT
COMPONENT=fmtd
COMMAND=fmtcli
PROTO_SRC_DIR=fmtrpc
EXCLUDE_PROTOS="none"
GOOS_CMD="export GOOS=\"windows\""
GOARCH_CMD="export GOARCH=\"386\""
GOPATH_CMD="export GOPATH=~/go && export PATH=${PATH}:${GOPATH}/bin"
MV_EXE_CMD="cp /usr/local/go/bin/windows_386/fmtd.exe ~/go/bin && cp /usr/local/go/bin/windows_386/fmtcli.exe ~/go/bin"
INSTALL_CMD="make install"
APPEND_TO_FILE=source/fmtd.html.md
GRPC_PORT=3567
REST_PORT=8080
compile
