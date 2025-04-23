#!/bin/bash

set -e

usage() {
    echo "Usage: $0"
    echo "Uploads RealESRGAN model weights using runpodctl."
    exit 1
}

# No arguments needed
if [ "$#" -ne 0 ]; then
    usage
fi

# Define files to upload
FILES=("weights/RealESRGAN_x4plus.pth" "weights/net_g_1000000.pth")

echo "📂 Sending weights using runpodctl..."

for FILE in "${FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        echo "❌ File not found: $FILE"
        exit 1
    fi

    CODE=$(runpodctl send "$FILE" | grep -oE '[0-9]{4}-[a-zA-Z]+-[a-zA-Z]+-[a-zA-Z]+')

    echo "📨 Sent: $FILE"
    echo "🖥️  On the pod, run:"
    echo "    runpodctl receive $CODE"
    echo "    mv $(basename "$FILE") /workspace/Real-ESRGAN/weights/"
    echo ""
done

echo "✅ All weight files prepared for transfer."
