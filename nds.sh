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

# Function to check if script is globally set
check_global() {
  if [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
    if [ -f "/usr/local/bin/nds" ]; then
      return 0
    fi
  fi

  echo -e "${RED}Script is not globally accessible. Setting it globally now...${RESET}"
  sudo cp "$0" /usr/local/bin/nds
  sudo chmod +x /usr/local/bin/nds
  echo -e "${YELLOW}Script is now globally accessible as 'nds'.${RESET}"
}
check_global

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

  echo -e "${YELLOW}Setting up NVM globally...${RESET}"
  mkdir -p /usr/local/nvm
  tee /usr/local/bin/nvm.sh << 'EOF'
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF

  tee /etc/profile.d/nvm.sh << 'EOF'
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF

  ln -sf /usr/local/nvm/nvm.sh /usr/local/bin/nvm

  echo -e "${YELLOW}NVM installed successfully. Please restart your terminal or run 'source /etc/profile.d/nvm.sh' to start using NVM.${RESET}"
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
remove_nvm() {
  echo -e "${YELLOW}Removing NVM...${RESET}"
  
  # Remove the NVM directory
  rm -rf "$HOME/.nvm"
  
  # Remove NVM source line from profile files
  sed -i '/NVM_DIR/d' "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"
  
  echo -e "${YELLOW}NVM removed. Please restart your terminal or source your profile files to apply changes.${RESET}"
}

# Function to change PHP version
change_php_version() {
  echo -e "${YELLOW}Changing PHP version...${RESET}"
  sudo update-alternatives --config php
  sudo systemctl restart apache2
}

# Function to install PHP version
install_php_version() {
  version=$1
  echo -e "${YELLOW}Installing PHP ${version}...${RESET}"
  sudo apt update
  sudo add-apt-repository ppa:ondrej/php -y
  sudo apt install -y php${version} php${version}-cli php${version}-fpm php${version}-mysql php${version}-curl php${version}-gd php${version}-mbstring php${version}-xml php${version}-zip libapache2-mod-php${version}
  sudo apt update
  echo -e "${YELLOW}PHP ${version} installed successfully.${RESET}"
}

# Function to remove PHP version
remove_php_version() {
  version=$1
  echo -e "${YELLOW}Removing PHP ${version}...${RESET}"
  sudo apt remove --purge -y php${version} php${version}-cli php${version}-fpm php${version}-mysql php${version}-curl php${version}-gd php${version}-mbstring php${version}-xml php${version}-zip libapache2-mod-php${version}
  sudo apt autoremove -y
  sudo apt autoclean
  echo -e "${YELLOW}PHP ${version} removed successfully.${RESET}"
}

# Function to install Composer
install_composer() {
  echo -e "${YELLOW}Installing Composer...${RESET}"
  EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
      >&2 echo 'ERROR: Invalid installer signature'
      rm composer-setup.php
      exit 1
  fi

  php composer-setup.php --quiet
  RESULT=$?
  rm composer-setup.php
  sudo mv composer.phar /usr/local/bin/composer
  echo -e "${YELLOW}Composer installed successfully.${RESET}"
  return $RESULT
}

# Function to remove Composer
remove_composer() {
  echo -e "${YELLOW}Removing Composer...${RESET}"
  sudo rm /usr/local/bin/composer
  echo -e "${YELLOW}Composer removed successfully.${RESET}"
}

# Function to show PHP menu
php_menu() {
  while true; do
    echo -e "${BLUE} ===========|  PHP Menu  |=========== ${RESET}"
    echo -e "${YELLOW}1. Change PHP version${RESET}"
    echo -e "${YELLOW}2. Install PHP version${RESET}"
    echo -e "${YELLOW}3. Remove PHP version${RESET}"
    echo -e "${YELLOW}0. Back to main menu${RESET}"
    read -p "Enter your choice [0-3]: " choice

    case $choice in
      1)
        change_php_version
        ;;
      2)
        echo -e "${YELLOW}Select PHP version to install: 8.1, 8.2, 8.3${RESET}"
        read -p "Enter PHP version (e.g., 8.1): " version
        install_php_version $version
        ;;
      3)
        echo -e "${YELLOW}Select PHP version to remove: 8.1, 8.2, 8.3${RESET}"
        read -p "Enter PHP version (e.g., 8.1): " version
        remove_php_version $version
        ;;
      0)
        break
        ;;
      *)
        echo -e "${RED}Invalid option selected.${RESET}"
        ;;
    esac
  done
}

# Function to show Node menu
node_menu() {
  while true; do
    echo -e "${BLUE} ===========|  Node Menu  |=========== ${RESET}"
    echo -e "${YELLOW}1. Install Node LTS${RESET}"
    echo -e "${YELLOW}2. Remove Node.js${RESET}"
    echo -e "${YELLOW}3. Install NVM${RESET}"
    echo -e "${YELLOW}4. Remove NVM${RESET}"
    echo -e "${YELLOW}0. Back to main menu${RESET}"
    read -p "Enter your choice [0-4]: " choice

    case $choice in
      1)
        install_node_lts
        ;;
      2)
        remove_node
        ;;
      3)
        install_nvm
        ;;
      4)
        remove_nvm
        ;;
      0)
        break
        ;;
      *)
        echo -e "${RED}Invalid option selected.${RESET}"
        ;;
    esac
  done
}

# Function to show Composer menu
composer_menu() {
  while true; do
    echo -e "${BLUE} ===========|  Composer Menu  |=========== ${RESET}"
    echo -e "${YELLOW}1. Install Composer${RESET}"
    echo -e "${YELLOW}2. Remove Composer${RESET}"
    echo -e "${YELLOW}0. Back to main menu${RESET}"
    read -p "Enter your choice [0-2]: " choice

    case $choice in
      1)
        install_composer
        ;;
      2)
        remove_composer
        ;;
      0)
        break
        ;;
      *)
        echo -e "${RED}Invalid option selected.${RESET}"
        ;;
    esac
  done
}

# Main menu
while true; do
  echo -e "${BLUE} ===========|  Main Menu  |=========== ${RESET}"
  echo -e "${YELLOW}1. PHP Menu${RESET}"
  echo -e "${YELLOW}2. Node Menu${RESET}"
  echo -e "${YELLOW}3. Composer Menu${RESET}"
  echo -e "${YELLOW}4. Show all versions${RESET}"
  echo -e "${YELLOW}0. Exit${RESET}"
  read -p "Enter your choice [0-4]: " choice

  case $choice in
    1)
      php_menu
      ;;
    2)
      node_menu
      ;;
    3)
      composer_menu
      ;;
    4)
      view_versions
      ;;
    0)
      echo -e "${YELLOW}Exiting...${RESET}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option selected.${RESET}"
      ;;
  esac
done