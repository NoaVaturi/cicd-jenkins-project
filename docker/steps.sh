#!/bin/bash


# Print the paths of Python and pip to verify the virtual environment is activated
which python3
which pip

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

# Upgrade pip to the latest version
pip install --upgrade pip

# Install dependencies from requirements.txt
pip install -r requirements.txt

