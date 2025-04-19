# Containers

This repository is a collection of containers based on apline.Intended to be used as a development tool to enable quick and easy installation of the tools

- Build Docker images for different tools and environments (e.g., `asdf`) across both `amd64` and `arm64` platforms.
- Automatically tag versioned builds based on upstream dependencies (e.g., Alpine, ASDF).
- Push to Docker Hub (`docker.io/dmascot/<image>:<version>` and `:latest`).
- Track build metadata to prevent redundant builds.
- Cleanly separate CI and local build workflows.

# 📂 Directory Structure
```bash
.
├── build.sh                      # Central logic for all image builds used by both CI and local build
├── local_build.sh                # Local builder,builds one image locally
├── common.sh                     # Shared shell functions and helpers
├── build-info.json               # Metadata for last-known build versions (CI)
├── local-build-info.json         # Metadata for last-known local builds,this is not commited to repository
├── images/
│   └── asdf/
│   │   ├── Dockerfile
│   │   ├── build.sh                # Image-specific version logic
│   │   └── asdf_helper.sh          # Script added to container image
│   └── <imange_name>/
│       ├── Dockerfile
│       ├── build.sh                # Image-specific version logic
│       └── <image specific script> # Script added to container image

```
## 🛠 Usage

### ✅ Local Build

```bash
./local_build.sh <image-name> [--dry-run]
```

if you want debug print

```bash
DEBUG="true" ./local_build.sh <image-name> [--dry-run]
```

### ✅ CI Builds

GitHub Actions uses `.github/workflows/_build-and-push.yml` to build and push multi-arch images only if versions have changed. It uses build-info.json as metadata to track this.

## ➕ Adding a New Image
  1. Create a new folder under images/, e.g. images/mytool/
  2. Add a Dockerfile with your image definition.
  3. Create a build.sh file with the following structure. Ensure function name to be same i.e. `build_image_data` and, it ouputs json string as fillows ```json { "BUILD_VERSION": VersionString, "BUILD_ARGS": BuildArgs }```

```bash
    #!/bin/bash
    set -euo pipefail

    build_image_data() {
    local context_path="$1"

    # Example version detection
    local BUILD_VERSION="1.0.0"
    
    #Example docker build args to be added
    local BUILD_ARGS="--build-arg BUILD_VERSION=$BUILD_VERSION"

    jq -n \
        --arg version "$BUILD_VERSION" \
        --arg args "$BUILD_ARGS" \
        '{BUILD_VERSION: $version, BUILD_ARGS: $args}'
    } 
```
  4. Ensure BUILD_VERSION is present in the file, if not you will see an error.
  5. BUILD_ARGS are optional and, it is a string which is not limited to `--build-arg` you can add any other valid `docker build` options here for build time
   
## 🤝 Contributing

PRs welcome! Please follow the pattern used in images/asdf and test your changes locally before submitting.

## 📦 Docker Hub

Images are published to:
https://hub.docker.com/u/dmascot

## Improvements
- run vulnerability scan