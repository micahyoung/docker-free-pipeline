#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if ! [ -d state/ ]; then
  exit "No State, exiting"
  exit 1
fi

source ./state/env.sh
true ${CONCOURSE_TARGET:?"!"}
true ${CONCOURSE_URL:?"!"}
true ${CONCOURSE_USERNAME:?"!"}
true ${CONCOURSE_PASSWORD:?"!"}
true ${CONCOURSE_PIPELINE:?"!"}
true ${ROOTFS_REPO:?"!"}

fly login \
  --target $CONCOURSE_TARGET \
  --concourse-url $CONCOURSE_URL \
  --username $CONCOURSE_USERNAME \
  --password $CONCOURSE_PASSWORD \
;

fly set-pipeline \
  --config pipeline.yml \
  --pipeline $CONCOURSE_PIPELINE \
  -v rootfs_repo=$ROOTFS_REPO \
  --target $CONCOURSE_TARGET \
  -n \
;

fly trigger-job \
  --job $CONCOURSE_PIPELINE/build \
  --target $CONCOURSE_TARGET \
  --watch \
;
