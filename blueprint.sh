#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to print status messages
print_status() {
    echo -e "${YELLOW}⏳ $1...${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${MAGENTA}⚠️  $1${NC}"
}

# Function to check if command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
        return 0
    else
        print_error "$2"
        return 1
    fi
}

# Function to animate progress
animate_progress() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Welcome animation
welcome_animation() {
    clear
    sleep 2
}

# Function: Install (Fresh Setup)
install_kelpnodes() {
    # ================= VARIABLES =================
    export PTERODACTYL_DIRECTORY=/var/www/pterodactyl

    # ================= START =================
    print_header "INSTALLING KELPNODES"
    print_status "Installing base dependencies (curl, wget, unzip)"
    apt update -y && apt install -y curl wget unzip ca-certificates git gnupg zip || print_error "Deps install failed"
    print_success "Base dependencies installed"

    print_status "Switching to Pterodactyl directory"
    cd "$PTERODACTYL_DIRECTORY" || print_error "Pterodactyl directory not found"

    print_status "Downloading Blueprint Framework (latest)"
    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | grep 'release.zip' | cut -d '"' -f 4)" -O "$PTERODACTYL_DIRECTORY/release.zip"
    unzip -o release.zip || print_error "Unzip failed"
    print_success "Blueprint downloaded & extracted"

    # ================= NODE.JS =================
    print_status "Installing Node.js 20.x"
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list

    apt update -y && apt install -y nodejs || print_error "Node.js install failed"
    print_success "Node.js installed"

    # ================= YARN & DEPENDENCIES =================
    print_status "Installing Yarn & Node dependencies"
    npm i -g yarn || print_error "Yarn install failed"
    yarn install || print_error "Yarn dependencies failed"
    print_success "Node dependencies ready"

    # ================= BLUEPRINT CONFIG =================
    print_status "Creating .blueprintrc configuration"
    cat <<EOF > "$PTERODACTYL_DIRECTORY/.blueprintrc"
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF
    print_success ".blueprintrc created"

    # ================= PERMISSIONS =================
    print_status "Setting permissions"
    chmod +x "$PTERODACTYL_DIRECTORY/blueprint.sh" || print_error "Permission failed"
    chown -R www-data:www-data "$PTERODACTYL_DIRECTORY"
    print_success "Permissions fixed"

    # ================= RUN BLUEPRINT =================
    print_status "Launching Blueprint installer"
    bash "$PTERODACTYL_DIRECTORY/blueprint.sh"

    # ================= DONE =================
    echo -e "\n${GREEN}🎉 KELPNODES UI Installation Complete!${NC}"
    echo -e "${YELLOW}Panel is ready… enjoy your new theme! 😏${NC}"
}

# Function: Reinstall (Rerun Only)
reinstall_kelpnodes() {
    print_header "REINSTALLING KELPNODES"
    print_status "Starting reinstallation"
    blueprint -rerun-install > /dev/null 2>&1 &
    animate_progress $! "Reinstalling"
    check_success "Reinstallation completed" "Reinstallation failed"
}

# Function: Update KELPNODES
update_kelpnodes() {
    print_header "UPDATING KELPNODES"
    print_status "Starting update"
    blueprint -upgrade > /dev/null 2>&1 &
    animate_progress $! "Updating"
    check_success "Update completed" "Update failed"
}

# Function to display the main menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}           🔧 BLUEPRINT INSTALLER               ${NC}"
    echo -e "${CYAN}              KELPNODES HOSTING                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "${WHITE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                📋 MAIN MENU                   ║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║   ${GREEN}1)${NC} ${CYAN}Fresh Install${NC}                         ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}2)${NC} ${CYAN}Reinstall (Rerun Only)${NC}                ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}3)${NC} ${CYAN}Update KELPNODES Hosting${NC}               ${WHITE}║${NC}"
    echo -e "${WHITE}║   ${GREEN}0)${NC} ${RED}Exit${NC}                               ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📝 Select an option [0-3]: ${NC}"
}

# Main execution
welcome_animation

while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) install_kelpnodes ;;
        2) reinstall_kelpnodes ;;
        3) update_kelpnodes ;;
        0) 
            echo -e "${GREEN}Exiting Blueprint Installer...${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}           Thank you for using our tools!       ${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            sleep 2
            exit 0 
            ;;
        *) 
            print_error "Invalid option! Please choose between 0-3"
            sleep 2
            ;;
    esac
    
    echo -e ""
    read -p "$(echo -e "${YELLOW}Press Enter to continue...${NC}")" -n 1
done
