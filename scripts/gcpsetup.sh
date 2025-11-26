#!/bin/bash

# Optimizing filesystem mount
sudo mount -o remount,rw,noatime,barrier=0,commit=600,data=writeback /

packages=(
  "7zip"
  "android-sdk-platform-tools" "aria2" "arj" "axel"
  "bc" "bison" "brotli" "btop" "build-essential"
  "cabextract" "ccache" "cpio" "curl"
  "detox" "device-tree-compiler"
  "flex"
  "g++-multilib" "gawk" "gcc-multilib" "git" "git-lfs" "gnupg" "gperf"
  "imagemagick"
  "lib32ncurses-dev" "lib32readline-dev" "lib32z1-dev" "liblz4-dev" "liblz4-tool" "liblzma-dev" "libncurses6" "libncurses-dev" "libdw-dev" "libelf-dev" "libsdl1.2-dev" "libssl-dev" "libxml2" "libxml2-utils" "linux-modules-extra-$(uname -r)" "lz4" "lzop"
  "micro" "mpack"
  "p7zip-full" "p7zip-rar" "pngcrush" "protobuf-compiler" "python3-pip" "python3-protobuf" "python-is-python3"
  "rar" "rename" "ripgrep" "rsync"
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
git config --global core.preloadindex true
git config --global core.untrackedCache true
git config --global gc.auto 0
git lfs install

# Install uv
if [ ! -f "$HOME/.local/bin/uv" ]; then
  curl -LSs https://astral.sh/uv/install.sh | bash
fi

# Setup RBE
if [ ! -d "$HOME/.rbe" ]; then
  wget -q https://github.com/xyz-sundram/Releases/releases/download/client-linux-amd64/client-linux-amd64.zip
  unzip -q client-linux-amd64.zip -d ~/.rbe
  rm client-linux-amd64.zip
fi

# Download stock firmware
if [ ! -f "$HOME/.firmware.zip" ]; then
  curl -LSs https://mirrors.lolinet.com/firmware/lenomola/2024/eqe/official/RETAIL/EQE_RETAIL_15_V1UMS35H.10-67-7-2_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip -o ~/.firmware.zip
fi

# Install repo
curl -LSs https://storage.googleapis.com/git-repo-downloads/repo > ~/.local/bin/repo
chmod a+x ~/.local/bin/repo

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
sudo sysctl vm.dirty_background_ratio=10 > /dev/null
sudo sysctl vm.dirty_ratio=40 > /dev/null
sudo sysctl net.core.default_qdisc=fq > /dev/null
sudo sysctl net.ipv4.tcp_congestion_control=bbr > /dev/null

# Setup ccache
ccache -M 50G > /dev/null
ccache -o compression=true
