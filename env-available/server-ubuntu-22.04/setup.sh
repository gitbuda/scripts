#!/bin/bash -e
script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

RM_DEPS=(
    # rm_neovim
    # rm_nvchad
)
DEPS=(
    htop tmux vim tree curl git tig dialog silversearcher-ag zsh plocate
    custom-fzf
    make cmake cmake-curses-gui libssl-dev pkg-config libtool-bin unzip gettext
    ripgrep
    exuberant-ctags
    python3-dbg python3.10-venv
    openjdk-17-jre
    ansible
    memtester
    heaptrack
    sysstat iotop nvtop
    nvidia-cuda-toolkit custom-cudnn custom-nccl custom-cutensor custom-cusparselt
    custom-nvm
    custom-rust
    custom-neovim custom-nvchad
    # custom-just # https://just.systems/man/en/chapter_4.html -> cargo install just
    # custom-mevi # https://github.com/fasterthanlime/mevi
      # sudo sysctl -w vm.unprivileged_userfaultfd=1
      # cargo install just trunk
    cargo-tree-sitter
)
# TODO(gitbuda): Add e.g. https://github.com/leehblue/texpander

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

PUBLIC_DOTFILES="bash_aliases"
for f in ${PUBLIC_DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    sudo -H -u "$SUDO_USER" bash -c "ln -s ${script_dir}/../../dotfiles/$f /home/$SUDO_USER/.$f"
done

LOCAL_DOTFILES="bashrc tmux.conf"
for f in ${LOCAL_DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    sudo -H -u "$SUDO_USER" bash -c "ln -s ${script_dir}/$f /home/$SUDO_USER/.$f"
done

for rm_pkg in "${RM_DEPS[@]}"; do
    "$rm_pkg" "$HOME"
done

cd "$script_dir"
for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-cudnn ]; then
        installed_install_path="/var/cudnn-local-repo-ubuntu2204-8.8.0.121"
        cudnn_deb_packet="cudnn-local-repo-ubuntu2204-8.8.0.121_1.0-1_amd64.deb"
        cudnn_gpg_path="$installed_install_path/cudnn-local-04B81517-keyring.gpg"
        if [ ! -f "$cudnn_gpg_path" ]; then
          curl -O -J -L "https://developer.download.nvidia.com/compute/redist/cudnn/v8.8.0/local_installers/12.0/$cudnn_deb_packet"
          dpkg -i "$cudnn_deb_packet"
          cp $cudnn_gpg_path /usr/share/keyrings/
        fi
        if ! deb_installed "libcudnn8"; then
          dpkg -i "$installed_install_path/libcudnn8_8.8.0.121-1+cuda12.0_amd64.deb"
          echo "libcudnn installed"
        fi
        if ! deb_installed "libcudnn8-dev"; then
          dpkg -i "$installed_install_path/libcudnn8-dev_8.8.0.121-1+cuda12.0_amd64.deb"
          echo "libcudnn-dev installed"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nccl ]; then
        if [ ! -f "/usr/local/include/nccl.h" ]; then
          rm -rf nccl
          git clone https://github.com/NVIDIA/nccl.git
          cd "$script_dir/nccl"
          # NOTE: CUDA_HOME depends on how cuda is actually installed.
          # NOTE: g++-10 is here because of https://github.com/NVIDIA/nccl/issues/102
          CXX=/usr/bin/g++-10 make -j src.build CUDA_HOME=/usr/lib/nvidia-cuda-toolkit
          make install
          cd "$script_dir"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-cutensor ]; then
        # https://developer.nvidia.com/cutensor-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local
        if ! deb_installed "libcutensor2"; then
          curl -O -J -L https://developer.download.nvidia.com/compute/cutensor/2.0.0/local_installers/cutensor-local-repo-ubuntu2204-2.0.0_1.0-1_amd64.deb
          dpkg -i cutensor-local-repo-ubuntu2204-2.0.0_1.0-1_amd64.deb
          cp /var/cutensor-local-repo-ubuntu2204-2.0.0/cutensor-*-keyring.gpg /usr/share/keyrings/
          apt update
          apt-get -y install libcutensor2 libcutensor-dev libcutensor-doc
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-cusparselt ]; then
        # https://developer.nvidia.com/cusparselt-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local
        if ! deb_installed "libcusparselt0"; then
          curl -O -J -L https://developer.download.nvidia.com/compute/cusparselt/0.5.2/local_installers/cusparselt-local-repo-ubuntu2204-0.5.2_1.0-1_amd64.deb
          dpkg -i cusparselt-local-repo-ubuntu2204-0.5.2_1.0-1_amd64.deb
          cp /var/cusparselt-local-repo-ubuntu2204-0.5.2/cusparselt-*-keyring.gpg /usr/share/keyrings/
          apt-get update
          apt-get -y install libcusparselt0 libcusparselt-dev
        fi
        echo "$pkg is installed." && continue
    fi

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
            git checkout v0.8.3
            chown -R "$SUDO_USER:$SUDO_USER" "$script_dir/neovim"
            sudo -H -u "$SUDO_USER" bash -c "make CMAKE_BUILD_TYPE=Release -j4"
            make install
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvchad ]; then
        if [ ! -d "/home/$SUDO_USER/.config/nvim" ]; then
            sudo -H -u "$SUDO_USER" bash -c "git clone git@github.com:NvChad/NvChad.git '/home/$SUDO_USER/.config/nvim'"
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/nvim"
            cd "/home/$SUDO_USER/.config/nvim"
            git checkout v2.0
        fi
        if [ ! -L "/home/$SUDO_USER/.config/nvim/lua/custom" ]; then
            ln -s "/home/$SUDO_USER/scripts/nvchad-v2.0" "/home/$SUDO_USER/.config/nvim/lua/custom"
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

    if [ "$pkg" == cargo-tree-sitter ]; then
        sudo -H -u "$SUDO_USER" bash -c "/home/$SUDO_USER/.cargo/bin/cargo install tree-sitter-cli"
        echo "$pkg is installed." && continue
    fi

    if ! deb_installed "$pkg"; then
        apt install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done

# https://wiki.archlinux.org/title/SSH_keys
ssh_agent_setup_path="$HOME/.local/ssh-agent-setup"
if [ ! -f "$ssh_agent_setup_path" ]; then
    cat >"$ssh_agent_setup_path" << EOF
if ! pgrep -u "$SUDO_USER" ssh-agent > /dev/null; then
    ssh-agent -t 24h > "$HOME/.ssh/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$HOME/.ssh/ssh-agent.env" >/dev/null
fi
EOF
fi
if ! grep -qF "source $HOME/.local/ssh-agent-setup" "$HOME/.bashrc" ; then
    echo "source $HOME/.local/ssh-agent-setup" >> "$HOME/.bashrc"
fi

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
