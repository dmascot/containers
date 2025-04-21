#!/bin/bash
set -euo pipefail

export OVER_RIDE_META_DATA_FILE="local-build-info.json"

source "$(dirname "$0")/common.sh"

run_local_build(){

    local image=${1:-}
    local dry_run=false
    local image_dir="images/$image"

    [[ -z "$image" ]] && usage
    [[ "${2:-}" == "--dry-run" ]] && dry_run=true

    # Load shared build logic
    source "$(dirname "$0")/build.sh"
    local build_data
    build_data=$(gen_build_data "$image" "$dry_run" --output)

    IMAGE_DATA=$(jq -r .IMAGE_DATA <<< "$build_data")
    
    BUILD_VERSION=$(jq -r .IMAGE_DATA.BUILD_VERSION <<< "$build_data")
    SHOULD_BUILD=$(jq -r .SHOULD_BUILD <<< "$build_data")
    
    BUILD_ARGS=$(jq -r '.BUILD_ARGS // [] | map("--build-arg " + .) | join(" ")' <<< "$build_data")

    if [[ "$SHOULD_BUILD" == true ]]; then
        info "🛠 Rebuilding image: $image (version: $BUILD_VERSION)"
        info "Running: docker build $BUILD_ARGS -t $image:$BUILD_VERSION $image_dir"
        if [[ "$dry_run" == false ]]; then
            docker build $BUILD_ARGS -t "$image:$BUILD_VERSION" "$image_dir"
            docker tag "$image:$BUILD_VERSION" "$image:latest"
            write_metadata "$image" "$IMAGE_DATA"
            info "Build complete: $image:$BUILD_VERSION and :latest"
        else
            info "[DRY RUN] Would build: $image:$BUILD_VERSION"
        fi
    else
        info "No changes detected for $image (version: $BUILD_VERSION), skipping build."
    fi
}

run_local_build "$@"