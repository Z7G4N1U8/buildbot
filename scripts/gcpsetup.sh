#!/bin/bash

# remount root as noatime
sudo mount -o remount,rw,noatime /

packages=(
  "7zip"
  "android-sdk-platform-tools" "aria2" "arj" "axel"
  "bc" "bison" "brotli" "build-essential"
  "cabextract" "ccache" "cpio" "curl"
  "detox" "device-tree-compiler"
  "flex"
  "g++-multilib" "gawk" "gcc-multilib" "git" "git-lfs" "gnupg" "gperf"
  "imagemagick"
  "lib32ncurses-dev" "lib32readline-dev" "lib32z1-dev" "liblz4-dev" "liblz4-tool" "liblzma-dev" "libncurses6" "libncurses-dev" "libdw-dev" "libelf-dev" "libsdl1.2-dev" "libssl-dev" "libxml2" "libxml2-utils" "linux-modules-extra-$(uname -r)" "lz4" "lzop"
  "mpack"
  "p7zip-full" "p7zip-rar" "pngcrush" "protobuf-compiler" "python3-pip" "python3-protobuf" "python-is-python3"
  "rar" "rename" "ripgrep" "repo" "rsync"
  "schedtool" "sharutils" "squashfs-tools"
  "unace" "unrar" "unzip" "uudeview"
  "xsltproc"
  "zip" "zlib1g-dev" "zram-tools" "zstd"
)

# Install all necessary packages
sudo apt-get update -y
sudo apt-get install -y "${packages[@]}"

# Configure git
git config --global user.name "Peace"
git config --global user.email "git@z7g4n1u8.dev"
git config --global color.ui true

# Install additional stuff
curl -LsSf https://astral.sh/uv/install.sh | bash
git lfs install

# Setup RBE
if [ ! -d "$HOME/rbe" ]; then
  wget -q https://github.com/xyz-sundram/Releases/releases/download/client-linux-amd64/client-linux-amd64.zip
  unzip -q client-linux-amd64.zip -d $HOME/rbe
  rm client-linux-amd64.zip
fi

# ZRAM Setup
cat << EOF | sudo tee /etc/default/zramswap > /dev/null
ALGO=zstd
PERCENT=100
PRIORITY=100
EOF
sudo systemctl restart zramswap

# Kernel Tuning (Memory + Network for RBE)
sudo sysctl vm.swappiness=100 > /dev/null
sudo sysctl vm.page-cluster=0 > /dev/null
sudo sysctl vm.vfs_cache_pressure=50 > /dev/null
sudo sysctl vm.dirty_background_bytes=419430400 > /dev/null
sudo sysctl vm.dirty_bytes=1073741824 > /dev/null
sudo sysctl -w net.core.default_qdisc=fq > /dev/null
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null

# Setup ccache
ccache -M 50G > /dev/null
