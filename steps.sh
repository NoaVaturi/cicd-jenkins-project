#!/bin/bash

mkdir -p app
cd app

python3 -m venv env
source env/bin/activate

pip install -r ../requirements.txt
sudo cp ../flaskapp.service /etc/systemd/system/flaskapp.service

sudo systemctl daemon-reload
sudo systemctl enable flaskapp.service
sudo systemctl start flaskapp.service