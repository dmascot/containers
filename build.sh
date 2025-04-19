#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

META_DATA_FILE="$SCRIPT_DIR/build-info.json"
source "$SCRIPT_DIR/common.sh"

gen_build_data(){
  local image=${1:-}
  local output_mode="${3:-}"
  local dry_run=${2:-false}

  [[ -z "$image" ]] && usage
  [[ "$output_mode" == "--dry-run" ]] && dry_run=true

  local image_dir="images/$image"
  [[ ! -d "$image_dir" ]] && { echo "Image not found: $image_dir"; exit 1; }

  source "$image_dir/build.sh"

  require_command jq
  require_command curl

  local previous_version
  previous_version=$(read_metadata_version "$image")

  local result
  result="$(build_image_data "$image_dir")"

  if ! jq -e 'has("BUILD_VERSION")' <<< "$result" > /dev/null; then
    error "BUILD_VERSION missing in build_image_data output" >&2
    exit 1
  fi

  if ! jq -e 'has("BUILD_ARGS")' <<< "$result" > /dev/null; then
    result=$(jq '. + {BUILD_ARGS: ""}' <<< "$result")
  fi
  
  BUILD_VERSION=$(jq -r .BUILD_VERSION <<< "$result")
  
  SHOULD_BUILD=false
  if [[ "$previous_version" != "$BUILD_VERSION" ]]; then
    SHOULD_BUILD=true
  fi

  result=$(jq --argjson shouldBuild "$SHOULD_BUILD" '. + {SHOULD_BUILD: $shouldBuild}' <<< "$result")
  
  if [[ "$output_mode" == "--output" ]]; then
    echo "$result"
  fi
}