#!/usr/bin/env bash

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root."
    exit 1
fi

log_message() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

reset_and_configure_ufw() {
    log_message "Resetting UFW to avoid conflicts..."
    if ! ufw --force reset; then
        log_error "Failed to reset UFW."
        exit 1
    fi

    log_message "Enabling UFW..."
    if ! ufw --force enable; then
        log_error "Failed to enable UFW."
        exit 1
    fi

    log_message "Adding rules for SSH, HTTP, and HTTPS..."
    for port in ssh http https; do
        if ! ufw allow "$port"; then
            log_error "Failed to allow $port through UFW."
            exit 1
        fi
    done

    log_message "Enabling UFW logging..."
    if ! ufw logging on; then
        log_error "Failed to enable logging for UFW."
        exit 1
    fi

    log_message "UFW configuration completed successfully."
}

install_and_configure_fail2ban() {
    log_message "Checking if /var/log/auth.log exists..."

    # Ensure /var/log/auth.log exists
    if [ ! -f /var/log/auth.log ]; then
        log_message "/var/log/auth.log not found. Creating it..."
        sudo touch /var/log/auth.log
        # chown syslog:adm /var/log/auth.log
        # chmod 640 /var/log/auth.log
        log_message "/var/log/auth.log created successfully."
    else
        log_message "/var/log/auth.log already exists."
    fi

    log_message "Installing Fail2Ban..."
    if ! apt-get install -y fail2ban; then
        log_error "Failed to install Fail2Ban."
        exit 1
    fi

    local jail_local_file="/etc/fail2ban/jail.local"

    log_message "Creating and configuring $jail_local_file..."
    cat > "$jail_local_file" <<EOF
[DEFAULT]
bantime = 1h
banaction = ufw

[sshd]
enabled = true
EOF

    if ! systemctl restart fail2ban; then
        log_error "Failed to restart Fail2Ban."
        exit 1
    fi

    log_message "Fail2Ban configured successfully."
}


update_and_clean() {
    log_message "Updating and upgrading the system..."
    if ! apt-get update && apt-get upgrade -y; then
        log_error "Failed to update and upgrade the system."
        exit 1
    fi
    log_message "System update and upgrade completed."
}

install_and_configure_unattended_upgrades() {
    log_message "Installing unattended-upgrades..."
    if ! apt-get install -y unattended-upgrades; then
        log_error "Failed to install unattended-upgrades."
        exit 1
    fi

    log_message "Configuring unattended-upgrades for Raspbian and Raspberry Pi Foundation..."
    local distro_codename
    distro_codename=$(lsb_release -sc)

    local unattended_upgrades_file="/etc/apt/apt.conf.d/50unattended-upgrades"

    if grep -q "Raspbian" "$unattended_upgrades_file"; then
        log_message "Raspbian origins already configured in $unattended_upgrades_file. Skipping."
    else
        sed -i "/^\/\/ *\"origin=.*;/a \
        \"origin=Raspbian,codename=${distro_codename},label=Raspbian\"; \
        \"origin=Raspberry Pi Foundation,codename=${distro_codename},label=Raspberry Pi Foundation\";" \
        "$unattended_upgrades_file"
        log_message "Added Raspbian and Raspberry Pi origins to $unattended_upgrades_file."
    fi

    log_message "Enabling unattended-upgrades service..."
    if ! dpkg-reconfigure --priority=low unattended-upgrades; then
        log_error "Failed to enable unattended-upgrades."
        exit 1
    fi

    log_message "Unattended-upgrades configured successfully."
}

configure_sshd() {
    log_message "Configuring SSH to allow only the current user..."

    # Extract the current username
    local current_user
    current_user=$(whoami)

    # Check if the current user is already allowed
    if grep -q "^AllowUsers.*\b$current_user\b" /etc/ssh/sshd_config; then
        log_message "User $current_user is already allowed in /etc/ssh/sshd_config. Skipping."
    else
        # Append the AllowUsers directive or modify if it exists
        if grep -q "^AllowUsers" /etc/ssh/sshd_config; then
            sed -i "/^AllowUsers/s/$/ $current_user/" /etc/ssh/sshd_config
        else
            echo "AllowUsers $current_user" >> /etc/ssh/sshd_config
        fi
        log_message "User $current_user added to AllowUsers in /etc/ssh/sshd_config."
    fi

    # Restart SSH service
    log_message "Restarting SSH service..."
    if ! systemctl restart ssh; then
        log_error "Failed to restart SSH service."
        exit 1
    fi
    log_message "SSH configuration updated successfully."
}

main() {
    log_message "Starting security configuration..."
    reset_and_configure_ufw
    install_and_configure_fail2ban
    install_and_configure_unattended_upgrades
    configure_sshd
    update_and_clean
    log_message "Security configuration completed successfully."
}

main