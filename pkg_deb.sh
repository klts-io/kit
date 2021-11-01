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

SRC="${ROOT}/deb/"
DEBBUILD="${ROOT}/debbuild/"
DEBREPO="${REPOSDIR}/deb/"
PKG_PATH="${OUTPUT}"

docker build -t deb-builder "${KITDIR}/deb/"

mkdir -p "${DEBREPO}"

docker run --rm -e NOTAR="${NOTAR}"  -v "${SRC}:/root/src" -v "${PKG_PATH}:/root/output/" -v "${DEBBUILD}:/root/debbuild/" -v "${DEBREPO}:/root/debrepo/" deb-builder "${NAMES}" "${ARCHS}" "${VERSION#v}" "${RELEASE}"
