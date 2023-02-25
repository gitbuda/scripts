#!/bin/bash -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi
if [ "$EUID" -eq 0 ]; then
    SUDO_USER="root"
    HOME="/root"
else
    if [ "$SUDO_USER" == "" ]; then
        echo "Please run as sudo."
        exit 1
    fi
    HOME=/home/$SUDO_USER
fi

# os_type=""
os_distro=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # os_type="Linux"
    if grep -qF "Ubuntu" /etc/os-release ; then
        os_distro="Ubuntu"
    elif grep -qF "Fedora" /etc/os-release ; then
        os_distro="Fedora"
    else
        echo "Unknown OS"
        exit 1
    fi
else
    echo "Unknown OS"
    exit 1
fi

if [ "$os_distro" = "Ubuntu" ]; then
    apt update
    # apt purge -y
    apt install -y git vim neovim tmux htop gcc g++ clang clang-format libssl-dev silversearcher-ag fzf shellcheck procps
fi
if [ "$os_distro" = "Fedora" ]; then
    dnf update
    # dnf remove -y
    dnf install -y git vim neovim tmux htop gcc g++ clang openssl-devel fzf shellcheck procps-ng
fi

sudo -H -u "$SUDO_USER" bash -c "mkdir -p $HOME/.ssh"
sudo -H -u "$SUDO_USER" bash -c "chmod 700 $HOME/.ssh"
sudo -H -u "$SUDO_USER" bash -c "mkdir -p $HOME/Workspace/code"
sudo -H -u "$SUDO_USER" bash -c "mkdir -p $HOME/.local"

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

gitconfig_path="$HOME/.gitconfig"
if [ ! -f "$gitconfig_path" ]; then
    wget https://raw.githubusercontent.com/gitbuda/dotfiles/master/gitconfig -O $HOME/.gitconfig
fi

bash_aliases_path="$HOME/.bash_aliases"
if [ ! -f "$bash_aliases_path" ]; then
    wget https://raw.githubusercontent.com/gitbuda/dotfiles/master/bash_aliases -O $HOME/.bash_aliases
fi
if ! grep -qF "$bash_aliases_path" "$HOME/.bashrc" ; then
    echo "source $bash_aliases_path" >> "$HOME/.bashrc"
fi
