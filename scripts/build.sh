#!/usr/bin/env bash

PROJECT="$HOME/Evolution-X"
PROJECT_FILES="$HOME/files/Evolution-X"
SCRIPTS="https://raw.githubusercontent.com/$GH_REPOSITORY/refs/heads/main/scripts"

function handle_error() {
  cat out/error.log
  paste out/error.log
  exit 1
} ; trap handle_error ERR

mkdir -p $PROJECT $PROJECT_FILES
curl -LSs $SCRIPTS/gcpsetup.sh | bash

cd $PROJECT

rm -rf .repo/local_manifests vendor/evolution-priv/keys
repo init --depth 1 --git-lfs -u https://github.com/Evolution-X/manifest -b bq1
git clone https://github.com/$GH_ACTOR/local_manifests .repo/local_manifests
git clone https://$GH_TOKEN@github.com/$GH_ACTOR/android_vendor_evolution-priv_keys vendor/evolution-priv/keys
curl -LSs $SCRIPTS/sync.sh | bash

# Fixes envsetup.sh getting stuck due to generate_host_overrides function
sed -i '/^[[:space:]]*generate_host_overrides[[:space:]]*$/d' vendor/lineage/build/envsetup.sh

source build/envsetup.sh
source <(curl -LSs $SCRIPTS/envsetup.sh)

export BUILD_USERNAME="peace"
export BUILD_HOSTNAME="github"

lunch lineage_eqe-bp3a-user
cmka evolution

cp -u $OUT/*.zip $PROJECT_FILES
rsync -avP -e "ssh -o StrictHostKeyChecking=no" $OUT/*.zip z7g4n1u8@frs.sourceforge.net:/home/frs/project/eqe/Evolution-X
