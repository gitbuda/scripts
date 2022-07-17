#!/bin/bash -e

# TODO(gitbuda): Add the ability to pick one package.
# TODO(gitbuda): Add the ability to force reinstallation of a package.
# TODO(gitbuda): Add the ability to isolate heavy packages like Conda and Cuda.
# TODO(gitbuda): Add e.g. https://github.com/leehblue/texpander

DEPS=(
    htop tmux vim tree curl git libssl-dev tig dialog silversearcher-ag
    # https://wiki.archlinux.org/title/SSH_keys -> a very nice read about SSH keys.
    # https://unix.stackexchange.com/questions/90853/how-can-i-run-ssh-add-automatically-without-a-password-prompt
    # ssh-ident seems very interesting for the server side use-case.
    openssh-server keychain gnupg-agent custom-ssh-ident
    python-is-python3 # REQUIRED_BY: ssh-ident
    python3-dbg
    ansible
    custom-neovim custom-nvchad
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
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:gitbuda/NvChad.git "/home/$SUDO_USER/.config/nvim"
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/nvim"
        fi
        if [ ! -L "/home/$SUDO_USER/.config/nvim/lua/custom" ]; then
          ln -s "/home/$SUDO_USER/scripts/nvchad" "/home/$SUDO_USER/.config/nvim/lua/custom"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-ssh-ident ]; then
        ssh_ident_folder="/home/$SUDO_USER/.local/ssh-ident"
        if [ ! -d "$ssh_ident_folder" ]; then
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:ccontavalli/ssh-ident.git "$ssh_ident_folder"
            chown -R "$SUDO_USER:$SUDO_USER" "$ssh_ident_folder"
            cd "$ssh_ident_folder"
            ln -s ssh-ident ssh
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvm ]; then
        if [ ! -d "/home/$SUDO_USER/.nvm" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | sudo -H -u "$SUDO_USER" bash
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

    echo "$pkg is installed." && continue
done

chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config"
chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.cache"
