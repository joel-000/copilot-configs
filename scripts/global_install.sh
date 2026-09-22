#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_SOURCE="${SOURCE_ROOT}/copilot"
MANAGED_DIRECTORIES=(instructions agents skills)
MANAGED_FILES=(copilot-instructions.md)
PACK_MARKER="<!-- copilot-config-pack: joel-000/copilot-configs -->"

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

canonicalize_link_target() {
  local link_path="$1"
  local link_target
  link_target="$(readlink -- "${link_path}")"

  if [[ "${link_target}" == /* ]]; then
    canonicalize_path "${link_target}"
  else
    canonicalize_path "$(dirname "${link_path}")/${link_target}"
  fi
}

copilot_source_root_from_link_target() {
  local target="$1"
  local managed_basename="$2"

  if [[ "$(basename -- "${target}")" != "${managed_basename}" ]]; then
    return 1
  fi

  dirname -- "${target}"
}

copilot_root_from_managed_item_link() {
  local item="$1"
  local expected_basename
  local link_path="${COPILOT_HOME}/${item}"
  local target

  if [[ ! -L "${link_path}" ]]; then
    return 1
  fi

  case "${item}" in
    agents|instructions|skills)
      expected_basename="${item}"
      ;;
    copilot-instructions.md)
      expected_basename="copilot-instructions.md"
      ;;
    *)
      return 1
      ;;
  esac

  target="$(readlink -- "${link_path}" 2>/dev/null || true)"
  if [[ "${target}" == /* ]] && [[ "$(basename -- "${target}")" == "${expected_basename}" ]]; then
    copilot_source_root_from_link_target "${target}" "${expected_basename}"
    return 0
  fi

  if target="$(canonicalize_link_target "${link_path}" 2>/dev/null)" && [[ "$(basename -- "${target}")" == "${expected_basename}" ]]; then
    copilot_source_root_from_link_target "${target}" "${expected_basename}"
    return 0
  fi

  return 1
}

is_valid_copilot_source_root() {
  local root="$1"
  local item

  if [[ ! -d "${root}" ]]; then
    return 1
  fi

  for item in "${MANAGED_DIRECTORIES[@]}"; do
    if [[ ! -d "${root}/${item}" ]]; then
      return 1
    fi
  done

  for item in "${MANAGED_FILES[@]}"; do
    if [[ ! -f "${root}/${item}" ]]; then
      return 1
    fi
  done

  return 0
}

has_pack_marker() {
  local root="$1"
  local marker_file="${root}/copilot-instructions.md"

  [[ -f "${marker_file}" ]] && grep -Fq "${PACK_MARKER}" "${marker_file}"
}

array_contains() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done

  return 1
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

  if ! has_pack_marker "${COPILOT_SOURCE}"; then
    echo "Expected pack marker not found in ${COPILOT_SOURCE}/copilot-instructions.md" >&2
    exit 1
  fi
}

cleanup_legacy_prompt_link() {
  local candidate_source_root
  local candidate_target
  local item
  local legacy_link_target
  local legacy_link_canonical
  local legacy_link="${COPILOT_HOME}/prompts"
  local -a legacy_source_roots=("${COPILOT_SOURCE}")

  for item in "${MANAGED_DIRECTORIES[@]}" "${MANAGED_FILES[@]}"; do
    if candidate_source_root="$(copilot_root_from_managed_item_link "${item}" 2>/dev/null)" && is_valid_copilot_source_root "${candidate_source_root}" && has_pack_marker "${candidate_source_root}"; then
      if ! array_contains "${candidate_source_root}" "${legacy_source_roots[@]}"; then
        legacy_source_roots+=("${candidate_source_root}")
      fi
    fi
  done

  if [[ -L "${legacy_link}" ]]; then
    legacy_link_target="$(readlink -- "${legacy_link}" 2>/dev/null || true)"
    legacy_link_canonical="$(canonicalize_link_target "${legacy_link}" 2>/dev/null || true)"

    for candidate_source_root in "${legacy_source_roots[@]}"; do
      candidate_target="${candidate_source_root}/prompts"
      if [[ "${legacy_link_target}" == "${candidate_target}" ]] || [[ -n "${legacy_link_canonical}" && "${legacy_link_canonical}" == "$(canonicalize_path "${candidate_target}")" ]]; then
        # Re-check the entry immediately before removal; never follow the link.
        if [[ -L "${legacy_link}" ]]; then
          rm -- "${legacy_link}"
          echo "Removed legacy pack-owned prompt symlink ${legacy_link}"
        fi
        break
      fi
    done
  fi
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
  cleanup_legacy_prompt_link
  install_managed_items

  echo "Linked global Copilot customisations under ${COPILOT_HOME}"
}

main "$@"
