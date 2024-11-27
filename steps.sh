mkdir app
python3 -m venv app/env
source app/env/bin/activate
pip install -r requirements.txt

[Unit]
Description=flask app
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/app/
Environment="PATH=/home/ubuntu/app/env/bin"
ExecStart=/home/ubuntu/app/env/bin/python3 /home/ubuntu/app/app.py

[Install]
WantedBy=multi-user.target


sudo vi flaskapp.service
sudo systemctl daemon-reload
sudo systemctl enable flaskapp.service
sudo systemctl start flaskapp.service