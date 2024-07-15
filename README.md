# Development Environment Setup Script

## Overview

This Bash script provides a simple menu-driven interface to manage PHP, Node.js, NVM (Node Version Manager), and their versions on a Unix-like system. It allows users to check, install, change, or remove versions of these tools efficiently.

## Features

- **PHP Management**:
  - Check the current PHP version
  - Install specific PHP versions (8.1, 8.2, 8.3)
  - Change the active PHP version
  - Remove PHP versions

- **Node.js Management**:
  - Install the latest Node LTS version
  - Remove Node.js

- **NVM Management**:
  - Install NVM
  - Remove NVM

- **View Versions**:
  - Display the installed versions of PHP, Node.js, NPM, and NVM

## Requirements

- A Unix-like operating system (Linux, macOS)
- `curl` command must be installed
- Sudo access to install packages

## Usage


- `curl` should be installed on your system. If not, you can install it using:

 ```bash
    sudo apt install curl
```


- Download the Script: Open your terminal and execute the following command to download the script:

```bash
    curl -o nds.sh https://raw.githubusercontent.com/nikunj-sorathiya/nds/main/nds.sh && bash nds.sh
```

- Run the Script: Once the script is downloaded, execute it using bash:

 ```bash
    nds
```


- Remove the script from your device

 ```bash
     sudo rm -f /usr/local/bin/nds
```