#!/bin/bash

# Function to install Zsh
install_zsh() {
	if [ "$OSTYPE" = "darwin"* ]; then
		brew install zsh
	elif [ "$OSTYPE" = "linux-gnu"* ]; then
		if command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update
			sudo apt-get install zsh
		elif command -v yum >/dev/null 2>&1; then
			sudo yum update
			sudo yum install zsh
		elif command -v pacman >/dev/null 2>&1; then
			sudo pacman -Syu zsh
		else
			echo "Your package manager is not supported. Please install Zsh manually."
			exit 1
		fi
	else
		echo "Your operating system is not supported. Please install Zsh manually."
		exit 1
	fi
}

# Function to install Oh-My-Zsh
install_oh_my_zsh() {
	# Using curl to download and running with zsh instead of sh
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# Function to install Chaos-Zsh theme
install_chaos_zsh() {
	if [ ! -d ~/.oh-my-zsh/custom/themes ]; then
		mkdir -p ~/.oh-my-zsh/custom/themes
	fi
	curl -L https://raw.github.com/kusamaxi/chaos-zsh/master/chaos.zsh-theme --output ~/.oh-my-zsh/custom/themes/chaos.zsh-theme
	if [ -f ~/.zshrc ]; then
		sed -i.bak 's/ZSH_THEME=".*"/ZSH_THEME="chaos"/g' ~/.zshrc
	else
		echo "Error: Could not find ~/.zshrc"
		exit 1
	fi
}

# Check if Zsh is installed, if not install
if ! command -v zsh >/dev/null 2>&1; then
	echo "Zsh is not installed! Installing Zsh..."
	install_zsh
else
	echo "Zsh is already installed."
fi

# Check if Oh-My-Zsh is installed, if not install
if [ ! -d ~/.oh-my-zsh ]; then
	echo "Oh-My-Zsh is not installed! Installing Oh-My-Zsh..."
	install_oh_my_zsh
else
	echo "Oh-My-Zsh is already installed."
fi

# Install Chaos-Zsh theme
echo "Setting up Chaos-Zsh theme..."
install_chaos_zsh

# Source .zshrc with zsh
zsh -c 'source ~/.zshrc'

echo "Chaos-Zsh theme installation complete!"
