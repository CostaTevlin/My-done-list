#!/bin/bash
# ci_post_clone.sh — Xcode Cloud: auto-set build number
#
# Xcode Cloud provides $CI_BUILD_NUMBER (auto-incremented each cloud build).
# We write it into CURRENT_PROJECT_VERSION so App Store Connect always sees
# a unique, increasing build number — no manual bumping needed.
#
# Reference: https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds

# -e  exit on any error
# -u  treat unset variables as errors (catches missing CI_BUILD_NUMBER early)
# -o pipefail  propagate pipe failures
set -euo pipefail

echo "ci_post_clone: CI_BUILD_NUMBER=${CI_BUILD_NUMBER}"
echo "ci_post_clone: CI_WORKSPACE=${CI_WORKSPACE}"

# Guard: CI_BUILD_NUMBER must be a non-empty integer before we touch anything.
# An empty value would silently produce CURRENT_PROJECT_VERSION = ; in every
# build config, corrupting project.pbxproj with perl exiting 0.
if ! [[ "${CI_BUILD_NUMBER}" =~ ^[0-9]+$ ]]; then
  echo "ERROR: CI_BUILD_NUMBER is not a valid integer: '${CI_BUILD_NUMBER}'"
  exit 1
fi

PROJ="${CI_WORKSPACE}/XCode Project/DoneList/DoneList.xcodeproj/project.pbxproj"

echo "ci_post_clone: project path=${PROJ}"

if [ ! -f "${PROJ}" ]; then
  echo "ERROR: project.pbxproj not found at: ${PROJ}"
  echo "Listing CI_WORKSPACE:"
  ls "${CI_WORKSPACE}" || true
  exit 1
fi

# Use perl -pi for reliable in-place substitution (avoids BSD/GNU sed differences).
# ${CI_BUILD_NUMBER} is verified to be a pure integer above, so it is safe to
# interpolate directly into the replacement side of the s/// expression.
perl -pi -e "s/CURRENT_PROJECT_VERSION = \\d+;/CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER};/g" "${PROJ}"

# Verify at least one substitution actually happened.
# Perl exits 0 on zero matches, so without this check a regex drift (e.g. Xcode
# changes the pbxproj format) would silently produce a no-op and the archive
# would be rejected by App Store Connect for a duplicate build number.
if ! grep -q "CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER};" "${PROJ}"; then
  echo "ERROR: substitution did not take effect — expected 'CURRENT_PROJECT_VERSION = ${CI_BUILD_NUMBER};' in project.pbxproj"
  echo "Existing CURRENT_PROJECT_VERSION lines:"
  grep "CURRENT_PROJECT_VERSION" "${PROJ}" || true
  exit 1
fi

echo "ci_post_clone: CURRENT_PROJECT_VERSION set to ${CI_BUILD_NUMBER} — done"
