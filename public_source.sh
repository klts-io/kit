#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

cd "${ROOT}"

VERSION=$(helper::workdir::version)
./kit/git_push_tag.sh "${VERSION}"
