#!/bin/bash

mkdir -p /home/ubuntu/app

cp requirements.txt /home/ubuntu/app/ 
cp flaskapp.service /etc/systemd/system/flaskapp.service

cd /home/ubuntu/app

python3 -m venv env
source env/bin/activate

pip install -r requirements.txt

sudo systemctl daemon-reload
sudo systemctl enable flaskapp.service
sudo systemctl start flaskapp.service