SHELL := /bin/bash

all: install

install:
	@echo "Setting up dotfiles...."
	stow -v .bash .git .vim .ssh
	@cho "Dotfiles Installed successfully!"

clean:
	@echo "Removing dotfiles..."
	stow -D bash git vim ssh
	@echo "Dotfiles removed!"
