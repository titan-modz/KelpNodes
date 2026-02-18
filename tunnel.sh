#!/bin/bash
# ═══════════════════════════════════════════════
#  KelpNodes Tunnel - Auto Installer
# ═══════════════════════════════════════════════

set -e

REPO_URL="https://github.com/titan-modz/tunnel"
INSTALL_PATH="/usr/local/bin/tunnel"

GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
BOLD="\e[1m"
RESET="\e[0m"

echo -e "${CYAN}${BOLD}⚡ Installing KelpNodes Tunnel...${RESET}"
echo

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✗ Please run as root (use sudo)${RESET}"
    exit 1
fi

echo -e "${YELLOW}Updating packages...${RESET}"
apt update -y

echo -e "${YELLOW}Installing dependencies (git, sshpass)...${RESET}"
apt install -y git sshpass

echo -e "${YELLOW}Cloning repository...${RESET}"
rm -rf tunnel 2>/dev/null
git clone "$REPO_URL"

if [ ! -f tunnel/tunnel ]; then
    echo -e "${RED}✗ Tunnel file not found in repository${RESET}"
    exit 1
fi

echo -e "${YELLOW}Setting permissions...${RESET}"
chmod +x tunnel/tunnel

echo -e "${YELLOW}Installing to ${INSTALL_PATH}...${RESET}"
mv tunnel/tunnel "$INSTALL_PATH"

echo -e "${YELLOW}Cleaning up...${RESET}"
rm -rf tunnel

echo
echo -e "${GREEN}${BOLD}✓ Installed successfully!${RESET}"
echo
echo -e "Run it using:"
echo -e "${CYAN}   tunnel <port>${RESET}"
echo
