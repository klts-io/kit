#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

ORIGIN="origin"
REPOS="${REPOS:-}"
REPOSDIR="${REPOSDIR}/${REPOS}"
SOURCE="${SOURCE:-$(helper::repos::get_base_repository)}"
BRANCH_PREFIX="${BRANCH_PREFIX:-}"
BRANCH="${BRANCH:-${BRANCH_PREFIX}$(helper::workdir::version)}"

if [[ ! -d "${REPOSDIR}/.git" ]]; then
    mkdir -p "${REPOSDIR}" && cd "${REPOSDIR}" && {
        git init .

        if [[ "${GH_TOKEN:-}" != "" ]]; then
            SOURCE=$(echo ${SOURCE} | sed "s#https://github.com#https://bot:${GH_TOKEN}@github.com#g")
        fi

        git remote add "${ORIGIN}" "${SOURCE}"
    }
fi

cd "${REPOSDIR}" && {
    git add *
    git commit -m "Automatic synchronize ${BRANCH}"
    git branch -M "${BRANCH}"
    git push -f -u "${ORIGIN}" "${BRANCH}"
}
