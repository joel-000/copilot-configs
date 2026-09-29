#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_SOURCE="${SOURCE_ROOT}/copilot"
LEGACY_REPO_ARTIFACTS=(
  "prompts/add-fastapi-endpoint.prompt.md"
  "prompts/improve-docker-setup.prompt.md"
  "prompts/plan-approved-slice.prompt.md"
  "prompts/prepare-pr.prompt.md"
  "prompts/review-terraform-plan.prompt.md"
  "instructions/prompt.instructions.md"
)
LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_add_fastapi_endpoint_prompt_md="6a92fcfef421793f09851ff1a9b5b027315deaadc011577d375782c709944532"
LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_improve_docker_setup_prompt_md="945f5a0e4d1f196b52fd68f02a8380f97ce450e8b0c1d74835e5f34d692b31b3"
LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_plan_approved_slice_prompt_md="ee74c3123a064767831fc6afb1269174c0c9b491e88e9542449061047edd94f2"
LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_prepare_pr_prompt_md="db1d65293c7fd25ba107c18dbae4962aa9c45ae6086b62b20ed659a8fd516bec"
LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_review_terraform_plan_prompt_md="7af159aaa67fa2195c02c0ca67ca11e34c1f5d5b6ad8bb5f74308fb880a7d8d0"
LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_prompt_instructions_md="2516ce4be48906f49de0c41a917b6f124abcee4920f47dcd537140cc91b0b09c"

usage() {
  cat <<'EOF'
Usage: scripts/repo_install.sh [--prune --confirm-prune] [TARGET]

Install the Copilot configuration pack into TARGET.

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

path_has_symlink_component() {
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
      return 0
    fi
  done

  return 1
}

legacy_repo_artifact_object_id() {
  case "$1" in
    prompts/add-fastapi-endpoint.prompt.md)
      printf '%s\n' "${LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_add_fastapi_endpoint_prompt_md}"
      ;;
    prompts/improve-docker-setup.prompt.md)
      printf '%s\n' "${LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_improve_docker_setup_prompt_md}"
      ;;
    prompts/plan-approved-slice.prompt.md)
      printf '%s\n' "${LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_plan_approved_slice_prompt_md}"
      ;;
    prompts/prepare-pr.prompt.md)
      printf '%s\n' "${LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_prepare_pr_prompt_md}"
      ;;
    prompts/review-terraform-plan.prompt.md)
      printf '%s\n' "${LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_review_terraform_plan_prompt_md}"
      ;;
    instructions/prompt.instructions.md)
      printf '%s\n' "${LEGACY_REPO_ARTIFACT_NORMALIZED_SHA256_prompt_instructions_md}"
      ;;
    *)
      return 1
      ;;
  esac
}

is_pack_owned_legacy_repo_artifact() {
  local relative_path="$1"
  local artifact_path="$2"
  local expected_object_id
  local artifact_sha

  expected_object_id="$(legacy_repo_artifact_object_id "${relative_path}")" || return 1
  artifact_sha="$(python -c 'import hashlib, sys; print(hashlib.sha256(open(sys.argv[1], "rb").read().replace(b"\r\n", b"\n")).hexdigest())' "${artifact_path}")"
  [[ "${artifact_sha}" == "${expected_object_id}" ]]
}

cleanup_legacy_repo_artifacts() {
  local relative_path
  local artifact_path

  for relative_path in "${LEGACY_REPO_ARTIFACTS[@]}"; do
    artifact_path="${TARGET_GITHUB_CANONICAL}/${relative_path}"
    if [[ ! -e "${artifact_path}" && ! -L "${artifact_path}" ]]; then
      continue
    fi
    if path_has_symlink_component "${artifact_path}"; then
      echo "Skipped legacy artifact cleanup for symlinked path: ${artifact_path}" >&2
      continue
    fi
    if is_pack_owned_legacy_repo_artifact "${relative_path}" "${artifact_path}"; then
      rm -f -- "${artifact_path}"
    fi
  done

  if ! path_has_symlink_component "${TARGET_GITHUB_CANONICAL}/prompts"; then
    rmdir --ignore-fail-on-non-empty -- "${TARGET_GITHUB_CANONICAL}/prompts" 2>/dev/null || true
  fi
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

if [[ ! -d "${COPILOT_SOURCE}" ]]; then
  echo "Expected source directory not found: ${COPILOT_SOURCE}" >&2
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

if [[ ! -d "${COPILOT_SOURCE}" || ! -d "${TARGET_GITHUB_CANONICAL}" ]]; then
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
  "${COPILOT_SOURCE}/" \
  "${TARGET_GITHUB_CANONICAL}/"

cleanup_legacy_repo_artifacts

MODE="merged safely"
if [[ "${PRUNE}" == true ]]; then
  MODE="mirrored with prune"
fi

echo "Installed Copilot customisations into ${TARGET_GITHUB_CANONICAL} (${MODE})"
