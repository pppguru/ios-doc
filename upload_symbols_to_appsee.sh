#!/bin/sh
echo "Appsee - Starting debug symbols upload..."

APIKEY="$1"
APIURL="https://api.appsee.com/crashes/upload-symbols"

# Check given APIKey
if [ ! "${APIKEY}" ]; then
    echo "Appsee - Please provide your API Key"
    echo "Appsee - Usage: ./upload_symbols.sh APIKEY"
    exit 1
fi

# Upload dSYM
RES=$(curl "${APIURL}?APIKey=${APIKEY}" --write-out %{http_code} --silent --output /dev/null -F dsym=@"${ZIP_PATH}")
if [ $RES -ne 200 ]; then
    echo "Appsee - Upload failed with status $RES. Please contact support@appsee.com for assistance"
    exit 1
fi

# Remove Zip file
/bin/rm -f "${ZIP_PATH}"

echo "Appsee - Debug symbols uploaded successfully"
