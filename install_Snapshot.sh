#!/bin/bash

# Update and install necessary tools
echo "Installing required tools..."
sudo apt-get update
sudo apt-get install wget lz4 aria2 pv -y

# Stop node services
echo "Stopping Story and Story-Geth services..."
sudo systemctl stop story
sudo systemctl stop story-geth

# Download Story snapshot
echo "Downloading Story snapshot..."
cd $HOME
rm -f Story_snapshot.lz4
wget --show-progress https://josephtran.co/Story_snapshot.lz4

# Download Geth snapshot
echo "Downloading Geth snapshot..."
rm -f Geth_snapshot.lz4
wget --show-progress https://josephtran.co/Geth_snapshot.lz4

# Backup priv_validator_state.json
echo "Backing up priv_validator_state.json..."
cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup

# Remove old data
echo "Removing old data..."
rm -rf ~/.story/story/data
rm -rf ~/.story/geth/iliad/geth/chaindata

# Decompress Story snapshot
echo "Decompressing Story snapshot..."
sudo mkdir -p /root/.story/story/data
lz4 -d -c Story_snapshot.lz4 | pv | sudo tar xv -C ~/.story/story/ > /dev/null

# Decompress Geth snapshot
echo "Decompressing Geth snapshot..."
sudo mkdir -p /root/.story/geth/iliad/geth/chaindata
lz4 -d -c Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/iliad/geth/ > /dev/null

# Move priv_validator_state.json back
echo "Restoring priv_validator_state.json..."
cp ~/.story/priv_validator_state.json.backup ~/.story/story/data/priv_validator_state.json

# Restart node services
echo "Restarting Story and Story-Geth services..."
sudo systemctl start story
sudo systemctl start story-geth

echo "Snapshot installation completed!"

