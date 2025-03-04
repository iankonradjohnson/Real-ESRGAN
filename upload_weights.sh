#!/bin/bash

# Exit script on error
set -e

# Usage function
usage() {
    echo "Usage: $0 <instance-name> <zone>"
    echo "Example: $0 my-instance us-east1-c"
    exit 1
}

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Assign arguments to variables
INSTANCE_NAME="$1"
ZONE="$2"

echo "📂 Transferring weights/RealESRGAN_x4plus.pth..."
gcloud compute scp weights/RealESRGAN_x4plus.pth "iankonradjohnson@${INSTANCE_NAME}:Real-ESRGAN/weights/RealESRGAN_x4plus.pth" --zone="${ZONE}"

echo "📂 Transferring weights/net_g_1000000.pth..."
gcloud compute scp weights/net_g_1000000.pth "iankonradjohnson@${INSTANCE_NAME}:Real-ESRGAN/weights/net_g_1000000.pth" --zone="${ZONE}"

echo "✅ Weights files uploaded successfully!"
