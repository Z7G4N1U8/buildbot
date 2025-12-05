#!/usr/bin/env bash

function set_vars() {
  MANIFEST=$1
  BRANCH=$2
  TARGET=$3
  BUILD_TYPE=$4
}

case "$ANDROID" in
  LineageOS) set_vars https://github.com/LineageOS/android.git lineage-23.0 bacon userdebug ;;
  Evolution-X) set_vars https://github.com/Evolution-X/manifest.git bka evolution user ;;
esac

PROJECT="$HOME/$ANDROID"
PROJECT_FILES="$HOME/files/$ANDROID"
TOOLS="https://raw.githubusercontent.com/$GH_REPOSITORY/refs/heads/main"
RSYNC_OPTS=( -avP --exclude='*-ota.zip' --include='*.zip' --exclude='*' )

function handle_error() {
  cat out/error.log
  paste out/error.log
  exit 1
} ; trap handle_error ERR

mkdir -p $PROJECT $PROJECT_FILES
curl -LSs $TOOLS/scripts/gcpsetup.sh | bash

cd $PROJECT

rm -rf .repo/local_manifests vendor/private/keys
repo init --depth 1 --git-lfs -u $MANIFEST -b $BRANCH
git clone https://github.com/$GH_ACTOR/android_local_manifests.git .repo/local_manifests
git clone https://$GH_TOKEN@github.com/$GH_ACTOR/android_vendor_private_keys.git vendor/private/keys
curl -LSs $TOOLS/scripts/sync.sh | bash

[ "$ANDROID" != "LineageOS" ] && (cd device/motorola/eqe && curl -LSs $TOOLS/patches/$ANDROID.patch | git am) || true
source <(curl -LSs $TOOLS/scripts/envsetup.sh)

breakfast eqe $BUILD_TYPE
cmka $TARGET

rsync "${RSYNC_OPTS[@]}" $OUT/ $PROJECT_FILES
[ $SF_UPLOAD == true ] && rsync "${RSYNC_OPTS[@]}" -e "ssh -o StrictHostKeyChecking=no" $OUT/ z7g4n1u8@frs.sourceforge.net:/home/frs/project/eqe/$ANDROID || true
