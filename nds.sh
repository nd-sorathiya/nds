#!/bin/bash
## Author: Nikunj Sorathiya | Hardik Variya
# bash ~/nds.sh

# Display ASCII art
echo "                 _           "
echo "                | |          "
echo "    _ __      __| |   ___    "
echo "   | '_ \    / _' |  / __|   "
echo "   | | | |  | (_| |  \__ \   "
echo "   |_| |_|   \__,_|  |___/   "
echo "                             "

# Color codes
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[1;31m'
BLINK='\033[5m'
RESET='\033[0m'
ROOT_DIR="/var/www"
CONF_DIR="/etc/apache2/sites-available"

# Function to check if script is globally set
check_global() {
  if [[ ":$PATH:" == *":/usr/local/bin:"* ]]; then
    if [ -f "/usr/local/bin/nds" ]; then
      return 0
    fi
  fi

  echo -e "${RED}Script is not globally accessible. Setting it globally now...${RESET}"
  cp "$0" /usr/local/bin/nds
  chmod +x /usr/local/bin/nds
  echo -e "${YELLOW}Script is now globally accessible as 'nds'.${RESET}"
}

# Function to display PHP, NVM, Node, and NPM versions
view_versions() {
  echo -e "${YELLOW}Checking versions...${RESET}"

  # Check PHP version
  if command -v php &>/dev/null; then
    php_version=$(php -v | head -n 1)
    echo -e "PHP: ${BLUE}$php_version${RESET}"
  else
    echo -e "${RED}PHP is not installed.${RESET}"
  fi

  # Check Apache version
  if command -v apache2 &>/dev/null; then
    apache_version=$(apache2 -v | grep "Server version")
    echo -e "Apache: ${BLUE}$apache_version${RESET}"
  else
    echo -e "${RED}Apache is not installed.${RESET}"
  fi

  # Check MySQL version
  if command -v mysql &>/dev/null; then
    mysql_version=$(mysql --version)
    echo -e "MySQL: ${BLUE}$mysql_version${RESET}"
  else
    echo -e "${RED}MySQL is not installed.${RESET}"
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
  if command -v node &>/dev/null; then
    node_version=$(node -v)
    echo -e "Node: ${BLUE}$node_version${RESET}"
  else
    echo -e "${RED}Node is not installed.${RESET}"
  fi

  # Check NPM version
  if command -v npm &>/dev/null; then
    npm_version=$(npm -v)
    echo -e "NPM: ${BLUE}$npm_version${RESET}"
  else
    echo -e "${RED}NPM is not installed.${RESET}"
  fi

  # Check OS version
  os_version=$(lsb_release -d 2>/dev/null || echo "OS version not available")
  echo -e "OS: ${BLUE}$os_version${RESET}"
}



# Function to install NVM
install_nvm() {
  echo -e "${YELLOW}Installing NVM...${RESET}"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

  echo -e "${YELLOW}Setting up NVM globally...${RESET}"
  mkdir -p /usr/local/nvm
  tee /usr/local/bin/nvm.sh <<'EOF'
    export NVM_DIR="/usr/local/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF

  tee /etc/profile.d/nvm.sh <<'EOF'
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF

  ln -sf /usr/local/nvm/nvm.sh /usr/local/bin/nvm

  echo -e "${YELLOW}NVM installed successfully. Please restart your terminal or run 'source /etc/profile.d/nvm.sh' to start using NVM.${RESET}"
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
  version=$1
  echo -e "${YELLOW}Changing PHP version to PHP $version...${RESET}"
  a2dismod php*
  a2enmod php"${version}"
  update-alternatives --set php /usr/bin/php"${version}"
  systemctl restart apache2
  selected_php=$(php -v | head -n 1)
  echo -e "${YELLOW}PHP version changed to: ${BLUE}$selected_php${RESET}"
}

# Function to install PHP version
install_php_version() {
  version=$1
  echo -e "${YELLOW}Installing PHP ${version}...${RESET}"
  apt-get update
  add-apt-repository ppa:ondrej/php -y
  apt-get install -y php"${version}" php"${version}"-cli php"${version}"-fpm php"${version}"-mysql php"${version}"-curl php"${version}"-gd php"${version}"-mbstring php"${version}"-xml php"${version}"-zip php"${version}"-sqlite3 libapache2-mod-php"${version}"
  apt-get update
  echo -e "${YELLOW}PHP ${version} installed successfully.${RESET}"
}

# Function to remove PHP version
remove_php_version() {
  version=$1
  echo -e "${YELLOW}Removing PHP ${version}...${RESET}"
  apt-get remove --purge -y php"${version}" php"${version}"-cli php"${version}"-fpm php"${version}"-mysql php"${version}"-curl php"${version}"-gd php"${version}"-mbstring php"${version}"-xml php"${version}"-zip php"${version}"-sqlite3 libapache2-mod-php"${version}"
  apt-get autoremove -y
  apt-get autoclean
  echo -e "${YELLOW}PHP ${version} removed successfully.${RESET}"
}



# Function to install Composer
install_composer() {
  echo -e "${YELLOW}Installing Composer...${RESET}"
  EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
    echo >&2 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
  fi

  php composer-setup.php --quiet
  RESULT=$?
  rm composer-setup.php
  mv composer.phar /usr/local/bin/composer
  echo -e "${YELLOW}Composer installed successfully.${RESET}"
  return $RESULT
}

# Function to remove Composer
remove_composer() {
  echo -e "${YELLOW}Removing Composer...${RESET}"
  rm /usr/local/bin/composer
  echo -e "${YELLOW}Composer removed successfully.${RESET}"
}



# Function to create a virtual host (pwd)
create_vhost() {
  read -p "Enter the domain name :" domain
  read -p "Do you want to create a root directory for the domain ? [ Ex : /var/www/domain.vh ] (y/n) : " create_root_dir

  if [ "$create_root_dir" == "y" ]; then
    path="$ROOT_DIR/$domain"
    if [ ! -d "$path" ]; then
      mkdir -p "$path"
      chown -R "$USER":"$USER" "$path"
      chmod 755 "$path"
      chmod -R 777 $ROOT_DIR/"$domain"
      echo "Directory created at $path"
    else
      echo -e "The $path directory already exists. "
      return 1
    fi
  else
    read -p "Do you want to use the current directory ? (y/n): " use_current_dir
    if [ "$use_current_dir" == "y" ]; then
      path=$(pwd)
    else
      read -p "Enter the custom path :" custom_path
      path=${custom_path:-$(pwd)}
    fi
  fi

  echo "Creating Virtual Host for domain: $domain"
  echo "Using DocumentRoot: $path"

  file="<VirtualHost *:80>
        <Directory $path >
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        ServerName $domain
        ServerAlias www.$domain
        ServerAdmin webmaster@localhost
        DocumentRoot $path

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>"

  echo "$file" >"/etc/apache2/sites-available/${domain}.conf"
  a2ensite "${domain}.conf"
  systemctl restart apache2

  echo "127.0.0.1   $domain " | tee -a /etc/hosts

  echo "New Virtual Host is http://$domain"
}

# Function to delete or remove a virtual host
delete_vhost() {
  read -p "Enter the domain name to delete :" domain
  if [ -f "/etc/apache2/sites-available/${domain}.conf" ]; then
    a2dissite "${domain}.conf"
    rm "/etc/apache2/sites-available/${domain}.conf"
    systemctl restart apache2
    echo -e "${RED} Virtual Host $domain has been removed. ${RESET}"
    sed -i "/$domain/d" /etc/hosts
    read -p "Do you want to delete the root directory associated with the domain ? (y/n): " delete_dir

    if [ "$delete_dir" == "y" ]; then
      default_path="$ROOT_DIR/$domain"
      read -p "Enter the directory path to delete (default: $default_path): " path
      path=${path:-$default_path}

      if [ -d "$path" ]; then
        rm -rf "$path"
        echo -e "${RED} Directory $path has been deleted. ${RESET}"
      else
        echo -e "${RED} Directory $path does not exist. ${RESET}"
      fi
    fi
    echo -e "${RED} Virtual Host $domain has been fully deleted ${RESET}"
  else
    echo "Virtual Host $domain does not exist."
    return 1
  fi
}


# Function to install Apache
install_apache() {
  echo -e "${YELLOW}Installing Apache...${RESET}"
  apt-get update
  apt-get install -y apache2
  ufw allow in "Apache"

  # Set default DirectoryIndex
  echo '<IfModule mod_dir.c>
           DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
        </IfModule>' | sudo tee /etc/apache2/mods-enabled/dir.conf > /dev/null

  # Enable necessary PHP modules
  phpenmod mbstring
  a2enmod rewrite
  systemctl restart apache2

  # Create default virtual host configuration
  echo '<VirtualHost *:80>
    <Directory /var/www/html>
      Options Indexes FollowSymLinks MultiViews
      AllowOverride All
      Require all granted
    </Directory>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
  </VirtualHost>' | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null

  systemctl restart apache2
  systemctl enable apache2
  systemctl start apache2
  echo -e "${YELLOW}Apache installed successfully.${RESET}"
}

# Function to remove Apache
remove_apache() {
  echo -e "${YELLOW}Removing Apache...${RESET}"
  systemctl stop apache2
  apt-get remove --purge -y apache2
  apt-get autoremove -y
  apt-get autoclean
  echo -e "${YELLOW}Apache removed successfully.${RESET}"
}

# Function to install phpMyAdmin
install_pma() {
  echo -e "${YELLOW}Installing phpMyAdmin...${RESET}"
  apt-get update
  apt-get install -y phpmyadmin
  echo -e "${YELLOW}Configuring Apache for phpMyAdmin...${RESET}"
  echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
  phpenmod mbstring
  a2enmod rewrite
  systemctl restart apache2
  echo -e "${YELLOW}phpMyAdmin installed successfully. Access it at http://localhost/phpmyadmin ${RESET}"
}

# Function to remove phpMyAdmin
remove_pma() {
  echo -e "${YELLOW}Removing phpMyAdmin...${RESET}"
  systemctl stop apache2
  apt-get remove --purge -y phpmyadmin
  apt-get autoremove -y
  apt-get autoclean
  sed -i '/phpmyadmin/d' /etc/apache2/apache2.conf
  systemctl start apache2
  echo -e "${YELLOW}phpMyAdmin removed successfully.${RESET}"
}



# Function to show PHP menu
php_menu() {
  while true; do
    echo -e "${BLUE} =====|  PHP Menu  |===== ${RESET}"
    echo -e "${YELLOW}1. Change  - PHP version ${RESET}"
    echo -e "${YELLOW}2. Install - PHP version ${RESET}"
    echo -e "${YELLOW}3. Remove  - PHP version ${RESET}"
    echo -e "${YELLOW}0. Back ${RESET}"
    read -p "Enter your choice [0-3] :" choice

    case $choice in
    1)
      echo -e "${YELLOW}Select PHP version to install: 8.1, 8.2, 8.3, 8.4, etc.... ${RESET}"
      read -p "Enter PHP version [Ex. 8.1 ]: " version
      change_php_version "$version"

      ;;
    2)
      echo -e "${YELLOW}Select PHP version to install: 8.1, 8.2, 8.3, 8.4, etc.... ${RESET}"
      read -p "Enter PHP version [Ex. 8.1 ]: " version
      install_php_version "$version"
      ;;
    3)
      echo -e "${YELLOW}Select PHP version to remove: 8.1, 8.2, 8.3, 8.4, etc.... ${RESET}"
      read -p "Enter PHP version [Ex. 8.1 ]: " version
      remove_php_version "$version"
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

# Function to show vHost menu
vHost_menu() {
  while true; do
    echo -e "${BLUE} =====| vHost Menu |===== ${RESET}"
    echo -e "${YELLOW}1. Create vHost ${RESET}"
    echo -e "${YELLOW}2. Remove vHost ${RESET}"
    echo -e "${YELLOW}3. Show all available seats vHost ${RESET}"
    echo -e "${YELLOW}4. Edit vHost domain configuration  ${RESET}"
    echo -e "${YELLOW}5. Show the hosts file ${RESET}"
    echo -e "${YELLOW}6. Edit the hosts file ${RESET}"
    echo -e "${YELLOW}0. Back ${RESET}"
    read -p "Enter your choice [0-4] :" choice

    case $choice in
    1)
      create_vhost
      ;;
    2)
      delete_vhost
      ;;
    3)
      ls -l $CONF_DIR
      ;;
    4)
      read -p "Enter the domain name :" domain
      if [ -f "/etc/apache2/sites-available/${domain}.conf" ]; then
        nano "/etc/apache2/sites-available/${domain}.conf"
      else
        echo "Virtual Host $domain does not exist."
        return 1
      fi
      ;;
    5)
      echo -e "${BLUE}Here is a /ect/hosts file ${RESET}"
      cat /etc/hosts
      ;;
    6)
      nano /etc/hosts
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
    echo -e "${BLUE} =====|  Composer Menu  |===== ${RESET}"
    echo -e "${YELLOW}1. Install Composer${RESET}"
    echo -e "${YELLOW}2. Remove Composer${RESET}"
    echo -e "${YELLOW}0. Back ${RESET}"
    read -p "Enter your choice [0-2] :" choice

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

# Function to show NVM menu
nvm_menu() {
  while true; do
    echo -e "${BLUE} =====|  Node Version Manager Menu  |===== ${RESET}"
    echo -e "${YELLOW}1. Install NVM  ${RESET}"
    echo -e "${YELLOW}2. Remove NVM ${RESET}"
    echo -e "${YELLOW}0. Back ${RESET}"
    read -p "Enter your choice [0-2]: " choice

    case $choice in
    1)
      install_nvm
      ;;
    2)
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

# Function to show Apache menu
apache_menu() {
  while true; do
    echo -e "${BLUE} =====|  Apache Menu  |===== ${RESET}"
    echo -e "${YELLOW}1. Install Apache  ${RESET}"
    echo -e "${YELLOW}2. Remove  Apache ${RESET}"
    echo -e "${YELLOW}3. Install phpMyadmin ${RESET}"
    echo -e "${YELLOW}4. Remove  phpMyadmin ${RESET}"
    echo -e "${YELLOW}0. Back ${RESET}"
    read -p "Enter your choice [0-2]: " choice

    case $choice in
    1)
      install_apache
      ;;
    2)
      remove_apache
      ;;
    3)
      install_pma
      ;;
    4)
      remove_pma
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
  echo -e "${BLUE} =====| Main Menu |===== ${RESET}"
  echo -e "${YELLOW}1. PHP ${RESET}"
  echo -e "${YELLOW}2. vHost ${RESET}"
  echo -e "${YELLOW}3. Composer ${RESET}"
  echo -e "${YELLOW}4. Node Version Manager (nvm) ${RESET}"
  echo -e "${YELLOW}5. Apache ${RESET}"
  echo -e "${YELLOW}6. Check Version ${RESET}"
  echo -e "${YELLOW}0. Exit ${RESET}"
  read -p "Enter your choice [0-6] :" choice

  case $choice in
  1)
    php_menu
    ;;
  2)
    vHost_menu
    ;;
  3)
    composer_menu
    ;;
  4)
    nvm_menu
    ;;
  5)
    apache_menu
    ;;
  6)
     view_versions
    ;;
  cg)
    check_global
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
