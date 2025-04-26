# Build with:
# docker buildx build --platform linux/amd64 --push -t iankonradjohnson/realesrgan-runpod:latest --build-arg SERVER_DEPLOY_VERSION=1 .

FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

# Set working directory
WORKDIR /workspace
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install basic system dependencies
RUN apt-get update && apt-get install -y \
    git unzip wget ffmpeg libgl1 python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. Create workspace data folders
RUN mkdir -p /workspace/data/in /workspace/data/out

# Install torch + torchvision manually
RUN pip install --upgrade pip && \
    pip install torch==2.1.0 torchvision==0.16.1

# Now install your other packages
RUN pip install basicsr --no-deps
RUN pip install facexlib gfpgan
RUN pip install numpy opencv-python Pillow tqdm tenacity future pyyaml pytest requests pyexiv2 setuptools

RUN cd Real-ESRGAN && \
    python setup.py develop

# 4. Copy model weights
COPY ./weights /workspace/Real-ESRGAN/weights

# 5. Dummy ARG to force recaching server install if needed
ARG SERVER_DEPLOY_VERSION=1

# 6. Install Real-ESRGANServer (your Flask server)
RUN git clone https://github.com/iankonradjohnson/Real-ESRGANServer.git && \
    python3 -m venv /workspace/server-venv && \
    /workspace/server-venv/bin/pip install --upgrade pip && \
    # Install server-specific requirements
    /workspace/server-venv/bin/pip install --upgrade-strategy only-if-needed --prefer-binary -r /workspace/Real-ESRGANServer/requirements.txt

# 7. Set default command to run the Flask server
CMD ["/workspace/server-venv/bin/python", "/workspace/Real-ESRGANServer/runpod_server.py"]
