#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NAMES="${1:-}"
ARCHS="${2:-}"
VERSION="${3:-}"
RELEASE="${4:-00}"

declare -A ARCH_MAP
ARCH_MAP["amd64"]="amd64"
ARCH_MAP["arm"]="armhf"
ARCH_MAP["arm64"]="arm64"
ARCH_MAP["ppc64le"]="ppc64el"
ARCH_MAP["s390x"]="s390x"

ROOT="/root"
SRC="${ROOT}/src"
PKG_PATH="${ROOT}/output"
DEBBUILD="${ROOT}/debbuild"
DEBREPO="${ROOT}/debrepo"
PUBLIC="${ROOT}/.aptly/public"
SRC_PATH="${DEBBUILD}/debs"
NOTAR="${NOTAR:-}"

IFS=, NAMES_SLICE=(${NAMES})
IFS=, ARCHS_SLICE=(${ARCHS})

for arch in ${ARCHS_SLICE[@]}; do
    for name in ${NAMES_SLICE[@]}; do
        echo "Building ${name} DEB's for ${arch}"
        pkg="${PKG_PATH}/linux/${arch}/${name}"
        src="${SRC_PATH}/${name}-${VERSION}"

        mkdir -p "${src}"
        cp -r "${SRC}/${name}"/* "${src}/"

        if [[ "${NOTAR}" != "true" ]]; then
            cp -r "${pkg}"/* "${src}/"
        fi

        debarch="${ARCH_MAP[$arch]}"
        cd "${SRC_PATH}/${name}-${VERSION}"

        declare -A define
        define["_version"]="${VERSION}"
        define["_release"]="${RELEASE}"
        define["_arch"]="${debarch}"
        define["_goarch"]="${arch}"

        for key in ${!define[@]}; do
            sed -i "s#%{${key}}#${define[${key}]}#g" ./debian/changelog
            sed -i "s#%{${key}}#${define[${key}]}#g" ./debian/control
            sed -i "s#%{${key}}#${define[${key}]}#g" ./debian/rules
        done

        dpkg-buildpackage --unsigned-source --unsigned-changes --build=binary --host-arch "${debarch}"
    done
done

COMPONENT=main

mv "${DEBREPO}/pool/${COMPONENT}"/*/*/*.deb "${SRC_PATH}/" || true
aptly repo create -comment="kubernetes-lts" -component="${COMPONENT}" -distribution="stable" kubernetes-lts
aptly repo add kubernetes-lts "${SRC_PATH}"/*.deb

aptly publish repo -distribution="stable" -skip-signing kubernetes-lts
rm -rf "${DEBREPO}"/*
mv "${PUBLIC}"/* "${DEBREPO}"
