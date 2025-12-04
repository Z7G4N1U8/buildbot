#!/usr/bin/env bash

source build/envsetup.sh

# Increase System Limits
ulimit -n 65536
ulimit -S -n 65536

# Setup ccache
ccache -M 50G > /dev/null
ccache -o compression=true
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

export USE_RBE=1                                      
export RBE_DIR="$HOME/.rbe"
export NINJA_REMOTE_NUM_JOBS=256

# BuildBuddy Connection Settings
export RBE_service="remote.buildbuddy.io:443"
export RBE_use_rpc_credentials=false                   
export RBE_service_no_auth=true                       

# Unified Downloads/Uploads
export RBE_use_unified_downloads=true
export RBE_use_unified_uploads=true

# Execution Strategies
export RBE_R8_EXEC_STRATEGY=remote_local_fallback
export RBE_D8_EXEC_STRATEGY=remote_local_fallback
export RBE_JAVAC_EXEC_STRATEGY=remote_local_fallback
export RBE_JAR_EXEC_STRATEGY=remote_local_fallback
export RBE_ZIP_EXEC_STRATEGY=remote_local_fallback
export RBE_TURBINE_EXEC_STRATEGY=remote_local_fallback
export RBE_SIGNAPK_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_EXEC_STRATEGY=remote_local_fallback
export RBE_CXX_LINKS_EXEC_STRATEGY=remote_local_fallback
export RBE_ABI_LINKER_EXEC_STRATEGY=remote_local_fallback
export RBE_CLANG_TIDY_EXEC_STRATEGY=remote_local_fallback
export RBE_METALAVA_EXEC_STRATEGY=remote_local_fallback
export RBE_LINT_EXEC_STRATEGY=remote_local_fallback

# Enable RBE for Specific Tools
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
export RBE_CLANG_TIDY=1
export RBE_METALAVA=1
export RBE_LINT=1

# Resource Pools
export RBE_JAVA_POOL=default
export RBE_METALAVA_POOL=default
export RBE_LINT_POOL=default

# Timeouts
export RBE_reclient_timeout=60m
export RBE_exec_timeout=10m

function paste() {
  local file=${1:-/dev/stdin}
  curl --data-binary @${file} https://paste.rs
}

function upload() {
  local server=$(curl -s https://api.gofile.io/servers | jq -r '.data.servers[0].name')
  for file in "$@"; do
    local link=$(curl -# -F "file=@${file}" "https://${server}.gofile.io/uploadFile" | jq -r '.data|.downloadPage') 2>&1
    echo -e "Uploaded '${file}': ${link}"
  done
}
