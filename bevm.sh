#!/bin/bash

read -r -p "Enter wallet address: " MONIKER

CHAIN_ID="testnet0.1.1"
CHAIN_DENOM="bevm"
BINARY_NAME="bevmd"
GITHUB="https://github.com/Terasaz"
BINARY_VERSION_TAG="v0.1.1"

echo -e "Node moniker: ${CYAN}$NODE_MONIKER${NC}"
echo -e "Chain id:     ${CYAN}$CHAIN_ID${NC}"
echo -e "Chain demon:  ${CYAN}$CHAIN_DENOM${NC}"
echo -e "Binary version tag:  ${CYAN}$BINARY_VERSION_TAG${NC}"

sleep 1

echo -e "\e[1m\e[32m1. Updating packages and dependencies--> \e[0m" && sleep 1
sudo apt update && apt upgrade -y
sudo apt install curl  build-essential git wget jq make gcc tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev libgmp3-dev tar clang bsdmainutils ncdu unzip llvm libudev-dev protobuf-compiler -y
cd $HOME
sudo  wget -O bevm https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04
sudo chmod 744 bevm
sudo mv bevm /usr/bin/
sudo bevm --version
cd $HOME

sudo tee /etc/systemd/system/bevmd.service > /dev/null << EOF
[Unit]
Description=BTClayer2 Node
After=network-online.target
StartLimitIntervalSec=0
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=/usr/bin/bevm \
--chain=testnet --name="$MONIKER" \
--pruning=archive \
--telemetry-url "wss://telemetry.bevm.io/submit 0" \

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable bevmd
sudo systemctl restart bevmd

echo '=============== SETUP FINISHED ==================='
echo -e "Check logs:            ${CYAN}sudo journalctl -u $BINARY_NAME -f --no-hostname -o cat ${NC}"
echo -e "Check synchronization: ${CYAN}$BINARY_NAME status 2>&1 | jq .SyncInfo.catching_up${NC}"
echo -e "More commands:         ${CYAN}$GITHUB${NC}"
