#!/bin/bash

# Color codes
YELLOW='\033[1;33m' # Bold Yellow
BOLD='\033[1m'      # General Bold
CYAN='\033[1;36m'   # Bold Cyan
GREEN='\033[1;32m'  # Bold Green (নতুন যোগ করা হয়েছে)
NC='\033[0m'        # No Color

print_header() {
    clear # Clear screen to ensure header is always at the top
    echo -e "${YELLOW}${BOLD}=====================================================${NC}"
    echo -e "${YELLOW}${BOLD} # # # # # # 🟡 BENGAL AIRDROP 🟡 # # # # # #${NC}"
    echo -e "${YELLOW}${BOLD}=====================================================${NC}"
    echo -e "${CYAN}👉 Join TG Channel: https://t.me/BENGAL_AIR ${NC}"
    echo -e ""
}

stop_node() {
    echo -e "${GREEN}========== STEP 1: STOP YOUR NODE ==========${NC}"
    sudo systemctl stop zgs
    echo -e "${GREEN}Node stopped successfully.${NC}"
}

rpc_change() {
    echo -e "${GREEN}========== STEP 2: RPC CHANGE ==========${NC}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/rpc_change.sh)
    echo -e "${GREEN}RPC change completed.${NC}"
}

key_change() {
    echo -e "${GREEN}========== STEP 3: PVT KEY CHANGE ==========${NC}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/key_change.sh)
    echo -e "${GREEN}Private key change completed.${NC}"
}

start_service() {
    echo -e "${GREEN}========== STEP 4: START SERVICE ==========${NC}"
    sudo systemctl daemon-reload
    sudo systemctl enable zgs
    sudo systemctl start zgs
    echo -e "${GREEN}Service reloaded, enabled, and started.${NC}"
}

block_check() {
    echo -e "${GREEN}========== STEP 5: BLOCK CHECK ==========${NC}"
    bash <(curl -s https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/logs.sh)
    echo -e "${GREEN}Block check complete.${NC}"
}

while true; do
    print_header # Call header function to clear and print
    echo -e "${YELLOW}${BOLD}╔═══════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}${BOLD}║      🔵 0G STORAGE NODE MENU 🔵      ║${NC}"
    echo -e "${YELLOW}${BOLD}╠═══════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}1️⃣ ${NC}${BOLD} Node Install (No Fast Sync)   ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}2️⃣ ${NC}${BOLD} Apply Fast Sync Only          ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}3️⃣ ${NC}${BOLD} STOP YOUR NODE                ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}4️⃣ ${NC}${BOLD} RPC CHANGE                    ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}5️⃣ ${NC}${BOLD} PVT KEY CHANGE                ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}6️⃣ ${NC}${BOLD} START SERVICE                 ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}7️⃣ ${NC}${BOLD} BLOCK CHECK                   ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}║ ${CYAN}0️⃣ ${NC}${BOLD} Exit                          ${YELLOW}${BOLD}║${NC}"
    echo -e "${YELLOW}${BOLD}╚═══════════════════════════════════════╝${NC}"
    echo -e "" # Add a new line for better spacing
    read -p "Enter your choice [0-7]: " choice

    case $choice in
        1)
            echo -e "${GREEN}🚀 Starting Node Install (without Fast Sync)...${NC}"
            bash -c '
            set -e
            cd "$HOME"

            if [ -d "0g-storage-node" ]; then
                echo -e "${GREEN}✅ 0g-storage-node already installed.${NC}"
                exit 0
            fi

            echo -e "${GREEN}🚀 Starting 0G Storage Node Auto Installer...${NC}"
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt install -y curl iptables build-essential git wget lz4 jq make cmake gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen ufw xdotool

            if ! command -v rustc &> /dev/null; then
                echo -e "${GREEN}🔧 Installing Rust...${NC}"
                curl https://sh.rustup.rs -sSf | sh -s -- -y
                source "$HOME/.cargo/env"
            fi

            if ! command -v go &> /dev/null; then
                echo -e "${GREEN}🔧 Installing Go...${NC}"
                wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
                sudo rm -rf /usr/local/go
                sudo tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
                rm go1.24.3.linux-amd64.tar.gz
                echo "export PATH=$PATH:/usr/local/go/bin" >> "$HOME/.bashrc"
                source "$HOME/.bashrc"
            fi

            echo -e "${GREEN}📁 Cloning 0g-storage-node repository...${NC}"
            git clone https://github.com/0glabs/0g-storage-node.git
            cd 0g-storage-node
            git checkout v1.1.0
            git submodule update --init

            sudo apt install -y protobuf-compiler
            echo -e "${GREEN}⚙️ Building node...${NC}"
            cargo build --release

            rm -f "$HOME/0g-storage-node/run/config.toml"
            mkdir -p "$HOME/0g-storage-node/run"
            curl -o "$HOME/0g-storage-node/run/config.toml" https://raw.githubusercontent.com/HustleAirdrops/0G-Storage-Node/main/config.toml

            read -e -p "🔐 Enter PRIVATE KEY (with or without 0x): " k; k=${k#0x}; printf "\033[A\033[K"; [[ ${#k} -eq 64 && "$k" =~ ^[0-9a-fA-F]+$ ]] && sed -i "s|miner_key = .*|miner_key = \"$k\"|" "$HOME/0g-storage-node/run/config.toml" && echo -e "${GREEN}✅ Private key updated: ${k:0:4}****${k: -4}${NC}" || echo -e "${YELLOW}❌ Invalid key!${NC}"
            read -e -p "🌐 Enter blockchain_rpc_endpoint URL: " r; echo; if [[ -z "$r" ]]; then echo -e "${YELLOW}❌ URL cannot be empty.${NC}"; else sed -i "s|blockchain_rpc_endpoint = .*|blockchain_rpc_endpoint = \"$r\"|" "$HOME/0g-storage-node/run/config.toml" && echo -e "${GREEN}✅ RPC updated to: $r${NC}"; fi

            sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=ZGS Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

            sudo systemctl daemon-reload
            sudo systemctl enable zgs

            echo -e "${GREEN}🚀 Node installed successfully! Please apply fast sync manually if needed using Option 2.${NC}"
            echo -e "${CYAN}👉 To start node manually: sudo systemctl start zgs${NC}"
            echo -e "${CYAN}📄 To view logs: tail -f \$HOME/0g-storage-node/run/log/zgs.log.\$(TZ=UTC date +%Y-%m-%d)${NC}"
            '
            read -p "Press Enter to continue..." ;;

        2)
            echo -e "${GREEN}🔄 Applying Fast Sync Only (Mega Download)...${NC}"
            bash -c '
            echo -e "${GREEN}========== STEP 1: STOP NODE ==========${NC}"
            sudo systemctl stop zgs

            echo -e "${GREEN}========== STEP 2: INSTALL MEGATOOLS IF NOT PRESENT ==========${NC}"
            if ! command -v megadl &> /dev/null; then
                echo -e "${GREEN}📦 Installing megatools...${NC}"
                sudo apt-get update
                sudo apt-get install -y megatools
            fi

            echo -e "${GREEN}========== STEP 3: CLEANING OLD DB FOLDER ==========${NC}"
            rm -rf $HOME/0g-storage-node/run/db/
            mkdir -p $HOME/0g-storage-node/run/db/
            cd $HOME/0g-storage-node/run/db/

            echo -e "${GREEN}========== STEP 4: DOWNLOAD FROM MEGA ==========${NC}"
            megadl "https://mega.nz/file/eJ0RXY4Q#5RDf_7Y7HW8eUKzQvqACCkynNAOrtXDfp4Z0uYCWnsg"

            echo -e "${GREEN}========== STEP 5: EXTRACTING flow_db.tar.gz ==========${NC}"
            tar -xzvf flow_db.tar.gz

            echo -e "${GREEN}========== STEP 6: STARTING NODE AGAIN ==========${NC}"
            sudo systemctl restart zgs

            echo -e "${GREEN}✅ Fast Sync Completed & Node Restarted Successfully!${NC}"
            '
            read -p "Press Enter to continue..." ;;

        3) stop_node; read -p "Press Enter to continue..." ;;
        4) rpc_change; read -p "Press Enter to continue..." ;;
        5) key_change; read -p "Press Enter to continue..." ;;
        6) start_service; read -p "Press Enter to continue..." ;;
        7) block_check; read -p "Press Enter to continue..." ;;
        0)
            echo "Exiting... Bye!"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Try again.${NC}"
            sleep 1
            ;;
    esac

done
