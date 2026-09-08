#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_SOURCE="${SOURCE_ROOT}/copilot"
MANAGED_DIRECTORIES=(instructions agents prompts skills)
MANAGED_FILES=(copilot-instructions.md)

COPILOT_HOME="${HOME}/.copilot"
FORCE=false
ALLOW_OUTSIDE_HOME=false

usage() {
  cat <<'EOF'
Usage: scripts/global_install.sh [--copilot-home PATH] [--force] [--allow-outside-home]

Create global user-level symlinks for Copilot config files and directories.

- --copilot-home sets the base directory (default: ~/.copilot).
- --force replaces conflicting files, directories, or symlinks.
- --allow-outside-home allows --copilot-home outside of $HOME.
EOF
}

canonicalize_path() {
  realpath -m -- "$1"
}

reject_symlink_components() {
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

parse_arguments() {
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
}

validate_source_tree() {
  local item

  if [[ ! -d "${COPILOT_SOURCE}" ]]; then
    echo "Expected source directory not found: ${COPILOT_SOURCE}" >&2
    exit 1
  fi

  for item in "${MANAGED_DIRECTORIES[@]}"; do
    if [[ ! -d "${COPILOT_SOURCE}/${item}" ]]; then
      echo "Expected source directory not found: ${COPILOT_SOURCE}/${item}" >&2
      exit 1
    fi
  done

  for item in "${MANAGED_FILES[@]}"; do
    if [[ ! -f "${COPILOT_SOURCE}/${item}" ]]; then
      echo "Expected source file not found: ${COPILOT_SOURCE}/${item}" >&2
      exit 1
    fi
  done
}

prepare_copilot_home() {
  if [[ -z "${COPILOT_HOME}" ]]; then
    echo "Invalid --copilot-home: value must not be empty" >&2
    exit 1
  fi
  if [[ "${COPILOT_HOME}" == "." || "${COPILOT_HOME}" == ".." ]]; then
    echo "Invalid --copilot-home: use an explicit directory path" >&2
    exit 1
  fi

  local home_canonical
  home_canonical="$(canonicalize_path "${HOME}")"
  COPILOT_HOME="$(canonicalize_path "${COPILOT_HOME}")"

  if [[ "${COPILOT_HOME}" == "/" ]]; then
    echo "Invalid --copilot-home: canonical path must not be root" >&2
    exit 1
  fi

  if [[ "${ALLOW_OUTSIDE_HOME}" != true && "${COPILOT_HOME}" != "${home_canonical}" && "${COPILOT_HOME}" != "${home_canonical}/"* ]]; then
    echo "Invalid --copilot-home: ${COPILOT_HOME} is outside HOME (${home_canonical}); use --allow-outside-home to override." >&2
    exit 1
  fi

  reject_symlink_components "${COPILOT_HOME}"
  mkdir -p -- "${COPILOT_HOME}"
}

is_managed_item() {
  local candidate="$1"
  local item

  for item in "${MANAGED_DIRECTORIES[@]}" "${MANAGED_FILES[@]}"; do
    if [[ "${candidate}" == "${item}" ]]; then
      return 0
    fi
  done
  return 1
}

validate_replacement_target() {
  local target="$1"
  local item="$2"
  local expected_target="${COPILOT_HOME}/${item}"

  if ! is_managed_item "${item}"; then
    echo "Refusing to replace unmanaged item: ${item}" >&2
    exit 1
  fi

  if [[ "${target}" != "${expected_target}" ]]; then
    echo "Refusing to replace unexpected target path: ${target}" >&2
    exit 1
  fi

  reject_symlink_components "$(dirname "${target}")"
}

link_item() {
  local source="$1"
  local target="$2"
  local item="$3"

  if [[ ! -e "${target}" && ! -L "${target}" ]]; then
    ln -s -- "${source}" "${target}"
    echo "Linked ${target} -> ${source}"
    return
  fi

  if [[ -L "${target}" ]]; then
    local current_target
    current_target="$(readlink -- "${target}")"
    if [[ "${current_target}" == "${source}" ]]; then
      echo "Already linked ${target} -> ${source}"
      return
    fi
    if [[ "${FORCE}" != true ]]; then
      echo "Conflicting symlink at ${target}: ${current_target}" >&2
      echo "Use --force to replace it." >&2
      exit 1
    fi
    validate_replacement_target "${target}" "${item}"
    rm -- "${target}"
    ln -s -- "${source}" "${target}"
    echo "Replaced symlink ${target} -> ${source}"
    return
  fi

  if [[ "${FORCE}" != true ]]; then
    echo "Conflicting path exists at ${target}" >&2
    echo "Use --force to replace it." >&2
    exit 1
  fi

  validate_replacement_target "${target}" "${item}"
  rm -rf -- "${target}"
  ln -s -- "${source}" "${target}"
  echo "Replaced path ${target} -> ${source}"
}

install_managed_items() {
  local item

  for item in "${MANAGED_DIRECTORIES[@]}" "${MANAGED_FILES[@]}"; do
    link_item "${COPILOT_SOURCE}/${item}" "${COPILOT_HOME}/${item}" "${item}"
  done
}

main() {
  parse_arguments "$@"
  validate_source_tree
  prepare_copilot_home
  install_managed_items

  echo "Linked global Copilot customisations under ${COPILOT_HOME}"
}

main "$@"
