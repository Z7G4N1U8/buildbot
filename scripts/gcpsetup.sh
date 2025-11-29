#!/bin/bash

# Optimizing filesystem mount
sudo mount -o remount,rw,noatime,commit=600 /

packages=(
  # lineage
  "bc" "bison" "build-essential" "ccache" "curl" "flex" "g++-multilib" "gcc-multilib"
  "git" "git-lfs" "gnupg" "gperf" "protobuf-compiler" "python3-protobuf" "python-is-python3"
  "repo" "lib32readline-dev" "lib32z1-dev" "libdw-dev" "libelf-dev" "lib32ncurses-dev"
  "libncurses6" "libncurses-dev" "lz4" "libsdl1.2-dev" "libssl-dev" "libxml2" "libxml2-utils"
  "lzop" "pngcrush" "rsync" "schedtool" "squashfs-tools" "xsltproc" "zip" "zlib1g-dev"

  # extra
  "btop" "linux-modules-extra-$(uname -r)" "micro" "zram-tools" "zstd"
)

# Install all necessary packages
sudo apt-get update -y
sudo apt-get install -y "${packages[@]}"

# Configure git
git config --global user.name "Peace"
git config --global user.email "git@z7g4n1u8.dev"
git config --global color.ui true
git config --global core.preloadindex true
git config --global core.untrackedCache true
git config --global gc.auto 0
git lfs install

# Setup RBE
if [ ! -d "$HOME/.rbe" ]; then
  wget -q https://github.com/xyz-sundram/Releases/releases/download/client-linux-amd64/client-linux-amd64.zip
  unzip -q client-linux-amd64.zip -d ~/.rbe
  rm client-linux-amd64.zip
fi

# ZRAM Setup
cat << EOF | sudo tee /etc/default/zramswap > /dev/null
ALGO=zstd
PERCENT=100
PRIORITY=100
EOF
sudo systemctl restart zramswap

# Kernel Tuning
kernel_settings=(
  "vm.swappiness=100"
  "vm.page-cluster=0"
  "vm.dirty_background_ratio=10"
  "vm.dirty_ratio=40"
  "net.core.default_qdisc=fq"
  "net.ipv4.tcp_congestion_control=bbr"
)

sudo sysctl -q "${kernel_settings[@]}"
