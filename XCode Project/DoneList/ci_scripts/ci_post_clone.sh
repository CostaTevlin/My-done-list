#!/bin/sh
# ci_post_clone.sh — Xcode Cloud: auto-set build number
#
# Xcode Cloud provides $CI_BUILD_NUMBER (auto-incremented each cloud build).
# We write it into CURRENT_PROJECT_VERSION so App Store Connect always sees
# a unique, increasing build number — no manual bumping needed.
#
# Reference: https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds

set -e

echo "ci_post_clone: CI_BUILD_NUMBER=${CI_BUILD_NUMBER}"
echo "ci_post_clone: CI_WORKSPACE=${CI_WORKSPACE}"

PROJ="${CI_WORKSPACE}/XCode Project/DoneList/DoneList.xcodeproj/project.pbxproj"

echo "ci_post_clone: project path=${PROJ}"

if [ ! -f "${PROJ}" ]; then
  echo "ERROR: project.pbxproj not found at: ${PROJ}"
  echo "Listing CI_WORKSPACE:"
  ls "${CI_WORKSPACE}" || true
  exit 1
fi

# Use perl -pi instead of sed -i to avoid BSD/GNU differences
# and reliably handle file paths that contain spaces.
perl -pi -e "s/CURRENT_PROJECT_VERSION = \\d+;/CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER};/g" "${PROJ}"

echo "ci_post_clone: CURRENT_PROJECT_VERSION set to ${CI_BUILD_NUMBER} — done"
