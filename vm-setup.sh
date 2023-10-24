#!/bin/bash

# Specify your instance name, project ID, and zone
INSTANCE_NAME=instance-template-1
PROJECT_ID=abacus-399220
ZONE=europe-west4-a  # e.g., us-central1-a

# Specify the name of your training data file
TRAINING_DATA_FILENAME=training-data.zip

# Use gcloud to SSH into the GCP instance and execute the commands for setting up
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" << 'ENDGCLOUD'
    sudo apt update
    sudo apt install -y git wget unzip libgl1-mesa-glx

    # Check if Miniconda is already installed
    if [[ ! -d "$HOME/miniconda3" ]]; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        sha256sum Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b
    fi

    export PATH="$HOME/miniconda3/bin:$PATH"
    conda init bash

ENDGCLOUD

# Use gcloud to SSH into the GCP instance again and execute the commands for Real-ESRGAN setup
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" << 'ENDGCLOUD'
    if [[ ! -d "Real-ESRGAN" ]]; then
        git clone https://github.com/xinntao/Real-ESRGAN.git
    fi

    cd Real-ESRGAN

    export PATH="$HOME/miniconda3/bin:$PATH"
    conda activate

    # Install required packages
    pip install basicsr facexlib gfpgan
    pip install -r requirements.txt
    python setup.py develop

    echo "Generating meta info"
    python scripts/generate_meta_info.py --input $HOME/Real-ESRGAN/training-data/ --root $HOME/Real-ESRGAN/training-data/ --meta_info $HOME/Real-ESRGAN/training-data/train-meta-info.txt
ENDGCLOUD

echo "All tasks completed!"
