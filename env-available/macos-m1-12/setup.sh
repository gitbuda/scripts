#!/bin/bash -e

# TODO: xelatex https://gist.github.com/peterhurford/75957ba9335e755013b87254ec85fab1

DEPS=(
    git htop tmux nvim
    custom-xcode
    ffmpeg
    gnuplot
    pandoc basictex
    qcachegrind
    virtualenv
    custom-nvchad
    custom-fonts
)

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

function install_font {
    download_link=$1
    local_file_name=$2
    if [ ! -f "$local_file_name" ]; then
        wget "$download_link" -O "$local_file_name"
        mkdir -p "/Users/$USER/Library/Fonts"
        unzip "$local_file_name" -d "/Users/$USER/Library/Fonts"
    fi
}

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

    if [ "$pkg" == custom-fonts ]; then
        cd "$script_dir"
        install_font "https://dl.dafont.com/dl/?f=roboto" "Roboto.zip"
        echo "$pkg is installed." && continue
    fi

    if ! brew_installed "$pkg"; then
        brew install "$pkg"
    fi
    echo "$pkg is installed." && continue
done
