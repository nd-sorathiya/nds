# NDS - Development Environment Setup Script

## Overview

The **NDS** Bash script is a comprehensive tool designed to manage your development environment effortlessly. It offers a user-friendly, menu-driven interface to handle PHP, Node.js, NVM (Node Version Manager), virtual hosts, and Composer installations. Whether you're setting up a new project or maintaining an existing one, NDS simplifies tasks like version management, virtual host configuration, and environment setup.

## Requirements

- A Unix-like operating system (Linux, macOS)
- `curl` command must be installed
- Sudo access for package installation and system configuration

## Menu Structure

- **Main Menu**:
  - PHP 
  - vHost 
  - Composer 
  - Node Version Manager (nvm) 
  - Apache 
  - mySql 
  - Check Version 

- **vHost Menu**:
  - Change  - PHP version 
  - Install - PHP version 
  - Remove  - PHP version 
  - Back 

- **Composer Menu**:
  - Install Composer
  - Remove Composer

- **Node Version Manager (nvm) menu**:
  - Install NVM  
  - Remove NVM 

- **Apache**:
  - Install Apache  
  - Remove  Apache 
  - Install phpMyadmin 
  - Remove  phpMyadmin 



## Installation & Usage

1. **Ensure `curl` is installed**:
    - Install `curl` if it’s not already available:
```bash
sudo apt install curl
```

2. **Download and Run the Script**:
    - Download the script and start it with the following command:
```bash
curl -o nds.sh https://raw.githubusercontent.com/nd-sorathiya/nds/main/nds.sh
```


3. **Run the Script**:
  - Make the script globally accessible:
```bash
sudo chmod +x ./nds.sh
sudo ./nds.sh
```
  - Now, you can run the script with:
```bash
sudo nds
```


4. **Run the Script Globally**:
  - Make the script globally accessible:
```bash
sudo cp nds.sh /usr/local/bin/nds
sudo chmod +x /usr/local/bin/nds
```
  - Now, you can run the script with:
```bash
sudo nds
```

**Remove the Script**:
  - To remove the script from your system:
```bash
sudo rm -f /usr/local/bin/nds
```

## Notes

- **Global Accessibility**: The script can be made globally accessible, simplifying repeated use across different projects.
- **Virtual Hosts**: Ensure Apache is installed and properly configured before using the virtual host features.

## License

This project is licensed under the MIT License.
