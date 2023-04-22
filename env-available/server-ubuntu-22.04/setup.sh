#!/bin/bash -e

RM_DEPS=(
#   rm_neovim rm_nvchad
)
DEPS=(
    htop tmux vim tree curl git tig dialog silversearcher-ag zsh plocate
    custom-fzf
    make cmake libssl-dev pkg-config libtool-bin unzip gettext
    python3-dbg
    openjdk-17-jre
    ansible
    memtester
    heaptrack
    custom-neovim custom-nvchad
    custom-nvm
    custom-rust
)
# TODO(gitbuda): Add e.g. https://github.com/leehblue/texpander

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
        mkdir -p "/home/$SUDO_USER/.fonts"
        unzip "$local_file_name" -d "/home/$SUDO_USER/.fonts"
        fc-cache -fv
    fi
}

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

for rm_pkg in "${RM_DEPS[@]}"; do
    "$rm_pkg" "$HOME"
done

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
            cd neovim
            git checkout v0.8.0
            chown -R "$SUDO_USER:$SUDO_USER" "$script_dir/neovim"
            sudo -H -u "$SUDO_USER" bash -c "make CMAKE_BUILD_TYPE=Release -j4"
            make install
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvchad ]; then
        if [ ! -d "/home/$SUDO_USER/.config/nvim" ]; then
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:NvChad/NvChad.git "/home/$SUDO_USER/.config/nvim" --depth 1
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/nvim"
        fi
        if [ ! -L "/home/$SUDO_USER/.config/nvim/lua/custom" ]; then
            ln -s "/home/$SUDO_USER/scripts/nvchad3" "/home/$SUDO_USER/.config/nvim/lua/custom"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvm ]; then
        if [ ! -d "/home/$SUDO_USER/.nvm" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | sudo -H -u "$SUDO_USER" bash
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-tpm ]; then
        tpm_repo="https://github.com/tmux-plugins/tpm"
        tpm_dir="/home/$SUDO_USER/.tmux/plugins/tpm"
        if [[ ! -d "${tpm_dir}" ]]; then
            git clone "${tpm_repo}" "${tpm_dir}"
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

    if ! deb_installed "$pkg"; then
        apt install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done

chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config"
chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.cache"
if ! grep -qF "$HOME/scripts/util" "$HOME/.bashrc" ; then
    echo "PATH=\$PATH:$HOME/scripts/util" >> "$HOME/.bashrc"
fi
if ! grep -qF "$HOME/scripts/workspace" "$HOME/.bashrc" ; then
    echo "PATH=\$PATH:$HOME/scripts/workspace" >> "$HOME/.bashrc"
fi
if ! grep -qF "$HOME/scripts/git" "$HOME/.bashrc" ; then
    echo "PATH=\$PATH:$HOME/scripts/git" >> "$HOME/.bashrc"
fi
