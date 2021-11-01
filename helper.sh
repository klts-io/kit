#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

KITDIR="$(dirname "${BASH_SOURCE}")"
ROOT="${ROOT:-${KITDIR}/..}"
OUTPUT="${OUTPUT:-${ROOT}/output}"
PATCHESDIR="${PATCHESDIR:-${ROOT}/patches}"
REPOSDIR="${REPOSDIR:-${ROOT}/repos}"
TMPDIR="${TMP_DIR:-./tmp}"
CONFIG="${CONFIG:-${ROOT}/releases.yml}"

KITDIR=$(realpath -m ${KITDIR})
ROOT=$(realpath -m ${ROOT})
OUTPUT=$(realpath -m ${OUTPUT})
PATCHESDIR=$(realpath -m ${PATCHESDIR})
REPOSDIR=$(realpath -m ${REPOSDIR})
TMPDIR=$(realpath -m ${TMPDIR})
CONFIG=$(realpath -m ${CONFIG})

mkdir -p "${TMPDIR}"

function helper::download() {
    local patch="$1"
    if ! [[ "${patch}" =~ ^https?:// ]]; then
        echo "$(realpath -m ${ROOT}/${patch})"
        return
    fi
    local tmp_patch="${TMPDIR}/$(basename ${patch})"
    if ! [[ -f "${tmp_patch}" ]]; then
        echo "+++ Downloading patch to ${tmp_patch} from ${patch}" 1>&2
        curl -o "${tmp_patch}" -sSL "${patch}"
    fi
    echo ${tmp_patch}
}

function helper::workdir::version() {
    local version=$(cd "${WORKDIR}" && git describe --tags)
    echo "${version}"
}

function helper::config::get_base_repository() {
    cat "${CONFIG}" | yq ".base" | tr -d '"'
}

readonly REPO=$(helper::config::get_base_repository)

function helper::config::get_base_release() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"$1\" ) | .base_release" | tr -d '"'
}

function helper::config::get_patches() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"$1\" ) | .patches | .[]?" | tr -d '"'
}

function helper::config::get_patches_all() {
    base_chain=$(helper::config::base_chain $1)
    for base in ${base_chain}; do
        cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${base}\" ) | .patches | .[]?" | tr -d '"'
    done
}

function helper::config::get_test_failures_tolerated() {
    base_chain=$(helper::config::base_chain $1)
    for base in ${base_chain}; do
        cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${base}\" ) | .test_failures_tolerated | .[]?" | tr -d '"'
    done
}

function helper::config::get_test_integration_failures_tolerated() {
    base_chain=$(helper::config::base_chain $1)
    for base in ${base_chain}; do
        cat "${CONFIG}" | yq ".releases | .[] | select( .name == \"${base}\" ) | .test_integration_failures_tolerated | .[]?" | tr -d '"'
    done
}

function helper::config::base_chain() {
    base="$1"
    while [[ "${base}" != "" ]]; do
        echo "${base}"
        base=$(helper::config::get_base_release "${base}")
    done
}

function helper::config::get_patch() {
    local list=""
    for patch in $@; do
        patches=$(cat "${CONFIG}" | yq ".patches | .[] | select( .name == \"${patch}\" ) | .patch | .[]?" | tr -d '"')
        for item in ${patches}; do
            list+=" $(helper::download ${item})"
        done
    done
    echo "${list}"
}

function helper::config::list_releases() {
    cat "${CONFIG}" | yq ".releases | .[] | select( .must == true ) | .name" | tr -d '"'
}

function helper::repos::get_base_repository() {
    cd "${ROOT}" && git remote get-url origin | sed -E 's#git@(.+):(.+)#https://\1/\2#g'
}

function helper::repos::branch() {
    echo repos
}

WORKDIR="${WORKDIR:-${ROOT}/src/${REPO##*//}}"
WORKDIR=$(realpath -m ${WORKDIR})

function helper::show() {
    echo "KITDIR:     ${KITDIR}"
    echo "ROOT:       ${ROOT}"
    echo "OUTPUT:     ${OUTPUT}"
    echo "PATCHESDIR: ${PATCHESDIR}"
    echo "REPOSDIR:   ${REPOSDIR}"
    echo "TMPDIR:     ${TMPDIR}"
    echo "CONFIG:     ${CONFIG}"
    echo "REPO:       ${REPO}"
    echo "WORKDIR:    ${WORKDIR}"
}

if [[ "$(git config --global user.name)" == "" ]]; then
    git config --global user.name "bot"
fi
