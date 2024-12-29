#!/bin/bash

# Exit on error
set -e

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run as root and try again."
    exit 1
fi

# Function to install Zabbix agent based on distribution
install_zabbix_agent() {
    # Determine the distribution and version
    DISTRO=$(lsb_release -i | awk '{print $3}')
    VERSION=$(lsb_release -r | awk '{print $2}')

    echo "Detected Distribution: $DISTRO $VERSION"

    # Create the directory to store the .deb package
    mkdir -p /tmp/zabbix-agent

    # Install the corresponding Zabbix repository
    case $DISTRO in
        Debian)
            if [ "$VERSION" == "12" ]; then
                echo "Installing Zabbix agent for Debian 12"
                PACKAGE_URL="https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb"
                PACKAGE_NAME="zabbix-release_latest_7.2+debian12_all.deb"
            else
                echo "Unsupported Debian version: $VERSION"
                exit 1
            fi
            ;;
        Ubuntu)
            case $VERSION in
                18.04)
                    echo "Installing Zabbix agent for Ubuntu 18.04"
                    PACKAGE_URL="https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu18.04_all.deb"
                    PACKAGE_NAME="zabbix-release_latest_7.2+ubuntu18.04_all.deb"
                    ;;
                20.04)
                    echo "Installing Zabbix agent for Ubuntu 20.04"
                    PACKAGE_URL="https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu20.04_all.deb"
                    PACKAGE_NAME="zabbix-release_latest_7.2+ubuntu20.04_all.deb"
                    ;;
                22.04)
                    echo "Installing Zabbix agent for Ubuntu 22.04"
                    PACKAGE_URL="https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu22.04_all.deb"
                    PACKAGE_NAME="zabbix-release_latest_7.2+ubuntu22.04_all.deb"
                    ;;
                24.04)
                    echo "Installing Zabbix agent for Ubuntu 24.04"
                    PACKAGE_URL="https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb"
                    PACKAGE_NAME="zabbix-release_latest_7.2+ubuntu24.04_all.deb"
                    ;;
                *)
                    echo "Unsupported Ubuntu version: $VERSION"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Unsupported Distribution: $DISTRO"
            exit 1
            ;;
    esac

    # Download the .deb package into /tmp/zabbix-agent
    echo "Downloading $PACKAGE_NAME to /tmp/zabbix-agent..."
    if ! wget -P /tmp/zabbix-agent "$PACKAGE_URL"; then
        echo "Error: Failed to download Zabbix release package"
        exit 1
    fi

    # Install the downloaded package
    echo "Installing Zabbix release package..."
    if ! dpkg -i /tmp/zabbix-agent/"$PACKAGE_NAME"; then
        echo "Error: Failed to install Zabbix release package"
        exit 1
    fi

    # Update apt repositories
    if ! apt update; then
        echo "Error: Failed to update apt repository"
        exit 1
    fi

    # Install the Zabbix agent
    if ! apt install -y zabbix-agent; then
        echo "Error: Failed to install Zabbix agent"
        exit 1
    fi

    # Ask the user for the server address
    read -p "Please enter the Zabbix server address: " ZABBIX_SERVER

    # Update the Zabbix agent configuration with the user-provided server address
    if ! sed -i -E "s/^Server=127.0.0.1/Server=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf; then
        echo "Error: Failed to update Zabbix agent configuration"
        exit 1
    fi

    # Restart and enable the Zabbix agent service
    if ! systemctl restart zabbix-agent; then
        echo "Error: Failed to restart Zabbix agent service"
        exit 1
    fi
    if ! systemctl enable zabbix-agent; then
        echo "Error: Failed to enable Zabbix agent service on boot"
        exit 1
    fi

    echo "Zabbix agent installation and configuration completed with server: $ZABBIX_SERVER"

    # Ask the user if the system should be rebooted
    read -p "Do you want to reboot the system now? (y/n): " REBOOT_RESPONSE

    # Handle reboot based on user input
    if [[ "$REBOOT_RESPONSE" == "y" || "$REBOOT_RESPONSE" == "Y" ]]; then
        echo "Rebooting the system..."
        reboot
    else
        echo "The system will not be rebooted."
    fi
}

# Run the installation function
install_zabbix_agent
