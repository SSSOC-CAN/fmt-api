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
  eval $INSTALL_CMD
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
  export PROTO_DIR PROTO_SRC_DIR WS_ENABLED COMMIT REPO_URL COMMAND COMPONENT APPEND_TO_FILE GRPC_PORT REST_PORT EXCLUDE_SERVICES DOCS_COMMIT DOCS_REPO_URL
  ./render.py
  cat templates/${COMPONENT}_footer.md >> $APPEND_TO_FILE
}

# Generic options.
WS_ENABLED="${WS_ENABLED:-true}"
FMTD_FORK="${FMTD_FORK:-SSSOC-CAN}"
FMTD_COMMIT="${FMTD_COMMIT:-build_tags}"
PROTO_ROOT_DIR="build/protos"

# Remove previously generated templates.
rm -rf $PROTO_ROOT_DIR
rm -rf source/*.html.md

########################
## Compile docs for fmtd
########################
REPO_URL="https://github.com/${FMTD_FORK}/fmtd"
DOCS_REPO_URL="https://github.com/${FMTD_FORK}/laniakea-api"
CHECKOUT_COMMIT="main"
DOCS_COMMIT="master"
COMPONENT=fmtd
COMMAND=lanicli
PROTO_SRC_DIR=lanirpc
EXCLUDE_PROTOS="none"
EXCLUDE_SERVICES='["Controller", "Datasource"]'
INSTALL_CMD="make install"
APPEND_TO_FILE=source/fmtd.html.md
GRPC_PORT=7777
REST_PORT=8080
compile
