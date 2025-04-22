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

    ASDF_BIN_DIR="/usr/bin"

    
    asdf_bin_file="asdf-${version}-${os}-${arch}.tar.gz"
    url="https://github.com/asdf-vm/asdf/releases/download/${version}/$asdf_bin_file"

    wget "$url" 
    tar -xf $asdf_bin_file -C "$ASDF_BIN_DIR"
    rm $asdf_bin_file

    ASDF_PROFILE='/etc/profile.d/asdf.sh'
    ASDF_COMPLETION='/etc/profile.d/asdf_completion.sh'
    touch $ASDF_PROFILE
    echo '# ASDF PATH'
    echo 'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"' >> $ASDF_PROFILE
    echo '# ASDF completion' >> $ASDF_COMPLETION
    asdf completion bash >> $ASDF_COMPLETION
    echo '. /etc/profile' >> "$HOME/.profile" 
}

verify_asdf(){
    source /etc/profile
    local version=$(asdf version)
    echo "ASDF Version: $version"
}
