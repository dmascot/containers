#!/bin/bash
set -euo pipefail


usage() {
  echo "Usage: $0 <image-name> [--dry-run]"
  exit 1
}

log() {
  echo -e "[$(date +'%F %T')] $*" >&2
}

debug(){
  local YELLOW='\033[0;34m'
  local NC='\033[0m' # No Color
  [[ "${DEBUG:-false}" == "true" ]] && log "${YELLOW}[DEBUG] $*${NC}"
}

info(){
  local GREEN='\033[0;32m'
  local NC='\033[0m' # No Color
  log "${GREEN}[INFO] $*${NC}"
}

error(){
  local RED='\033[0;31m'
  local NC='\033[0m' # No Color
  log "${RED}[ERROR] $*${NC}"
}

require_command() {

  command -v "$1" >/dev/null 2>&1 || {
    error "Required command '$1' not found. Please install it" >&2
    exit 1
  }
  
}

fetch_latest_container_release_tag() {
  local repo="$1"

  local latest_digest
  latest_digest=$(curl -s "https://registry.hub.docker.com/v2/repositories/${repo}/tags/latest" | jq -r '.digest // empty')

  if [[ -z "$latest_digest" ]]; then
    echo "0"
    return
  fi

  local latest_tag
  latest_tag=$(curl -s "https://registry.hub.docker.com/v2/repositories/${repo}/tags?page_size=100" | \
    jq -r --arg digest "$latest_digest" '.results[] | select(.digest == $digest) | select(.name != "latest") | .name' | head -1)

  echo "${latest_tag:-0}"
}

fetch_latest_github_release_tag() {
  local repo="$1"
  curl -s "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name'
}

# Allow main script to define META_DATA_FILE, or default here
META_DATA_FILE="${OVER_RIDE_META_DATA_FILE:-build-info.json}"

ensure_metadata_exists() {
  [[ -f "$META_DATA_FILE" ]] || echo "{}" > "$META_DATA_FILE"
}

write_metadata() {
  local image="$1"
  local image_data="$2"
  ensure_metadata_exists

  local tmp_file
  tmp_file=$(mktemp)
  trap 'rm -f "$tmp_file"' EXIT

  jq --arg key "$image" --argjson val "$image_data" '.[$key] = $val' "$META_DATA_FILE" > "$tmp_file" && mv "$tmp_file" "$META_DATA_FILE"
  trap - EXIT
}

read_metadata_version() {
  local image="$1"
  ensure_metadata_exists
  jq -r --arg key "$image" '.[$key].BUILD_VERSION // empty' "$META_DATA_FILE"
}

compute_patch_bump() {
  local docker_patch="$1"
  local context_path="$2"

  if git diff --quiet origin/main -- "$context_path"; then
    echo 0
  else
    echo 1
  fi
}