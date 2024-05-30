#!/bin/bash

# Display ASCII art
echo "             _       "
echo "            | |      "
echo "  _ __    __| | ___  "
echo " | '_ \  / _' |/ __| "
echo " | | | || (_| |\__ \ "
echo " |_| |_| \__,_||___/ "
echo "                     "


# Color codes
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[1;31m'
BLINK='\033[5m'
RESET='\033[0m'

# Function to display PHP, NVM, Node, and NPM versions
view_versions() {
  echo -e "${YELLOW}Checking versions...${RESET}"
  
  # Check PHP version
  if command -v php &> /dev/null; then
    php_version=$(php -v | head -n 1)
    echo -e "PHP: ${BLUE}$php_version${RESET}"
  else
    echo -e "${RED}PHP is not installed.${RESET}"
  fi
  
  # Check NVM version
  if [ -d "$HOME/.nvm" ]; then
    source "$HOME/.nvm/nvm.sh"
    nvm_version=$(nvm --version)
    echo -e "NVM: ${BLUE}$nvm_version${RESET}"
  else
    echo -e "${RED}NVM is not installed.${RESET}"
  fi
  
  # Check Node version
  if command -v node &> /dev/null; then
    node_version=$(node -v)
    echo -e "Node: ${BLUE}$node_version${RESET}"
  else
    echo -e "${RED}Node is not installed.${RESET}"
  fi
  
  # Check NPM version
  if command -v npm &> /dev/null; then
    npm_version=$(npm -v)
    echo -e "NPM: ${BLUE}$npm_version${RESET}"
  else
    echo -e "${RED}NPM is not installed.${RESET}"
  fi
}

# Function to install NVM
install_nvm() {
  echo -e "${YELLOW}Installing NVM...${RESET}"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  echo -e "${YELLOW}NVM installed successfully. Please restart your terminal or run 'source ~/.bashrc' to start using NVM.${RESET}"
}

# Function to install Node LTS
install_node_lts() {
  echo -e "${YELLOW}Installing Node LTS...${RESET}"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  echo -e "${YELLOW}Node LTS installed successfully.${RESET}"
}

# Function to remove Node.js
remove_node() {
  echo -e "${YELLOW}Removing Node.js...${RESET}"
  
  # Remove Node.js installed via package manager
  if command -v node &> /dev/null; then
    sudo apt-get remove --purge -y nodejs
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    echo -e "${YELLOW}Node.js removed successfully from package manager.${RESET}"
  else
    echo -e "${RED}Node.js not found in package manager.${RESET}"
  fi
  
  # Remove Node.js installed via NVM
  if [ -d "$HOME/.nvm" ]; then
    source "$HOME/.nvm/nvm.sh"
    nvm deactivate
    nvm uninstall node
    echo -e "${YELLOW}Node.js removed successfully from NVM.${RESET}"
  fi
  
  # Check if Node.js is still installed
  if command -v node &> /dev/null; then
    echo -e "${RED}Node.js is still installed. Please check for other installations.${RESET}"
  else
    echo -e "${YELLOW}Node.js is not installed.${RESET}"
  fi
}

# Function to remove NVM 
remove_nvm_() {
  echo -e "${YELLOW}Removing NVM ...${RESET}"
  
  # Remove the NVM directory
  rm -rf "$HOME/.nvm"
  
  # Remove NVM source line from profile files
  sed -i '/NVM_DIR/d' "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"
  
  echo -e "${YELLOW}NVM removed. Please restart your terminal or source your profile files to apply changes.${RESET}"
}

# Main menu function
main_menu() {
  while true; do
    echo -e "${BLINK}${YELLOW}Select an option:${RESET}"
    echo -e "${YELLOW}1. View PHP, NVM, Node, and NPM versions${RESET}"
    echo -e "${YELLOW}2. Install NVM${RESET}"
    echo -e "${YELLOW}3. Install Node LTS${RESET}"
    echo -e "${YELLOW}4. Remove Node.js${RESET}"
    echo -e "${YELLOW}5. Remove NVM ${RESET}"
    echo -e "${YELLOW}6. Exit${RESET}"
    read -p "Enter your choice [1-6]: " choice

    case $choice in
      1)
        view_versions
        ;;
      2)
        install_nvm
        ;;
      3)
        install_node_lts
        ;;
      4)
        remove_node
        ;;
      5)
        remove_nvm_
        ;;
      6)
        echo -e "${YELLOW}Exiting...${RESET}"
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid option selected.${RESET}"
        ;;
    esac

    # Ask user whether to exit or return to menu
    echo ""
    read -p "Task completed. Do you want to exit? (y/n): " exit_choice
    if [[ $exit_choice == "y" || $exit_choice == "Y" ]]; then
      echo -e "${YELLOW}Exiting...${RESET}"
      exit 0
    else
      echo -e "${YELLOW}Returning to main menu...${RESET}"
      echo ""
    fi
  done
}

# Start the main menu
main_menu
