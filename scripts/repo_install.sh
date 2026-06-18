#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_GITHUB="${SOURCE_ROOT}/shared/.github"

usage() {
  cat <<'EOF'
Usage: scripts/repo_install.sh [--prune --confirm-prune] [TARGET]

Install the shared Copilot configuration pack into TARGET.

- TARGET defaults to the current working directory.
- TARGET may be either a repository root or a direct .github directory.
- --prune enables rsync --delete for exact mirroring.
- --confirm-prune is required when using --prune.
EOF
}

PRUNE=false
CONFIRM_PRUNE=false
TARGET_INPUT=""

canonicalize_path() {
  realpath -m -- "$1"
}

to_absolute_path() {
  local input="$1"
  if [[ "${input}" == /* ]]; then
    printf '%s\n' "${input}"
  else
    printf '%s/%s\n' "$(pwd)" "${input}"
  fi
}

normalize_path() {
  local input="$1"
  while [[ "${input}" != "/" && "${input}" == */ ]]; do
    input="${input%/}"
  done
  printf '%s\n' "${input}"
}

reject_unsafe_target_input() {
  local input="$1"
  if [[ "${input}" == -* ]]; then
    echo "Rejected unsafe target argument (starts with '-'): ${input}" >&2
    exit 1
  fi
  if [[ "${input}" =~ (^|/)\.\.(/|$) ]]; then
    echo "Rejected traversal target argument: ${input}" >&2
    exit 1
  fi
}

assert_no_symlink_chain() {
  local path="$1"
  local absolute_path
  local probe="/"
  local part

  absolute_path="$(to_absolute_path "${path}")"
  IFS='/' read -r -a parts <<< "${absolute_path#/}"
  for part in "${parts[@]}"; do
    [[ -z "${part}" ]] && continue
    probe="${probe%/}/${part}"
    if [[ -L "${probe}" ]]; then
      echo "Rejected symlink path component: ${probe}" >&2
      exit 1
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prune)
      PRUNE=true
      ;;
    --confirm-prune)
      CONFIRM_PRUNE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      if [[ $# -gt 1 ]]; then
        echo "Unexpected extra argument: $2" >&2
        usage >&2
        exit 1
      fi
      if [[ $# -eq 1 ]]; then
        if [[ -n "${TARGET_INPUT}" ]]; then
          echo "Unexpected argument: $1" >&2
          usage >&2
          exit 1
        fi
        TARGET_INPUT="$1"
      fi
      break
      ;;
    -*)
      echo "Unexpected option: $1" >&2
      usage >&2
      exit 1
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
reject_unsafe_target_input "${TARGET_INPUT}"

if [[ "${PRUNE}" == true && "${CONFIRM_PRUNE}" != true ]]; then
  echo "Error: --prune requires --confirm-prune" >&2
  exit 1
fi

if [[ ! -d "${SOURCE_GITHUB}" ]]; then
  echo "Expected source directory not found: ${SOURCE_GITHUB}" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "Required command not found: rsync" >&2
  exit 1
fi

if [[ "$(basename "${TARGET_INPUT}")" == ".github" ]]; then
  TARGET_GITHUB_INPUT="${TARGET_INPUT}"
else
  TARGET_GITHUB_INPUT="${TARGET_INPUT}/.github"
fi
TARGET_GITHUB_ABSOLUTE="$(normalize_path "$(to_absolute_path "${TARGET_GITHUB_INPUT}")")"

if [[ -L "${TARGET_GITHUB_ABSOLUTE}" ]]; then
  echo "Rejected symlink destination: ${TARGET_GITHUB_ABSOLUTE}" >&2
  exit 1
fi
assert_no_symlink_chain "$(dirname "${TARGET_GITHUB_ABSOLUTE}")"

TARGET_GITHUB_CANONICAL="$(canonicalize_path "${TARGET_GITHUB_ABSOLUTE}")"

if [[ "${TARGET_GITHUB_CANONICAL}" == "/" || "${TARGET_GITHUB_CANONICAL}" == "/.github" ]]; then
  echo "Dangerous target rejected: ${TARGET_GITHUB_CANONICAL}" >&2
  exit 1
fi

if [[ -e "${TARGET_GITHUB_CANONICAL}" && ! -d "${TARGET_GITHUB_CANONICAL}" && ! -L "${TARGET_GITHUB_CANONICAL}" ]]; then
  echo "Target path exists but is not a directory: ${TARGET_GITHUB_CANONICAL}" >&2
  exit 1
fi

if [[ -L "${TARGET_GITHUB_ABSOLUTE}" ]]; then
  echo "Rejected symlink destination during canonical validation: ${TARGET_GITHUB_ABSOLUTE}" >&2
  exit 1
fi

assert_no_symlink_chain "$(dirname "${TARGET_GITHUB_ABSOLUTE}")"

nearest_existing="$(dirname "${TARGET_GITHUB_CANONICAL}")"
while [[ ! -e "${nearest_existing}" ]]; do
  nearest_existing="$(dirname "${nearest_existing}")"
done
if [[ ! -w "${nearest_existing}" ]]; then
  echo "Target path is not writable: ${nearest_existing}" >&2
  exit 1
fi

mkdir -p -- "${TARGET_GITHUB_CANONICAL}"

RSYNC_ARGS=(-av)
if [[ "${PRUNE}" == true ]]; then
  RSYNC_ARGS+=(--delete)
fi

if [[ ! -d "${SOURCE_GITHUB}" || ! -d "${TARGET_GITHUB_CANONICAL}" ]]; then
  echo "Validation failed before sync; source or target directory missing." >&2
  exit 1
fi

if [[ -L "${TARGET_GITHUB_ABSOLUTE}" ]]; then
  echo "Rejected symlink destination during pre-sync validation: ${TARGET_GITHUB_ABSOLUTE}" >&2
  exit 1
fi

assert_no_symlink_chain "$(dirname "${TARGET_GITHUB_ABSOLUTE}")"
if [[ "$(canonicalize_path "${TARGET_GITHUB_ABSOLUTE}")" != "${TARGET_GITHUB_CANONICAL}" ]]; then
  echo "Destination changed during validation: ${TARGET_GITHUB_CANONICAL}" >&2
  exit 1
fi

rsync "${RSYNC_ARGS[@]}" \
  -- \
  "${SOURCE_GITHUB}/" \
  "${TARGET_GITHUB_CANONICAL}/"

MODE="merged safely"
if [[ "${PRUNE}" == true ]]; then
  MODE="mirrored with prune"
fi

echo "Installed Copilot customisations into ${TARGET_GITHUB_CANONICAL} (${MODE})"
