#!/bin/bash

# Update and install required packages
apt update
apt install -y xrdp xfce4 xfce4-goodies tightvncserver curl

# Enable and start xrdp service
systemctl enable xrdp
systemctl start xrdp

# Configure xfce4 as the default session for xrdp
echo xfce4-session >~/.xsession

# Allow RDP port through the firewall
ufw allow 3389/tcp

# Download and install Ngrok
NGROK_ZIP="ngrok-stable-linux-amd64.zip"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list
apt update
apt install ngrok

# Set up Ngrok authtoken
NGROK_AUTH_TOKEN="2NGLnxhxBzQAKSYKvcM4co8wN2B_P3RN1ixz3hhG74Yz4Sh9"
ngrok authtoken $NGROK_AUTH_TOKEN

# Create a systemd service for Ngrok
tee /etc/systemd/system/ngrok.service <<EOF
[Unit]
Description=Ngrok
After=network.target

[Service]
ExecStart=/usr/bin/ngrok tcp 3389
Restart=on-failure
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Ngrok service
systemctl enable ngrok
systemctl start ngrok

# Provide the Ngrok URL
echo "Setup complete. Use 'journalctl -u ngrok -f' to find your RDP address."
