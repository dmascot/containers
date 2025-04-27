# Containers

**Alpine- and ASDF-Powered Development Containers**  
Lightweight Docker images built on Alpine Linux and ASDF, designed to streamline tool installation, multi-architecture support (`amd64`/`arm64`), and consistent development environments.

- Build Docker images for different tools and environments (e.g., `asdf`) across both `amd64` and `arm64` platforms.
- Automatically tag versioned builds based on upstream dependencies (e.g., Alpine, ASDF versions).
- Push to Docker Hub (`docker.io/dmascot/<image>:<version>` and `:latest`).
- Track build metadata to prevent redundant builds.
- Cleanly separate CI and local build workflows.

# 📂 Directory Structure
```bash
.
├── build.sh                      # Central logic for all image builds used by both CI and local build
├── local_build.sh                # Local builder script;builds one image locally
├── common.sh                     # Shared shell functions and helpers
├── build-info.json               # Metadata for last-known build versions (CI)
├── local-build-info.json         # Metadata for last-known local builds (not committed to the repository)

├── images/
│   └── asdf/
│   │   ├── Dockerfile
│   │   ├── build.sh                # Image-specific version logic
│   │   └── asdf_helper.sh          # Script added to container image
│   └── <image_name>/
│       ├── Dockerfile
│       ├── build.sh                # Image-specific version logic
│       └── <image specific script> # Script added to container image

```
## 🛠 Usage

### ✅ Local Build

```bash
./local_build.sh <image-name> [--dry-run]
```

To enable debug printing:

```bash
DEBUG="true" ./local_build.sh <image-name> [--dry-run]
```

### ✅ CI Builds

GitHub Actions uses `.github/workflows/_build-and-push.yml` to build and push multi-arch images only if versions have changed. It uses `build-info.json` as metadata to track this.

## ➕ Adding a New Image
  1. Create a new folder under images/, e.g. images/mytool/
  2. Add a Dockerfile with your image definition
  3. Create a build.sh file with the following structure.Ensure the function name is the same (i.e. build_image_data) and that its output is a JSON string like this:
  ```json 
  { 
    "IMAGE_DATA": {
      "BUILD_VERSION": "v1.0",
      "TOOL_VERSION": "v0.1"
    },
    "BUILD_ARGS": ["KEY1=VAL1","KEY2=VAL2",..]
  }
```

Below is a simple example script:

```bash
    #!/bin/bash
    set -euo pipefail

    build_image_data() {
    local context_path="$1"

    # Example version detection
    local BUILD_VERSION="1.0.0"
    local TOOL_VERSION="0.0.2"

    jq -n \
        --arg build_version "$BUILD_VERSION" \
        --arg tool_version "$TOOL_VERSION" \
        --argjson build_args "$(jq -n --arg ar1 "TOOL_VERSION=$tool_version" '[ $ar1 ]')" \
        '{
          IMAGE_DATA: {
            BUILD_VERSION: $build_version,
            TOOL_VERSION: $tool_version,
          },
          BUILD_ARGS: $build_args
        }' 
```
  1. Ensure BUILD_VERSION is present in the file, if not you will see an error.
  2. BUILD_ARGS are optional and are limited to --build-arg only. They cannot be used to pass other Docker build options
   
## 🤝 Contributing

Pull requests are welcome! Please follow the pattern used in images/asdf, and test your changes locally before submitting.

## 📦 Docker Hub

Images are published to:
https://hub.docker.com/u/dmascot

## Improvements
- Run a vulnerability scan
- Support force build (i.e. rebuild even if `build-info.json` marks it as built)
- Manage additional Docker build options if needed (i.e., beyond --build-arg)