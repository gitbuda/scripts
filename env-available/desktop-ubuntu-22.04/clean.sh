#!/bin/bash

# TODO(gitbuda): Add the ability to pick one package.

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"

rm -rf "$script_dir/neovim"
rm -rf /home/buda/.config/nvim
rm -rf /home/buda/.local/share/nvim
rm -rf /home/buda/.cache/nvim
