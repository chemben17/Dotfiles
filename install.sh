#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

# Ensure necessary directories exist
mkdir -p ~/.ssh  # Creates .ssh directory if it doesn’t exist

# Symlink dotfiles
ln -sf $DOTFILES_DIR/.bashrc ~/.bashrc
ln -sf $DOTFILES_DIR/.vimrc ~/.vimrc
ln -sf $DOTFILES_DIR/.ssh/config ~/.ssh/config

echo "Dotfiles installed successfully!"
