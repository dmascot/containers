#!/bin/bash
set -euo pipefail

# Generate a combined version from Alpine and ASDF releases
_generate_build_version() {
  local alpine_version="$1"
  local asdf_version_tag="$2"
  local pushed_docker_build_version="$3"
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

  ## this means it is a fesh build and there is no version
  if [[ "$pushed_docker_build_version" == 0 ]]; then
    patch=1
  else
    IFS='.' read -r docker_major docker_minor docker_patch <<< "$pushed_docker_build_version"

    local previous_metadata
    previous_metadata=$(jq -r --arg key "$(basename "$context_path")" '.[$key] // empty' "$META_DATA_FILE" 2>/dev/null || echo "{}")

    local prev_alpine prev_asdf
    prev_alpine=$(jq -r '.ALPINE_VERSION // empty' <<< "$previous_metadata")
    prev_asdf=$(jq -r '.ASDF_VERSION // empty' <<< "$previous_metadata")

   
    if [[ "$alpine_release" != "$prev_alpine" || "$asdf_release" != "$prev_asdf" ]]; then
      patch=1
    else
      #new patch if there is change in the any of script or file with in image directory 
      patch=$((docker_patch + $(compute_patch_bump "$docker_patch" "$context_path")))
    fi 
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

  local pushed_docker_build_version
  pushed_docker_build_version=$(fetch_latest_container_release_tag "$docker_repo")
  pushed_docker_build_version="${pushed_docker_build_version:-0}"

  debug "$docker_repo release: $pushed_docker_build_version"

  local alpine_release="${ALPINE_VERSION_OVERRIDE:-$(fetch_latest_container_release_tag "$alpine_repo")}"
  debug "Alpine release: $alpine_release"

  local asdf_release="${ASDF_VERSION_OVERRIDE:-$(fetch_latest_github_release_tag "$github_repo")}"
  debug "ASDF release: $asdf_release"

  build_version=$(_generate_build_version "$alpine_release" "$asdf_release" "$pushed_docker_build_version" "$context_path")
  
  debug "Build Version: $build_version"

  jq -n \
    --arg build_version "$build_version" \
    --arg alpine_release "$alpine_release" \
    --arg asdf_release "$asdf_release" \
    --argjson build_args "$(jq -n --arg ar1 "ALPINE_VERSION=$alpine_release" --arg ar2 "ASDF_VERSION=$asdf_release" '[ $ar1, $ar2 ]')" \
    '{
      IMAGE_DATA: {
        BUILD_VERSION: $build_version,
        ALPINE_VERSION: $alpine_release,
        ASDF_VERSION: $asdf_release
      },
      BUILD_ARGS: $build_args
    }'
}