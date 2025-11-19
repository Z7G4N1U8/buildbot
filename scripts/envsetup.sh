#!/bin/bash

SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"

packages=(
  "7zip"
  "aria2" "arj" "axel"
  "bc" "bison" "brotli" "build-essential"
  "cabextract" "ccache" "cpio" "curl"
  "detox" "device-tree-compiler"
  "flex"
  "g++-multilib" "gawk" "gcc-multilib" "git" "git-lfs" "gnupg" "gperf"
  "imagemagick"
  "lib32ncurses5-dev" "lib32readline-dev" "lib32z1-dev" "liblz4-dev" "liblz4-tool" "liblzma-dev" "libncurses5" "libncurses5-dev" "libdw-dev" "libelf-dev" "libsdl1.2-dev" "libssl-dev" "libxml2" "libxml2-utils" "lz4" "lzop"
  "mpack"
  "p7zip-full" "p7zip-rar" "pngcrush" "protobuf-compiler" "python3-pip" "python3-protobuf" "python-is-python3"
  "rar" "rename" "ripgrep" "rsync"
  "schedtool" "sharutils" "squashfs-tools"
  "unace" "unrar" "unzip" "uudeview"
  "xsltproc"
  "zip" "zlib1g-dev"
)

# Backup source.list if it doesn't already exist
if [ ! -f "${SOURCES_FILE}.bak" ]; then
    sudo cp "$SOURCES_FILE" "${SOURCES_FILE}.bak"
    echo "Backup of $SOURCES_FILE created at ${SOURCES_FILE}.bak"
else
    echo "Backup file (${SOURCES_FILE}.bak) already exists. Skipping new backup."
fi

# Use awk to add 'contrib non-free' only if they are missing
sudo awk '
  /Components: main/ {
    if (!/non-free/) {
      print $0 " contrib non-free"
    } else {
      print
    }
    next
  }
  { print }
' "$SOURCES_FILE" | sudo tee "$SOURCES_FILE.tmp" > /dev/null
sudo mv "$SOURCES_FILE.tmp" "$SOURCES_FILE"

# Update system and install all necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y "${packages[@]}"

# Installing uv
curl -LsSf https://astral.sh/uv/install.sh | bash

# Install repo
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Configure git
git config --global user.name "Peace"
git config --global user.email "git@z7g4n1u8.dev"
git config --global trailer.changeid.key "Change-Id"
git lfs install

# Setup ccache
cat << EOF >> ~/.bashrc
USE_CCACHE=1
CCACHE_EXEC=/usr/bin/ccache
TERM=xterm
EOF
ccache -M 50G
