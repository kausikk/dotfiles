#!/usr/bin/env bash
# script for building and installing neovim to my tools directory
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/tools/neovim-bin
make install
