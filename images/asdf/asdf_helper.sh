#!/bin/bash
set -euo pipefail

install_asdf(){
    local version="$1"
    if [ -z "$version" ]; then
        echo "ASDF version not provided"
        exit 1
    fi

    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *) echo "Unsupported architecture"; exit 1 ;;
    esac

    local os
    case "$(uname -s)" in
        Linux) os="linux" ;;
        Darwin) os="darwin" ;;
        *) echo "Unsupported OS"; exit 1 ;;
    esac

    echo "Installing asdf ${version} for ${os}-${arch}"

    ASDF_HOME="/usr/local/share/asdf"
    ASDF_BIN_DIR="$ASDF_HOME/bin"
    ASDF_DATA_DIR="$ASDF_HOME/data"

    mkdir -p "$ASDF_BIN_DIR"
    mkdir -p "$ASDF_DATA_DIR"

    asdf_bin_file="asdf-${version}-${os}-${arch}.tar.gz"
    url="https://github.com/asdf-vm/asdf/releases/download/${version}/$asdf_bin_file"

    command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed"; exit 1; }

    # Clean up the tarball even if the script exits early
    trap 'rm -f "$asdf_bin_file"' EXIT

    wget "$url" 
    tar -xf "$asdf_bin_file" -C "$ASDF_BIN_DIR"
    rm "$asdf_bin_file"

    profile_file="/etc/profile.d/asdf.sh"
    touch "$profile_file"
    echo 'export ASDF_HOME="/usr/local/share/asdf"'  >> "$profile_file"
    echo 'export ASDF_BIN_DIR="$ASDF_HOME/bin"' >> "$profile_file"
    echo 'export ASDF_DATA_DIR="$ASDF_HOME/data"' >> "$profile_file"
    echo 'export PATH="$ASDF_BIN_DIR:$ASDF_DATA_DIR/shims:$PATH"' >> "$profile_file"

    cat <<'EOF' | tee /etc/bash.bashrc > /dev/null
#!/bin/sh
# Load profile.d scripts
for f in /etc/profile.d/*.sh; do
    [ -r "$f" ] && . "$f"
done
EOF

    grep -qxF '[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc' "${HOME}/.bashrc" || echo '[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc' >> "${HOME}/.bashrc"
}

verify_asdf(){
    source /etc/profile
    local version=$(asdf version)
    echo "ASDF Version: $version"
}
