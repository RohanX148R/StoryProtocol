#!/bin/bash

# Update and install dependencies
sudo apt update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y

# Set up Go environment
mkdir -p $HOME/go/bin
echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile

# Download and install Story-Geth
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xzvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
sudo cp geth-linux-amd64-0.9.2-ea9f0d2/geth $HOME/go/bin/story-geth

# Verify Story-Geth installation
story-geth version

# Download and install Story
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar -xzvf story-linux-amd64-0.9.11-2a25df1.tar.gz
sudo cp story-linux-amd64-0.9.11-2a25df1/story $HOME/go/bin/story

# Verify Story installation
story version

# Prompt user for node name (moniker)
read -p "Enter the moniker (node name): " MONIKER

# Initialize Story config with user-provided moniker
story init --network iliad --moniker "$MONIKER"

# Create Story-Geth service
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Create Story service
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload services and start Story-Geth and Story
sudo systemctl daemon-reload
sudo systemctl start story-geth
sudo systemctl enable story-geth
sudo systemctl start story
sudo systemctl enable story

# Display status of Story-Geth and Story services
sudo systemctl status story-geth
sudo systemctl status story

