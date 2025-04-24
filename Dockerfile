# build with
# docker buildx build --platform linux/amd64 --push -t iankonradjohnson/realesrgan-runpod:latest .

FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

WORKDIR /workspace
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git unzip wget ffmpeg libgl1 python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace/data/in \
    && mkdir -p /workspace/data/out

RUN set -eux && \
    git clone https://github.com/xinntao/Real-ESRGAN.git && \
    cd Real-ESRGAN && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install basicsr facexlib gfpgan && \
    python setup.py develop

WORKDIR /workspace/data

# Optionally add your weights
COPY ./weights /workspace/Real-ESRGAN/weights

# Use sleep to keep container alive
CMD ["sleep", "infinity"]

