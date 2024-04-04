#!/bin/bash -e

# TODO: xelatex https://gist.github.com/peterhurford/75957ba9335e755013b87254ec85fab1
#
# TODO: python3 -m pip install --user ansible
# TODO: PATH=$PATH:/Users/buda/Library/Python10/bin
#
# TODO: https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh dir
#       https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
# TODO: Install fish -> https://gist.github.com/idleberg/9c7aaa3abedc58694df5
#       fish_config command + the whole ~/.config/fish/ folder
#
# TODO:
#     brew install mkdocs
#
# TODO:
#     brew install sphinx-doc
#     brew link sphinx-doc --force # https://stackoverflow.com/questions/36137496/os-x-install-of-sphinx-the-sphinx-build-and-sphinx-quickstart-not-found
#     pip3 install m2r

RM_DEPS=(
    # rm_neovim
    # rm_nvchad
)

DEPS=(
    wget git htop tmux
    fish
    shellcheck
    custom-xcode
    clang-format
    ffmpeg
    pdftk-java
    gnuplot
    pandoc basictex
    # Valgrind doesn't work on Apple Silicon yet (2023-01-28).
    # valgrind
    qcachegrind
    # There is some issue here the .prof file is generated but almost empty.
    # pprof loads 0 nodes.
    gperftools
    virtualenv
    minio/stable/minio
    node
    custom-rust
    custom-nvim
    custom-nvchad
    custom-fonts
    cargo-flamegraph
)

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

function rm_neovim {
    echo "Removing neovim"
    rm -rf $script_dir/neovim
}
function rm_nvchad {
    echo "Removing nvchad"
    rm -rf $1/.config/nvim
    rm -rf $1/.local/share/nvim
    rm -rf $1/.cache/nvim
}

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

LOCAL_DOTFILES="zshrc zshenv tmux.conf"
for f in ${LOCAL_DOTFILES}; do
    rm -rf "/Users/$USER/.$f"
    ln -s "${script_dir}/$f" "/Users/$USER/.$f"
done

for rm_pkg in "${RM_DEPS[@]}"; do
    "$rm_pkg" "$HOME"
done

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-xcode ]; then
        continue # TODO: Check xcode-select -p https://stackoverflow.com/questions/21272479/how-can-i-find-out-if-i-have-xcode-commandline-tools-installed
        xcode-select --install
        echo "xcode installed." && continue
    fi

    if [ "$pkg" == custom-nvim ]; then
        if ! bin_installed "$script_dir/neovim/build/bin/nvim"; then
            cd "$script_dir"
            git clone https://github.com/neovim/neovim
            cd neovim
            git checkout v0.9.5
            make CMAKE_BUILD_TYPE=Release -j4
            sudo make install
        fi
        echo "$pkg is installed." && continue
    fi
    if [ "$pkg" == custom-nvchad ]; then
        NVIM_CONF_DIR="/Users/$USER/.config/nvim"
        if [ ! -L "$NVIM_CONF_DIR" ]; then
            ln -s "$script_dir/../../nvchad-v2.5" "$NVIM_CONF_DIR"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-fonts ]; then
        cd "$script_dir"
        install_font "https://dl.dafont.com/dl/?f=roboto" "Roboto.zip"
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-rust ]; then
      if ! bin_installed "$HOME/.cargo/bin/cargo"; then
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      fi
      echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == cargo-flamegraph ]; then
      cargo install flamegraph
      echo "$pkg is installed." && continue
    fi

    if ! brew_installed "$pkg"; then
        brew install "$pkg"
    fi
    echo "$pkg is installed." && continue
done
