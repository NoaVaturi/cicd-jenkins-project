#!/bin/bash

# Create and activate a virtual environment for testing in Jenkins
mkdir -p app
cd app

python3 -m venv env  
source env/bin/activate  

# Install dependencies from requirements.txt for testing
pip install --cache-dir=/var/lib/jenkins/.cache/pip -r ../requirements.txt


# Deactivate the virtual environment after the tests are complete
deactivate
