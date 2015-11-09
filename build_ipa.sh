#!/bin/bash

## build ipa and upload to http://www.pgyer.com/

DATE=$(date +'%Y-%m-%d')
TIME=$(date +'%H%M%S')

SHELL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$( cd "${SHELL_DIR}" && cd "../../" && pwd)

PRODUCT=YOUR_PRODUCT_NAME
WORKSPACE="${BASE_DIR}"/"${PRODUCT}".xcworkspace
CONF=Enterprise
SCHEME="${PRODUCT}"

# pgyer
PGYER_USER_KEY=YOUR_USER_KEY
PGYER_API_KEY=YOUR_API_KEY
PGYER_API_URL="http://www.pgyer.com/apiv1/app/upload"

# dirs
OUTPUT_DIR="${BASE_DIR}"/build/"${DATE}"/"${TIME}"
DERIVED_DATA_PATH="${OUTPUT_DIR}"/derived
ARCHIVE_PATH="${OUTPUT_DIR}"/"${PRODUCT}".xcarchive
APP_PATH="${ARCHIVE_PATH}"/Products/Applications/"${PRODUCT}".app
IPA_PATH="${OUTPUT_DIR}"/"${PRODUCT}".ipa
DSYM_PATH="${DERIVED_DATA_PATH}"/Build/Intermediates/ArchiveIntermediates/"${PRODUCT}"/BuildProductsPath/"${CONF}"-iphoneos/"${PRODUCT}".app.dSYM

# build ipa
xcodebuild -workspace "${WORKSPACE}" -scheme "${SCHEME}" -configuration "${CONF}" \
-archivePath "${ARCHIVE_PATH}" -derivedDataPath "${DERIVED_DATA_PATH}" archive
xcrun -sdk iphoneos PackageApplication "${APP_PATH}" -o "${IPA_PATH}"

# upload to http://www.pgyer.com/
curl -F "file=@${IPA_PATH}" -F "uKey=${PGYER_USER_KEY}" -F "_api_key=${PGYER_API_KEY}" "${PGYER_API_URL}"

# copy dSYM file
cp -R "${DSYM_PATH}" "${OUTPUT_DIR}/"
# clean derived data & archive file
rm -fr "${ARCHIVE_PATH}"
rm -fr "${DERIVED_DATA_PATH}"
