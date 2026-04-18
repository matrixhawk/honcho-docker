#!/usr/bin/env bash

set -euo pipefail

upstream_repo="${UPSTREAM_REPO:?UPSTREAM_REPO is required}"
image_name="${IMAGE_NAME:?IMAGE_NAME is required}"
requested_tag="${1:-${INPUT_TAG:-}}"

mapfile -t tags < <(
  git ls-remote --tags --refs "${upstream_repo}" \
    | awk '{print $2}' \
    | sed 's#^refs/tags/##' \
    | sort -u -V
)

if [[ "${#tags[@]}" -eq 0 ]]; then
  echo "No upstream tags found in ${upstream_repo}" >&2
  exit 1
fi

latest_tag="${tags[${#tags[@]}-1]}"

if [[ -n "${requested_tag}" ]]; then
  if ! printf '%s\n' "${tags[@]}" | grep -Fxq "${requested_tag}"; then
    echo "Requested tag ${requested_tag} does not exist upstream" >&2
    exit 1
  fi
  target_tag="${requested_tag}"
else
  target_tag="${latest_tag}"
fi

publish_latest=false
if [[ "${target_tag}" == "${latest_tag}" && "${target_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  publish_latest=true
fi

docker_tags="${image_name}:${target_tag}"
if [[ "${publish_latest}" == "true" ]]; then
  docker_tags+=$'\n'"${image_name}:latest"
fi

git_context="${upstream_repo}#${target_tag}"

emit_output() {
  local key="$1"
  local value="$2"

  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "${key}<<EOF"
      printf '%s\n' "${value}"
      echo "EOF"
    } >> "${GITHUB_OUTPUT}"
  else
    printf '%s=%s\n' "${key}" "${value}"
  fi
}

emit_output "tag" "${target_tag}"
emit_output "latest_tag" "${latest_tag}"
emit_output "publish_latest" "${publish_latest}"
emit_output "docker_tags" "${docker_tags}"
emit_output "git_context" "${git_context}"
