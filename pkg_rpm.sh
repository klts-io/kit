#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

NAMES="${1:-}"
ARCHS="${2:-}"
VERSION="${3:-}"
RELEASE="${4:-}"
NOTAR="${NOTAR:-}"

SRC="${ROOT}/hack/rpm/"
RPMBUILD="${ROOT}/rpmbuild/"
RPMREPO="${REPOSDIR}/rpm/"
PKG_PATH="${OUTPUT}"

docker build -t rpm-builder "${KITDIR}/rpm/"

mkdir -p "${RPMREPO}"

docker run --rm -e NOTAR="${NOTAR}" -v "${SRC}:/root/src" -v "${PKG_PATH}:/root/output/" -v "${RPMBUILD}:/root/rpmbuild/" -v "${RPMREPO}:/root/rpmrepo/" rpm-builder "${NAMES}" "${ARCHS}" "${VERSION}" "${RELEASE}"
