#!/bin/sh
# ci_post_clone.sh — Xcode Cloud: auto-set build number
#
# Xcode Cloud provides $CI_BUILD_NUMBER, which auto-increments with every
# cloud build. We write it into CURRENT_PROJECT_VERSION across all build
# configurations so App Store Connect always sees a unique, increasing number.
# This eliminates the need to manually bump the build number before each upload.
#
# Reference: https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds

set -e

PROJ="$CI_WORKSPACE/XCode Project/DoneList/DoneList.xcodeproj/project.pbxproj"

echo "ci_post_clone: setting CURRENT_PROJECT_VERSION to $CI_BUILD_NUMBER"

sed -i '' \
  "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $CI_BUILD_NUMBER;/g" \
  "$PROJ"

echo "ci_post_clone: done"
