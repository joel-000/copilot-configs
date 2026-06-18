#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_GITHUB="${SOURCE_ROOT}/shared/.github"

usage() {
  cat <<'EOF'
Usage: scripts/pycharm_install.sh [--copilot-home PATH] [--force] [--allow-outside-home]

Create user-level symlinks for Copilot config directories used by PyCharm.

- --copilot-home sets the base directory (default: ~/.copilot).
- --force replaces conflicting files, directories, or symlinks.
- --allow-outside-home allows --copilot-home outside of $HOME.
EOF
}

COPILOT_HOME="${HOME}/.copilot"
FORCE=false
ALLOW_OUTSIDE_HOME=false

canonicalize_path() {
  realpath -m -- "$1"
}

assert_no_symlink_chain() {
  local path="$1"
  local probe="/"
  local part

  IFS='/' read -r -a parts <<< "${path#/}"
  for part in "${parts[@]}"; do
    [[ -z "${part}" ]] && continue
    probe="${probe%/}/${part}"
    if [[ -L "${probe}" ]]; then
      echo "Rejected symlink path component: ${probe}" >&2
      exit 1
    fi
  done
}

validate_copilot_home() {
  if [[ -z "${COPILOT_HOME}" ]]; then
    echo "Invalid --copilot-home: value must not be empty" >&2
    exit 1
  fi
  if [[ "${COPILOT_HOME}" == "." || "${COPILOT_HOME}" == ".." ]]; then
    echo "Invalid --copilot-home: use an explicit directory path" >&2
    exit 1
  fi

  COPILOT_HOME_CANONICAL="$(canonicalize_path "${COPILOT_HOME}")"
  HOME_CANONICAL="$(canonicalize_path "${HOME}")"

  if [[ "${COPILOT_HOME_CANONICAL}" == "/" ]]; then
    echo "Invalid --copilot-home: canonical path must not be root" >&2
    exit 1
  fi

  if [[ "${ALLOW_OUTSIDE_HOME}" != true && "${COPILOT_HOME_CANONICAL}" != "${HOME_CANONICAL}" && "${COPILOT_HOME_CANONICAL}" != "${HOME_CANONICAL}/"* ]]; then
    echo "Invalid --copilot-home: ${COPILOT_HOME_CANONICAL} is outside HOME (${HOME_CANONICAL}); use --allow-outside-home to override." >&2
    exit 1
  fi

  assert_no_symlink_chain "${COPILOT_HOME_CANONICAL}"
}

validate_force_target() {
  local target_dir="$1"
  local category="$2"
  local expected_dir="${COPILOT_HOME_CANONICAL}/${category}"

  if [[ "${target_dir}" != "${expected_dir}" ]]; then
    echo "Refusing to replace unexpected target path: ${target_dir}" >&2
    exit 1
  fi

  case "${category}" in
    instructions|agents|prompts|skills)
      ;;
    *)
      echo "Refusing to replace disallowed category: ${category}" >&2
      exit 1
      ;;
  esac

  if [[ -L "${target_dir}" ]]; then
    echo "Refusing to replace symlink target at ${target_dir}" >&2
    exit 1
  fi

  assert_no_symlink_chain "$(dirname "${target_dir}")"
  if [[ "$(canonicalize_path "${target_dir}")" != "${expected_dir}" ]]; then
    echo "Refusing to replace target after canonical validation: ${target_dir}" >&2
    exit 1
  fi
}

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
    --allow-outside-home)
      ALLOW_OUTSIDE_HOME=true
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

validate_copilot_home
mkdir -p -- "${COPILOT_HOME_CANONICAL}"

link_directory() {
  local source_dir="$1"
  local target_dir="$2"
  local category="$3"

  if [[ ! -e "${target_dir}" && ! -L "${target_dir}" ]]; then
    ln -s -- "${source_dir}" "${target_dir}"
    echo "Linked ${target_dir} -> ${source_dir}"
    return
  fi

  if [[ -L "${target_dir}" ]]; then
    local current_target
    current_target="$(readlink -- "${target_dir}")"
    if [[ "${current_target}" == "${source_dir}" ]]; then
      echo "Already linked ${target_dir} -> ${source_dir}"
      return
    fi
    echo "Conflicting symlink at ${target_dir}: ${current_target}" >&2
    echo "Refusing symlink replacement; remove it manually and rerun." >&2
    exit 1
  fi

  if [[ "${FORCE}" != true ]]; then
    echo "Conflicting path exists at ${target_dir}" >&2
    echo "Use --force to replace it." >&2
    exit 1
  fi

  validate_force_target "${target_dir}" "${category}"
  rm -rf -- "${target_dir}"
  ln -s -- "${source_dir}" "${target_dir}"
  echo "Replaced path ${target_dir} -> ${source_dir}"
}

for category in instructions agents prompts skills; do
  source_dir="${SOURCE_GITHUB}/${category}"
  target_dir="${COPILOT_HOME_CANONICAL}/${category}"
  if [[ ! -d "${source_dir}" ]]; then
    echo "Expected source category not found: ${source_dir}" >&2
    exit 1
  fi
  link_directory "${source_dir}" "${target_dir}" "${category}"
done

echo "Linked PyCharm Copilot customisations under ${COPILOT_HOME_CANONICAL}"
