#!/bin/bash

# Exit on error
set -e

# Usage function
usage() {
    echo "Usage: $0 <zip-file>"
    echo "Example: $0 my-data.zip"
    exit 1
}

# Check for correct number of args
if [ "$#" -ne 1 ]; then
    usage
fi

ZIP_FILE="$1"

# Check file exists
if [ ! -f "$ZIP_FILE" ]; then
    echo "❌ File not found: $ZIP_FILE"
    exit 1
fi

BASENAME=$(basename "$ZIP_FILE")

echo "📂 Sending $BASENAME to RunPod using runpodctl..."

# Send and capture code
CODE=$(runpodctl send "$ZIP_FILE" | grep -oE '[0-9]{4}-[a-zA-Z]+-[a-zA-Z]+-[a-zA-Z]+' || true)

if [ -z "$CODE" ]; then
    echo "❌ Failed to get receive code. Check runpodctl output."
    exit 1
fi

echo ""
echo "🖥️  On your RunPod instance, run:"
echo "    runpodctl receive $CODE"
echo "    mkdir -p images && mv $BASENAME images/"
echo ""
echo "✅ Transfer code ready for retrieval."
