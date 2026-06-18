#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_GITHUB="${SOURCE_ROOT}/shared/.github"

usage() {
  cat <<'EOF'
Usage: scripts/pycharm_install.sh [--copilot-home PATH] [--force]

Create user-level symlinks for Copilot config directories used by PyCharm.

- --copilot-home sets the base directory (default: ~/.copilot).
- --force replaces conflicting files, directories, or symlinks.
EOF
}

COPILOT_HOME="${HOME}/.copilot"
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copilot-home)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --copilot-home" >&2
        usage >&2
        exit 1
      fi
      COPILOT_HOME="$2"
      shift
      ;;
    --force)
      FORCE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unexpected argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ ! -d "${SOURCE_GITHUB}" ]]; then
  echo "Expected source directory not found: ${SOURCE_GITHUB}" >&2
  exit 1
fi

mkdir -p "${COPILOT_HOME}"

link_directory() {
  local source_dir="$1"
  local target_dir="$2"

  if [[ ! -e "${target_dir}" && ! -L "${target_dir}" ]]; then
    ln -s "${source_dir}" "${target_dir}"
    echo "Linked ${target_dir} -> ${source_dir}"
    return
  fi

  if [[ -L "${target_dir}" ]]; then
    local current_target
    current_target="$(readlink "${target_dir}")"
    if [[ "${current_target}" == "${source_dir}" ]]; then
      echo "Already linked ${target_dir} -> ${source_dir}"
      return
    fi
    if [[ "${FORCE}" != true ]]; then
      echo "Conflicting symlink at ${target_dir}: ${current_target}" >&2
      echo "Use --force to replace it." >&2
      exit 1
    fi
    rm -f "${target_dir}"
    ln -s "${source_dir}" "${target_dir}"
    echo "Replaced symlink ${target_dir} -> ${source_dir}"
    return
  fi

  if [[ "${FORCE}" != true ]]; then
    echo "Conflicting path exists at ${target_dir}" >&2
    echo "Use --force to replace it." >&2
    exit 1
  fi

  rm -rf "${target_dir}"
  ln -s "${source_dir}" "${target_dir}"
  echo "Replaced path ${target_dir} -> ${source_dir}"
}

for category in instructions agents prompts skills; do
  source_dir="${SOURCE_GITHUB}/${category}"
  target_dir="${COPILOT_HOME}/${category}"
  if [[ ! -d "${source_dir}" ]]; then
    echo "Expected source category not found: ${source_dir}" >&2
    exit 1
  fi
  link_directory "${source_dir}" "${target_dir}"
done

echo "Linked PyCharm Copilot customisations under ${COPILOT_HOME}"
