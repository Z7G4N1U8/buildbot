#!/bin/bash

# Optimizing filesystem mount
sudo mount -o remount,rw,noatime,commit=600 /

packages=(
  # lineage
  "bc" "bison" "build-essential" "ccache" "curl" "flex" "g++-multilib" "gcc-multilib"
  "git" "git-lfs" "gnupg" "gperf" "imagemagick" "protobuf-compiler" "python3-protobuf"
  "python-is-python3" "lib32readline-dev" "lib32z1-dev" "libdw-dev" "libelf-dev"
  "lib32ncurses-dev" "libncurses6" "libncurses-dev" "lz4" "libsdl1.2-dev" "libssl-dev"
  "libxml2" "libxml2-utils" "lzop" "pngcrush" "rsync" "schedtool" "squashfs-tools"
  "xsltproc" "zip" "zlib1g-dev"

  # extra
  "btop" "linux-modules-extra-$(uname -r)" "micro" "zram-tools" "zstd"
)

# Install all necessary packages
sudo apt-get update -y
sudo apt-get install -y "${packages[@]}"

# Configure git
git_configs=(
  "user.name Peace"
  "user.email git@z7g4n1u8.dev"
  "trailer.changeid.key Change-Id"
  "color.ui true"
  "core.preloadindex true"
  "core.untrackedCache true"
  "gc.auto 0"
)

for config in "${git_configs[@]}"; do
  git config --global ${config}
done

git lfs install

# Setup ssh
echo "$SSH_KEY" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
cat <<EOF > ~/.ssh/config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF

# Install repo
sudo curl -LSs https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo
sudo chmod +x /usr/local/bin/repo

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
