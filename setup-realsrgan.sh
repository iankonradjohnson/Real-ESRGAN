#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🔄 Updating package lists..."
sudo apt update

echo "✅ Installing Python3, pip, and OpenGL dependencies..."
sudo apt install -y python3 python3-pip python3-venv libgl1

echo "🛠 Cloning the Real-ESRGAN repository..."
git clone https://github.com/xinntao/Real-ESRGAN.git
cd Real-ESRGAN

echo "🌍 Creating a virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install basicsr
pip install facexlib
pip install gfpgan
pip install -r requirements.txt

echo "⚙️ Running setup..."
python setup.py develop

echo "🛠 Fixing torchvision import issue in basicsr..."
DEGRADATIONS_FILE="venv/lib/python3.11/site-packages/basicsr/data/degradations.py"

if grep -q "from torchvision.transforms.functional_tensor import rgb_to_grayscale" "$DEGRADATIONS_FILE"; then
    sed -i "s/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/g" "$DEGRADATIONS_FILE"
    echo "✅ Fixed torchvision import issue in $DEGRADATIONS_FILE"
else
    echo "✅ No fix needed for torchvision import in $DEGRADATIONS_FILE"
fi

echo "✅ Installation and fixes complete! To activate the environment, run:"
echo "   source Real-ESRGAN/venv/bin/activate"
