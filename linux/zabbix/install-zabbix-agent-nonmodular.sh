#!/bin/bash

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
                wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb
                dpkg -i zabbix-release_latest_7.2+debian12_all.deb
                apt update
            else
                echo "Unsupported Debian version: $VERSION"
                exit 1
            fi
            ;;
        Ubuntu)
            case $VERSION in
                20.04)
                    echo "Installing Zabbix agent for Ubuntu 20.04"
                    wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu20.04_all.deb
                    dpkg -i zabbix-release_latest_7.2+ubuntu20.04_all.deb
                    apt update
                    ;;
                22.04)
                    echo "Installing Zabbix agent for Ubuntu 22.04"
                    wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu22.04_all.deb
                    dpkg -i zabbix-release_latest_7.2+ubuntu22.04_all.deb
                    apt update
                    ;;
                24.04)
                    echo "Installing Zabbix agent for Ubuntu 24.04"
                    wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
                    dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
                    apt update
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
    apt install -y zabbix-agent

    # Update the Zabbix agent configuration
    sed -i -E "s/^Server=127.0.0.1/Server=monitor.vampdev.com/" /etc/zabbix/zabbix_agentd.conf

    # Restart and enable the Zabbix agent service
    systemctl restart zabbix-agent
    systemctl enable zabbix-agent

    echo "Zabbix agent installation and configuration completed."
}

# Run the installation function
install_zabbix_agent
