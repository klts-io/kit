#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} tag: fetch and checkout to the tag"
    exit 2
fi

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

TAG="$1"
ORIGIN="origin-push-${TAG}"

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi

SOURCE="${SOURCE:-}"

if [[ "${GH_TOKEN:-}" != "" ]]; then
    SOURCE=$(echo ${SOURCE} | sed "s#https://github.com#https://bot:${GH_TOKEN}@github.com#g")
fi

git remote add "${ORIGIN}" "${SOURCE}"

git push "${ORIGIN}" "${TAG}"
