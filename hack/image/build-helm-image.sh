#!/usr/bin/env bash

# usage:
# $1 - GOARCH
# $2 - helm image name

set -eux

source hack/lib/test_lib.sh

ROOTDIR="$(pwd)"
GOTMP="$(mktemp -d -p $GOPATH/src)"
trap_add 'rm -rf $GOTMP' EXIT
BASEIMAGEDIR="$GOTMP/helm-operator"
mkdir -p "$BASEIMAGEDIR"

# build operator binary and base image
pushd "$BASEIMAGEDIR"
GOARCH=$1 go run "$ROOTDIR/hack/image/helm/scaffold-helm-image.go"

mkdir -p build/_output/bin/
cp $ROOTDIR/build/operator-sdk-dev-${1}-linux-gnu build/_output/bin/helm-operator
operator-sdk build $2
popd
