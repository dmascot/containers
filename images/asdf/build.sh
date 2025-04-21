#!/bin/bash
set -euo pipefail

# Generate a combined version from Alpine and ASDF releases
_generate_build_version() {
  local alpine_version="$1"
  local asdf_version_tag="$2"
  local docker_version="$3"
  local context_path="$4"

  local alpine_major alpine_minor alpine_patch
  local asdf_major asdf_minor asdf_patch
  local docker_major docker_minor docker_patch

  local ORIGINAL_IFS=$IFS

  IFS='.' read -r alpine_major alpine_minor alpine_patch <<< "$alpine_version"
  IFS='.' read -r asdf_major asdf_minor asdf_patch <<< "${asdf_version_tag#v}"

  alpine_major="${alpine_major:-0}"
  alpine_minor="${alpine_minor:-0}"
  alpine_patch="${alpine_patch:-0}"

  asdf_major="${asdf_major:-0}"
  asdf_minor="${asdf_minor:-0}"
  asdf_patch="${asdf_patch:-0}"

  local major=$((alpine_major + asdf_major))
  local minor=$((alpine_minor + asdf_minor))
  local patch

  if [[ "$docker_version" == 0 ]]; then
    patch=$((alpine_patch + asdf_patch + 1))
  else
    IFS='.' read -r docker_major docker_minor docker_patch <<< "$docker_version"
    patch=$((docker_patch + $(compute_patch_bump "$docker_patch" "$context_path")))
  fi

  IFS=$ORIGINAL_IFS

  echo "${major}.${minor}.${patch}"
}

# Returns BUILD_VERSION and BUILD_ARGS for the top-level build script
build_image_data() {
  local context_path="$1"
  local alpine_repo="library/alpine"
  local github_repo="asdf-vm/asdf"
  local docker_repo="dmascot/$(basename $context_path)"

  debug "Building Docker image: $docker_repo"

  local latest_docker_image_release
  latest_docker_image_release=$(fetch_latest_container_release_tag "$docker_repo")
  latest_docker_image_release="${latest_docker_image_release:-0}"

  debug "$docker_repo release: $latest_docker_image_release"

  local alpine_release="${ALPINE_VERSION_OVERRIDE:-$(fetch_latest_container_release_tag "$alpine_repo")}"
  debug "Alpine release: $alpine_release"

  local asdf_release="${ASDF_VERSION_OVERRIDE:-$(fetch_latest_github_release_tag "$github_repo")}"
  debug "ASDF release: $asdf_release"

  local build_version
  build_version=$(_generate_build_version "$alpine_release" "$asdf_release" "$latest_docker_image_release" "$context_path")
  
  debug "Build Version: $build_version"

  jq -n \
    --arg version "$build_version" \
    --arg alpine "ALPINE_VERSION=${alpine_release}" \
    --arg asdf "ASDF_VERSION=${asdf_release}" \
    '{BUILD_VERSION: $version, BUILD_ARGS: [$alpine, $asdf]}'
}