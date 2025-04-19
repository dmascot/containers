#!/bin/bash
set -euo pipefail

# Generate a combined version from Alpine and ASDF releases
_generate_build_version() {
  local alpine_version="$1"
  local asdf_version_tag="$2"

  local alpine_major alpine_minor alpine_patch
  local asdf_major asdf_minor asdf_patch

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
  local patch=$((alpine_patch + asdf_patch))

  echo "${major}.${minor}.${patch}"
}

# Returns BUILD_VERSION and BUILD_ARGS for the top-level build script
build_image_data() {
  local context_path="$1"
  local alpine_repo="library/alpine"
  local github_repo="asdf-vm/asdf"

  local alpine_release="${ALPINE_VERSION_OVERRIDE:-$(fetch_latest_container_release_tag "$alpine_repo")}"
  debug "Alpine release: $alpine_release"

  local asdf_release="${ASDF_VERSION_OVERRIDE:-$(fetch_latest_github_release_tag "$github_repo")}"
  debug "ASDF release: $asdf_release"

  local build_version
  build_version=$(_generate_build_version "$alpine_release" "$asdf_release")
  local release_tag="asdf:${build_version}"

  local build_args
  build_args="--build-arg ALPINE_VERSION=${alpine_release} --build-arg ASDF_VERSION=${asdf_release}"

  jq -n \
    --arg version "$build_version" \
    --arg args "$build_args" \
    '{BUILD_VERSION: $version, BUILD_ARGS: $args}'
}