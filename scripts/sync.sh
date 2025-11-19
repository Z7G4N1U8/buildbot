#!/bin/bash

# Run repo sync command and capture the output
find .repo -name '*.lock' -delete
repo sync -c -j$(nproc --all) --force-sync --no-tags --no-clone-bundle --prune 2>&1 | tee /tmp/output.txt

# Check if there's any failing repositories
if grep -qe "Failing repos\|uncommitted changes are present" /tmp/output.txt ; then
  echo "Found failing repositories, trying to fix..."

  bad_repos=$(awk '
    /Failing repos.*:/ {flag=1; next}
    /Try/ {flag=0}
    flag {print $NF}
    /uncommitted changes are present/ {print $2}
  ' /tmp/output.txt | sed 's/://g' | sort -u)

  if [ -n "$bad_repos" ]; then
    for repo_path in $bad_repos; do
      [ -z "$repo_path" ] && continue
      echo "Fixing: $repo_path"
      rm -rf "$repo_path"
      rm -rf ".repo/projects/$repo_path.git"
    done
  fi
else
  exit 0
fi

# Sync all repositories after deletion
echo "Re-syncing all repositories..."
find .repo -name '*.lock' -delete
repo sync -c -j$(nproc --all) --force-sync --no-tags --no-clone-bundle --prune
