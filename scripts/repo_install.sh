#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_GITHUB="${SOURCE_ROOT}/shared/.github"

usage() {
  cat <<'EOF'
Usage: scripts/repo_install.sh [--prune] [TARGET]

Install the shared Copilot configuration pack into TARGET.

- TARGET defaults to the current working directory.
- TARGET may be either a repository root or a direct .github directory.
- --prune enables rsync --delete for exact mirroring.
EOF
}

PRUNE=false
TARGET_INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prune)
      PRUNE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "${TARGET_INPUT}" ]]; then
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 1
      fi
      TARGET_INPUT="$1"
      ;;
  esac
  shift
done

TARGET_INPUT="${TARGET_INPUT:-$(pwd)}"

if [[ ! -d "${SOURCE_GITHUB}" ]]; then
  echo "Expected source directory not found: ${SOURCE_GITHUB}" >&2
  exit 1
fi

if [[ "$(basename "${TARGET_INPUT}")" == ".github" ]]; then
  TARGET_GITHUB="${TARGET_INPUT}"
else
  TARGET_GITHUB="${TARGET_INPUT}/.github"
fi

mkdir -p "${TARGET_GITHUB}"

RSYNC_ARGS=(-av)
if [[ "${PRUNE}" == true ]]; then
  RSYNC_ARGS+=(--delete)
fi

rsync "${RSYNC_ARGS[@]}" \
  "${SOURCE_GITHUB}/" \
  "${TARGET_GITHUB}/"

MODE="merged safely"
if [[ "${PRUNE}" == true ]]; then
  MODE="mirrored with prune"
fi

echo "Installed Copilot customisations into ${TARGET_GITHUB} (${MODE})"
