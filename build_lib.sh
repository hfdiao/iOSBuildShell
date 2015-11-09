#!/bin/bash

## build universal shared library

TRIM_STR() {
    local STR="$1"
    STR=${STR//[[:blank:]]/}
    echo "${STR}"
}

GIT=$( sh /etc/profile; which git )

# set to project target name
TARGET_NAME=YOUR_TARGET_NAME
CONF=Release

# version
VERSION_MAJOR=1
VERSION_MINOR=0

# git commit count
VERSION_REVISION="$( "$GIT" rev-list --all |wc -l )"
VERSION_REVISION="$( TRIM_STR "${VERSION_REVISION}" )"
# git commit sha1
COMMIT_SHA1="$( "$GIT" rev-parse --short HEAD )"
COMMIT_SHA1="$( TRIM_STR "${COMMIT_SHA1}" )"
VERSION="${VERSION_MAJOR}"."${VERSION_MINOR}"."${VERSION_REVISION}"."${COMMIT_SHA1}"

# @sealed ----------------------------------------------------------------------
SHELL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$( cd "${SHELL_DIR}" && cd "../../" && pwd)
PROJECT="${BASE_DIR}"/"${TARGET_NAME}".xcodeproj
OUTPUT="${BASE_DIR}"/build/

if [ -e "${OUTPUT}" ];
then
  rm -r "${OUTPUT}"
fi

xcodebuild -project "${PROJECT}" -target "${TARGET_NAME}" ONLY_ACTIVE_ARCH=NO \
-configuration "${CONF}" -sdk iphoneos BUILD_DIR="${OUTPUT}"/iphoneos
xcodebuild -project "${PROJECT}" -target "${TARGET_NAME}" ONLY_ACTIVE_ARCH=NO \
-configuration "${CONF}" -sdk iphonesimulator BUILD_DIR="${OUTPUT}"/iphonesimulator

mkdir -p "${OUTPUT}"/universal/lib/

lipo -create -output "${OUTPUT}"/universal/lib/lib"${TARGET_NAME}"-"${VERSION}".a \
"${OUTPUT}"/iphoneos/"${CONF}"-iphoneos/lib"${TARGET_NAME}".a \
"${OUTPUT}"/iphonesimulator/"${CONF}"-iphonesimulator/lib"${TARGET_NAME}".a
cp -R "${OUTPUT}"/iphoneos/"${CONF}"-iphoneos/include "${OUTPUT}"/universal/
# @end -------------------------------------------------------------------------
