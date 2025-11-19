#!/bin/bash

packages=(
  "7zip"
  "android-sdk-platform-tools" "aria2" "arj" "axel"
  "bc" "bison" "brotli" "build-essential"
  "cabextract" "ccache" "cpio" "curl"
  "detox" "device-tree-compiler"
  "flex"
  "g++-multilib" "gawk" "gcc-multilib" "git" "git-lfs" "gnupg" "gperf"
  "imagemagick"
  "lib32ncurses-dev" "lib32readline-dev" "lib32z1-dev" "liblz4-dev" "liblz4-tool" "liblzma-dev" "libncurses6" "libncurses-dev" "libdw-dev" "libelf-dev" "libsdl1.2-dev" "libssl-dev" "libxml2" "libxml2-utils" "lz4" "lzop"
  "mpack"
  "p7zip-full" "p7zip-rar" "pngcrush" "protobuf-compiler" "python3-pip" "python3-protobuf" "python-is-python3"
  "rar" "rename" "ripgrep" "repo" "rsync"
  "schedtool" "sharutils" "squashfs-tools"
  "unace" "unrar" "unzip" "uudeview"
  "xsltproc"
  "zip" "zlib1g-dev"
)

# Update system and install all necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y "${packages[@]}"

# Install additional stuff
curl -LsSf https://astral.sh/uv/install.sh | bash
git lfs install

# Setup ccache
cat << EOF >> ~/.bashrc
USE_CCACHE=1
CCACHE_EXEC=/usr/bin/ccache
EOF
ccache -M 50G
