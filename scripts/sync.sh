#!/usr/bin/env bash

MAX_TRIES=3
COUNT=0

# Remove uncommitted/unstaged changes
repo forall -j$(nproc --all) -c "git reset --hard ; git clean -fdx" > /dev/null

while [ $COUNT -lt $MAX_TRIES ]; do
  COUNT=$((COUNT + 1))
  echo "===== Sync Attempt $COUNT of $MAX_TRIES ====="

  # Run repo sync command and capture the output
  find .repo -name "*.lock" -type f -not -path "*/objects/*" -delete
  repo sync -c -j$(nproc --all) --force-sync --no-tags --no-clone-bundle --prune 2>&1 | tee sync_output.txt

  [ ${PIPESTATUS[0]} -eq 0 ] && break # Success: Exit loop
  [ $COUNT -eq $MAX_TRIES ] && exit 1 # Failure: Abort script

  # Delete failing repositories
  FAILING_REPOS=$(awk '/Failing repos.*:/{f=1;next}/Try/{exit}f{print $NF}' sync_output.txt | sort -u)
  [ -n "$FAILING_REPOS" ] && for REPO_PATH in $FAILING_REPOS; do
    [ -z "$REPO_PATH" ] && continue
    echo "Deleting: $REPO_PATH"
    rm -rf "$REPO_PATH" ".repo/projects/$REPO_PATH.git"
  done
done

# Unshallow all repositories on local group
repo forall -j$(nproc --all) -g local -c "git fetch --unshallow"
