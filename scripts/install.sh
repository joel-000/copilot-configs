#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_ROOT="${1:-$(pwd)}"

mkdir -p "${TARGET_ROOT}/.github"

rsync -av --delete \
  "${SOURCE_ROOT}/shared/.github/" \
  "${TARGET_ROOT}/.github/"

if [[ -f "${SOURCE_ROOT}/shared/AGENTS.md" ]]; then
  cp "${SOURCE_ROOT}/shared/AGENTS.md" "${TARGET_ROOT}/AGENTS.md"
fi

echo "Installed Copilot customisations into ${TARGET_ROOT}"
