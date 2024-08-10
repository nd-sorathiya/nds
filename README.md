# NDS - Development Environment Setup Script

## Overview

The **NDS** Bash script is a comprehensive tool designed to manage your development environment effortlessly. It offers a user-friendly, menu-driven interface to handle PHP, Node.js, NVM (Node Version Manager), virtual hosts, and Composer installations. Whether you're setting up a new project or maintaining an existing one, NDS simplifies tasks like version management, virtual host configuration, and environment setup.

## Features

- **PHP Management**:
  - Change the active PHP version
  - Install specific PHP versions (8.1, 8.2, 8.3)
  - Remove PHP versions

- **Node.js & NVM Management**:
  - Install the latest Node.js LTS version
  - Remove Node.js
  - Install and remove NVM

- **Composer Management**:
  - Install Composer
  - Remove Composer

- **Virtual Host Management**:
  - Create new virtual hosts
  - Delete existing virtual hosts
  - Modify and manage virtual host settings

- **Environment Information**:
  - Display versions of PHP, Node.js, NPM, and NVM
  - Set up the script globally for easier access

## Requirements

- A Unix-like operating system (Linux, macOS)
- `curl` command must be installed
- Sudo access for package installation and system configuration

## Menu Structure

- **Main Menu**:
  - PHP Menu
  - vHost Menu
  - Composer Menu
  - Other Menu

- **PHP Menu**:
  - Change PHP version
  - Install PHP
  - Remove PHP

- **Node Menu**:
  - Install Node LTS
  - Remove Node.js
  - Install NVM
  - Remove NVM

- **Composer Menu**:
  - Install Composer
  - Remove Composer

- **vHost Menu**:
  - Create vHost
  - Remove vHost
  - vHost settings (edit configurations, view available sites, etc.)

- **Other Menu**:
  - Install Node.js
  - Show all installed versions
  - Set up the script globally


`curl` should be installed on your system. If it's not already installed, you can install it using:
```bash
sudo apt install curl
```

## Installation & Usage

1. **Ensure `curl` is installed**:
    - Install `curl` if it’s not already available:
```bash
  sudo apt install curl
```

2. **Download and Run the Script**:
    - Download the script and start it with the following command:
```bash
      curl -o nds.sh https://raw.githubusercontent.com/nd-sorathiya/nds/main/nds.sh && bash nds.sh
```

3. **Run the Script Globally**:
    - Make the script globally accessible:
```bash
      sudo cp nds.sh /usr/local/bin/nds
      sudo chmod +x /usr/local/bin/nds
```
    - Now, you can run the script with:
```bash
      nds
```

4. **Remove the Script**:
    - To remove the script from your system:
```bash
      sudo rm -f /usr/local/bin/nds
```

## Notes

- **Global Accessibility**: The script can be made globally accessible, simplifying repeated use across different projects.
- **Virtual Hosts**: Ensure Apache is installed and properly configured before using the virtual host features.

## License

This project is licensed under the MIT License.
