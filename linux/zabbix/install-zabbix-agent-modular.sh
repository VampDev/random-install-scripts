#!/bin/bash

# Exit on error
set -e

# Function to install Zabbix agent based on distribution
install_zabbix_agent() {
    # Determine the distribution and version
    DISTRO=$(lsb_release -i | awk '{print $3}')
    VERSION=$(lsb_release -r | awk '{print $2}')

    echo "Detected Distribution: $DISTRO $VERSION"

    # Install the corresponding Zabbix repository
    case $DISTRO in
        Debian)
            if [ "$VERSION" == "12" ]; then
                echo "Installing Zabbix agent for Debian 12"
                if ! wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb; then
                    echo "Error: Failed to download Zabbix release package for Debian 12"
                    exit 1
                fi
                if ! dpkg -i zabbix-release_latest_7.2+debian12_all.deb; then
                    echo "Error: Failed to install Zabbix release package"
                    exit 1
                fi
                if ! apt update; then
                    echo "Error: Failed to update apt repository"
                    exit 1
                fi
            else
                echo "Unsupported Debian version: $VERSION"
                exit 1
            fi
            ;;
        Ubuntu)
            case $VERSION in
                18.04)
                    echo "Installing Zabbix agent for Ubuntu 18.04"
                    if ! wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu18.04_all.deb; then
                        echo "Error: Failed to download Zabbix release package for Ubuntu 18.04"
                        exit 1
                    fi
                    if ! dpkg -i zabbix-release_latest_7.2+ubuntu18.04_all.deb; then
                        echo "Error: Failed to install Zabbix release package"
                        exit 1
                    fi
                    if ! apt update; then
                        echo "Error: Failed to update apt repository"
                        exit 1
                    fi
                    ;;
                20.04)
                    echo "Installing Zabbix agent for Ubuntu 20.04"
                    if ! wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu20.04_all.deb; then
                        echo "Error: Failed to download Zabbix release package for Ubuntu 20.04"
                        exit 1
                    fi
                    if ! dpkg -i zabbix-release_latest_7.2+ubuntu20.04_all.deb; then
                        echo "Error: Failed to install Zabbix release package"
                        exit 1
                    fi
                    if ! apt update; then
                        echo "Error: Failed to update apt repository"
                        exit 1
                    fi
                    ;;
                22.04)
                    echo "Installing Zabbix agent for Ubuntu 22.04"
                    if ! wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu22.04_all.deb; then
                        echo "Error: Failed to download Zabbix release package for Ubuntu 22.04"
                        exit 1
                    fi
                    if ! dpkg -i zabbix-release_latest_7.2+ubuntu22.04_all.deb; then
                        echo "Error: Failed to install Zabbix release package"
                        exit 1
                    fi
                    if ! apt update; then
                        echo "Error: Failed to update apt repository"
                        exit 1
                    fi
                    ;;
                24.04)
                    echo "Installing Zabbix agent for Ubuntu 24.04"
                    if ! wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb; then
                        echo "Error: Failed to download Zabbix release package for Ubuntu 24.04"
                        exit 1
                    fi
                    if ! dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb; then
                        echo "Error: Failed to install Zabbix release package"
                        exit 1
                    fi
                    if ! apt update; then
                        echo "Error: Failed to update apt repository"
                        exit 1
                    fi
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
}

# Run the installation function
install_zabbix_agent
