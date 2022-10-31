#!/bin/bash -e

DEPS=(
    git htop tmux nvim
    custom-xcode
    ffmpeg
    qcachegrind
    virtualenv
    custom-nvchad
)

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

PUBLIC_DOTFILES="gitconfig gitignore"
for f in ${PUBLIC_DOTFILES}; do
    rm -rf "/Users/$USER/.$f"
    ln -s "${script_dir}/../../dotfiles/$f" "/Users/$USER/.$f"
done

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-xcode ]; then
        continue # TODO: Check xcode-select -p https://stackoverflow.com/questions/21272479/how-can-i-find-out-if-i-have-xcode-commandline-tools-installed
        xcode-select --install
        echo "xcode installed." && continue
    fi

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
