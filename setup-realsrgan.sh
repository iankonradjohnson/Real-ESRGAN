#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "✅ Installing Python3, pip, and OpenGL dependencies..."
apt install -y python3 python3-pip python3-venv libgl1

# Check CUDA installation
if command -v nvcc &> /dev/null; then
    echo "✅ CUDA is installed: $(nvcc --version | grep release)"
else
    echo "❌ CUDA not found. Installing CUDA 11.3..."
    apt install -y nvidia-cuda-toolkit
    export PATH=/usr/local/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
fi

# Fix potential libcublas.so.11 error
if [ -f "/usr/lib/x86_64-linux-gnu/libcublas.so.11" ]; then
    echo "🔧 Fixing libcublas.so.11..."
    ln -sf /usr/lib/x86_64-linux-gnu/libcublas.so.11 /usr/local/cuda/lib64/libcublas.so.11
    ldconfig
fi

# Check if the Real-ESRGAN repository already exists
if [ -d "Real-ESRGAN" ]; then
    echo "🛠 Real-ESRGAN directory already exists. Pulling latest changes..."
    cd Real-ESRGAN
    git pull
else
    echo "🛠 Cloning the Real-ESRGAN repository..."
    git clone https://github.com/xinntao/Real-ESRGAN.git
    cd Real-ESRGAN
fi

echo "🌍 Creating a virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install basicsr facexlib gfpgan
pip install -r requirements.txt

# Install PyTorch for CUDA 11.3
echo "🔍 Installing PyTorch for CUDA 11.3..."
pip uninstall -y torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu113

# Verify PyTorch Uses CUDA
if python -c "import torch; print(torch.cuda.is_available())" | grep -q "True"; then
    echo "✅ PyTorch is using CUDA."
else
    echo "❌ PyTorch is NOT using CUDA. Check CUDA installation."
    exit 1
fi

echo "⚙️ Running setup..."
python setup.py develop

echo "🛠 Fixing torchvision import issue in basicsr..."
DEGRADATIONS_FILE="venv/lib/python3.11/site-packages/basicsr/data/degradations.py"

if [ -f "$DEGRADATIONS_FILE" ]; then
    if grep -q "from torchvision.transforms.functional_tensor import rgb_to_grayscale" "$DEGRADATIONS_FILE"; then
        sed -i "s/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/g" "$DEGRADATIONS_FILE"
        echo "✅ Fixed torchvision import issue in $DEGRADATIONS_FILE"
    else
        echo "✅ No fix needed for torchvision import in $DEGRADATIONS_FILE"
    fi
else
    echo "⚠️ Warning: $DEGRADATIONS_FILE not found. The script may need a manual fix."
fi

echo "✅ Installation and fixes complete! To activate the environment, run:"
echo "   source Real-ESRGAN/venv/bin/activate"

apt install -y unzip
