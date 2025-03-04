#!/bin/bash

# Exit script on error
set -e

# Usage function
usage() {
    echo "Usage: $0 <instance-name> <zone> <zip-file>"
    echo "Example: $0 my-instance us-east1-c my-data.zip"
    exit 1
}

# Check if correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

# Assign arguments to variables
INSTANCE_NAME="$1"
ZONE="$2"
ZIP_FILE="$3"
BASENAME=$(basename "$ZIP_FILE")  # Extract only the filename

echo "📂 Transferring ${BASENAME} to remote instance images/ folder..."
gcloud compute scp "$ZIP_FILE" "iankonradjohnson@${INSTANCE_NAME}:images/${BASENAME}" --zone="${ZONE}"

echo "✅ ZIP file uploaded successfully!"
