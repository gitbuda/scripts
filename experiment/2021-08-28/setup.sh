#!/bin/bash -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dotfiles="bashrc tmux.conf"

for f in ${dotfiles}; do
    rm -rf "$HOME/.$f"
    ln -s "${script_dir}/$f" "$HOME/.$f"
done

## Dependencies setup.
# Tmux Plugin Manager setup.
tpm_repo="https://github.com/tmux-plugins/tpm"
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ ! -d "${tpm_dir}" ]]; then
    git clone "${tpm_repo}" "${tpm_dir}"
fi
