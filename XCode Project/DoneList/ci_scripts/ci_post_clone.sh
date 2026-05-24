#!/bin/bash
# ci_post_clone.sh — Xcode Cloud: auto-set build number
#
# Xcode Cloud provides $CI_BUILD_NUMBER (auto-incremented each cloud build).
# We write it into CURRENT_PROJECT_VERSION so App Store Connect always sees
# a unique, increasing build number — no manual bumping needed.
#
# Apple sets the working directory to the folder that contains ci_scripts/,
# which is "XCode Project/DoneList/" — so the project file is reachable via
# a relative path. We do NOT use $CI_WORKSPACE because its value is the path
# to the .xcodeproj/.xcworkspace file, not the repository root.
#
# Reference: https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds

set -euo pipefail

echo "ci_post_clone: pwd=$(pwd)"
echo "ci_post_clone: CI_BUILD_NUMBER=${CI_BUILD_NUMBER}"

# Guard: CI_BUILD_NUMBER must be a non-empty integer before we touch anything.
# An empty/missing value would silently produce CURRENT_PROJECT_VERSION = ;,
# corrupting project.pbxproj while perl exits 0 (set -e wouldn't catch it).
if ! [[ "${CI_BUILD_NUMBER}" =~ ^[0-9]+$ ]]; then
  echo "ERROR: CI_BUILD_NUMBER is not a valid integer: '${CI_BUILD_NUMBER}'"
  exit 1
fi

# Relative path — working directory is the parent of ci_scripts/ (Apple guarantee).
PROJ="DoneList.xcodeproj/project.pbxproj"

echo "ci_post_clone: project path=$(pwd)/${PROJ}"

if [ ! -f "${PROJ}" ]; then
  echo "ERROR: project.pbxproj not found. Working directory contents:"
  ls -la
  exit 1
fi

# Use perl -pi for reliable in-place substitution (avoids BSD/GNU sed differences).
# CI_BUILD_NUMBER is verified to be a pure integer above, safe to interpolate.
perl -pi -e "s/CURRENT_PROJECT_VERSION = \\d+;/CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER};/g" "${PROJ}"

# Verify at least one substitution actually happened.
# Perl exits 0 on zero matches, so without this a regex drift would silently
# no-op and App Store Connect would reject the upload for a duplicate build number.
if ! grep -q "CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER};" "${PROJ}"; then
  echo "ERROR: substitution did not take effect — CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER}; not found"
  echo "Existing CURRENT_PROJECT_VERSION lines:"
  grep "CURRENT_PROJECT_VERSION" "${PROJ}" || true
  exit 1
fi

echo "ci_post_clone: CURRENT_PROJECT_VERSION set to ${CI_BUILD_NUMBER} — done"
