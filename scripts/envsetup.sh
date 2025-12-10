#!/usr/bin/env bash

source build/envsetup.sh > /dev/null
source <(curl -LSs $TOOLS/scripts/rbe.sh) > /dev/null

# Setup ccache
ccache -M 50G > /dev/null
ccache -o compression=true
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

# Setup user/host name
export BUILD_USERNAME=$USER
export BUILD_HOSTNAME=$HOSTNAME

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
