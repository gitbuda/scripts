#!/bin/bash -e

DEPS=(
    git htop tmux nvim
    custom-nvchad
)

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-nvchad ]; then
	NVCHAD_DIR="/Users/$USER/.config/nvim"
        if [ ! -d "$NVCHAD_DIR" ]; then
            git clone https://github.com/NvChad/NvChad $NVCHAD_DIR --depth 1
        fi
        echo "$pkg is installed." && continue
    fi

    if ! brew_installed "$pkg"; then
        brew install "$pkg"
    fi
    echo "$pkg is installed." && continue
done
