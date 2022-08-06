#!/bin/bash -e

# TODO(gitbuda): Add the ability to pick one package.
# TODO(gitbuda): Add the ability to force reinstallation of a package.
# TODO(gitbuda): Add the ability to isolate heavy packages like Conda and Cuda.
# TODO(gitbuda): Add e.g. https://github.com/leehblue/texpander

DEPS=(
    htop tmux vim tree curl git libssl-dev tig dialog silversearcher-ag
    openssh-server keychain
    # screenkey -> PROBLEM: Seems not to be working properly on 22.04.
    python3-gi gir1.2-gtk-3.0 python3-cairo python3-setuptools python3-distutils-extra fonts-font-awesome slop gir1.2-appindicator3-0.1 screenkey 
    gnome-shell-extensions # Super + extensions -> opens the manager
    # draw-on-you-screen
    # https://ubuntuhandbook.org/index.php/2021/02/start-drawing-on-screen-ubuntu-2004
    # https://extensions.gnome.org/extension/1683/draw-on-you-screen/ -> For 22.04
    # PROBLEM: After initial drawing, Ctrl + B in tmux does NOT work anymore -> extension has to be disabled
    ansible
    custom-nvm
    custom-neovim
    custom-nvchad
    custom-rust
    custom-fzf
)

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
fi
if [ "$SUDO_USER" == "" ]; then
    echo "Please run as sudo."
fi
HOME=/home/$SUDO_USER

DOTFILES=""
for f in ${DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    sudo -H -u "$SUDO_USER" bash -c "ln -s ${script_dir}/$f /home/$SUDO_USER/.$f"
done

function install_font {
    download_link=$1
    local_file_name=$2
    if [ ! -f "$local_file_name" ]; then
        wget "$download_link" -O "$local_file_name"
        mkdir -p "/home/$SUDO_USER/.fonts"
        unzip "$local_file_name" -d "/home/$SUDO_USER/.fonts"
        fc-cache -fv
    fi
}

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-rust ]; then
        if ! bin_installed "/home/$SUDO_USER/.cargo/bin/rustup"; then
            sudo -H -u "$SUDO_USER" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-neovim ]; then
	if ! bin_installed "$script_dir/neovim/build/bin/nvim"; then
            cd "$script_dir"
            git clone https://github.com/neovim/neovim
            chown -R "$SUDO_USER:$SUDO_USER" "$script_dir/neovim"
            cd neovim
            git checkout v0.7.2 && make CMAKE_BUILD_TYPE=Release -j4 && make install
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvchad ]; then
        if [ ! -d "/home/$SUDO_USER/.config/nvim" ]; then
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:NvChad/NvChad.git "/home/$SUDO_USER/.config/nvim"
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/nvim"
        fi
        if [ ! -L "/home/$SUDO_USER/.config/nvim/lua/custom" ]; then
          ln -s "/home/$SUDO_USER/scripts/nvchad" "/home/$SUDO_USER/.config/nvim/lua/custom"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvm ]; then
        if [ ! -d "/home/$SUDO_USER/.nvm" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | sudo -H -u "$SUDO_USER" bash
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-fzf ]; then
        if [ ! -d "/home/$SUDO_USER/.fzf" ]; then
            git clone --depth 1 https://github.com/junegunn/fzf.git /home/$SUDO_USER/.fzf
            /home/$SUDO_USER/.fzf/install
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.fzf"
        fi
        echo "$pkg is installed." && continue
    fi

    echo "$pkg is installed." && continue
done

chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config"
chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.cache"
