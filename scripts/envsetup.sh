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
  "zip" "zlib1g-dev" "zram-tools" "zstd"
)

# Update system and install all necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y "${packages[@]}"

# Configure git
git config --global user.name "Peace"
git config --global user.email "git@z7g4n1u8.dev"
git config --global color.ui true

# Install additional stuff
curl -LsSf https://astral.sh/uv/install.sh | bash
git lfs install

# Setup ccache
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G

# Setup zram
cat << EOF | sudo tee /etc/default/zramswap > /dev/null
ALGO=zstd
PERCENT=100
PRIORITY=100
EOF

sudo systemctl restart zramswap
sudo sysctl vm.swappiness=100 > /dev/null
sudo zramctl

# Setup RBE
rm -rf $HOME/rbe client-linux-amd64.zip
wget https://github.com/xyz-sundram/Releases/releases/download/client-linux-amd64/client-linux-amd64.zip
unzip client-linux-amd64.zip -d $HOME/rbe

export USE_RBE=1                                      
export RBE_DIR="$HOME/rbe"                      # Path to the extracted reclient directory (relative or absolute)
export NINJA_REMOTE_NUM_JOBS=128                        # Number of parallel remote jobs (adjust based on your RAM, buildbuddy has 80 CPU cores in the free tier)

# --- BuildBuddy Connection Settings ---
export RBE_service="aosp.buildbuddy.io:443"        # BuildBuddy instance address (without grpcs://, add the port 443)
export RBE_use_rpc_credentials=false                   
export RBE_service_no_auth=true                       

# --- Unified Downloads/Uploads (Recommended) ---
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true

# --- Execution Strategies (remote_local_fallback is generally best) ---
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback    # Important see below.
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_DUMPER_EXEC_STRATEGY=    # Will make build slower, by a lot. Keeping this for documentation
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# --- Enable RBE for Specific Tools ---
export RBE_R8=1
export RBE_D8=1
export RBE_JAVAC=1
export RBE_JAR=1
export RBE_ZIP=1
export RBE_TURBINE=1
export RBE_SIGNAPK=1
export RBE_CXX_LINKS=1
export RBE_CXX=1
export RBE_ABI_LINKER=1
export RBE_ABI_DUMPER=    # Will make build slower, by a lot. Keeping this for documentation
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# --- Resource Pools ---
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default
