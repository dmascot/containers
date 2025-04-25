#!/usr/bin/env bash
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

    command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed"; exit 1; }

    # Clean up the tarball even if the script exits early
    trap 'rm -f "$asdf_bin_file"' EXIT

    wget "$url" 
    tar -xf "$asdf_bin_file" -C "$ASDF_BIN_DIR"
    rm "$asdf_bin_file"

    asdf completion bash > /etc/profile.d/asdf_completion.sh

    #Set ASDF Binary paths
    echo 'export ASDF_DIR="$HOME/.asdf"' >> /etc/profile.d/asdf_path.sh 
    echo 'export PATH="$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH"' >> /etc/profile.d/asdf_path.sh 

    cat <<'EOF' | tee /etc/bash.bashrc > /dev/null
#!/usr/bin/env bash
# Load profile.d scripts
for f in /etc/profile.d/*.sh; do
    [ -r "$f" ] && . "$f"
done
EOF

    grep -qxF '[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc' "${HOME}/.bashrc" || echo '[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc' >> "${HOME}/.bashrc"
}

asdf_install() {
    local tool_versions_file="$HOME/.tool-versions"

    if ! command -v asdf >/dev/null 2>&1; then
        echo "asdf not installed, please install it first"
        exit 1
    fi

    if -f tool_versions_file="$HOME/.tool-versions"; then 
        ORIGINAL_IFS="$IFS"

        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip empty lines or comments
            [[ -z "$line" || "$line" == \#* ]] && continue

            plugin=$(awk '{print $1}' <<< "$line")
            version=$(awk '{print $2}' <<< "$line")

            echo "Ensuring plugin '$plugin' is installed..."
            if ! asdf plugin list | grep -q "^${plugin}$"; then
                echo "Installing plugin: $plugin"
                asdf plugin add "$plugin"
            fi

            echo "Installing $plugin@$version"
            asdf install "$plugin" "$version"
        done < "$tool_versions_file"

        IFS="$ORIGINAL_IFS"
    else
        echo "you need to have $HOME/.tool-versions file in place to use this command";
    fi 
}

verify_asdf(){
    local version=$(asdf version)
    echo "ASDF Version: $version"
}
