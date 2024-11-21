#!/bin/bash

# Create the 'app' directory if it doesn't exist
mkdir -p /home/ubuntu/app

# Navigate into the app directory
cd /home/ubuntu/app

# Create a virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

# Activate the virtual environment
source .venv/bin/activate

# Install dependencies from requirements.txt
pip install -r requirements.txt

