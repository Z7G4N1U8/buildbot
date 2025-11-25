#!/bin/bash

# Remove uncommitted/unstaged changes
repo forall -j$(nproc --all) -c "git reset --hard ; git clean -fdx" > /dev/null

# Run repo sync command and capture the output
find .repo -name '*.lock' -delete
repo sync -c -j$(nproc --all) --force-sync --no-tags --no-clone-bundle --prune 2>&1 | tee sync_output.txt

# Check if there's any failing repositories
if [ ${PIPESTATUS[0]} -ne 0 ] || grep -qe "Failing repos" sync_output.txt ; then
  echo "Found failing repositories, trying to fix..."

  # Extract path of failing repositories
  bad_repos=$(awk '
    /Failing repos.*:/ {flag=1; next}
    /Try/ {flag=0}
    flag {print $NF}
  ' sync_output.txt | sed 's/://g' | sort -u)

  # Delete all failing repositories
  if [ -n "$bad_repos" ]; then
    for repo_path in $bad_repos; do
      [ -z "$repo_path" ] && continue
      echo "Deleting: $repo_path"
      rm -rf "$repo_path" ".repo/projects/$repo_path.git"
    done
  fi

  echo "Re-syncing all repositories..."
  find .repo -name '*.lock' -delete
  repo sync -c -j$(nproc --all) --force-sync --no-tags --no-clone-bundle --prune

  if [ $? -ne 0 ]; then
    echo "Sync failed again. Exiting."
    exit 1
  fi
fi

# Unshallow all repositories on local group
repo forall -j$(nproc --all) -g local -c "git fetch --unshallow"
