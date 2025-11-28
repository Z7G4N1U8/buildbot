#!/bin/bash

ACTION=$1

TOKEN_JSON=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$GH_REPOSITORY/actions/runners/$ACTION-token)

RUNNER_TOKEN=$(echo $TOKEN_JSON | jq -r .token)

if [ "$ACTION" == "registration" ]; then
  mkdir -p actions-runner && cd actions-runner
  VER=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -oP '"tag_name": "v\K[^"]*')
  curl -LSs "https://github.com/actions/runner/releases/download/v${VER}/actions-runner-linux-x64-${VER}.tar.gz" | tar xz
  sudo bin/installdependencies.sh
  ./config.sh --unattended --url https://github.com/$GH_REPOSITORY --token $RUNNER_TOKEN
  sudo apt-get -y install tmux
  tmux new-session -d -s ghactions './run.sh'
elif [ "$ACTION" == "remove" ]; then
  cd actions-runner
  tmux kill-session -t ghactions
  ./config.sh remove --token $RUNNER_TOKEN
  cd ..
  rm -rf actions-runner
else
  echo "Error: Unknown action $ACTION"
  exit 1
fi
