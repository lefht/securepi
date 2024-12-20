# Security Configuration Script

This script is designed to perform various security configurations on a Linux-based system, specifically for enabling and configuring **UFW (Uncomplicated Firewall)**, **Fail2Ban**, **Unattended Upgrades**, and **SSH**. It ensures that your system is securely configured with minimal manual intervention.

## Prerequisites

- The script should be run as root, as it modifies system configurations.
- The system must have the following packages available:
  - `ufw` (Uncomplicated Firewall)
  - `fail2ban`
  - `unattended-upgrades`

## Features

- **Resets and configures UFW** with default rules for SSH, HTTP, and HTTPS.
- **Installs and configures Fail2Ban** to protect SSH from brute-force attacks.
- **Installs and configures unattended-upgrades** to ensure the system receives automatic security updates.
- **Configures SSH** to allow only the current user.
- **Updates and cleans the system** by performing an upgrade and ensuring all packages are up-to-date.

## Script Breakdown

### 1. `reset_and_configure_ufw`
This function resets UFW to avoid conflicts and configures it to allow traffic on SSH, HTTP, and HTTPS ports.

#### Example:
```bash
ufw allow ssh
ufw allow http
ufw allow https
ufw logging on
```

### 2. `install_and_configure_fail2ban`
Installs Fail2Ban and configures it to protect SSH. It also checks for the existence of the `/var/log/auth.log` file and creates it if missing.

#### Example:
```bash
apt-get install -y fail2ban
```

### 3. `install_and_configure_unattended_upgrades`
Installs and configures the **unattended-upgrades** package for automatic security updates. It ensures that the Raspbian and Raspberry Pi Foundation repositories are included in the upgrade sources.

#### Example:
```bash
apt-get install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
```

### 4. `configure_sshd`
Configures SSH to allow only the current user for secure remote access. It checks if the current user is already added to the `AllowUsers` directive in `/etc/ssh/sshd_config`.

#### Example:
```bash
AllowUsers your_username
```

### 5. `update_and_clean`
Updates the system and upgrades all installed packages to their latest versions.

#### Example:
```bash
apt-get update && apt-get upgrade -y
```

### Main Function
The `main` function ties all the above functions together and ensures the entire security configuration process is automated and executed in the correct order.

```bash
reset_and_configure_ufw
install_and_configure_fail2ban
install_and_configure_unattended_upgrades
configure_sshd
update_and_clean
```

## How to Use

1. Save the script to a file, for example, `security_config.sh`.
2. Give it executable permissions:
   ```bash
   chmod +x security_config.sh
   ```
3. Run the script as root:
   ```bash
   sudo ./security_config.sh
   ```
4. It is also possible to run script without needing to download
    ```bash
        curl https://raw.githubusercontent.com/lefht/securepi/refs/heads/main/securepi.sh | ssh pi_usr@hostip 'sudo bash -s'
    ```
### Example Output

When running the script, you should see logs indicating the progress and completion of each security configuration step:
```
[INFO] Starting security configuration...
[INFO] Resetting UFW to avoid conflicts...
[INFO] Enabling UFW...
[INFO] Adding rules for SSH, HTTP, and HTTPS...
[INFO] Enabling UFW logging...
[INFO] UFW configuration completed successfully.
[INFO] Checking if /var/log/auth.log exists...
[INFO] Installing Fail2Ban...
[INFO] Fail2Ban configured successfully.
[INFO] Installing unattended-upgrades...
[INFO] Enabling unattended-upgrades service...
[INFO] Unattended-upgrades configured successfully.
[INFO] Configuring SSH to allow only the current user...
[INFO] User wehelie added to AllowUsers in /etc/ssh/sshd_config.
[INFO] Restarting SSH service...
[INFO] SSH configuration updated successfully.
[INFO] Updating and upgrading the system...
[INFO] System update and upgrade completed.
[INFO] Security configuration completed successfully.
```

## Important Notes

- **Root privileges**: Ensure the script is executed as root for proper configuration changes.
- **Logging**: The script logs progress to the console for easy troubleshooting.
- **SSH Configuration**: This script configures SSH to only allow the current user. Ensure your user is correctly identified.

## Conclusion

This script simplifies the process of securing a Raspberry PIs by automating common security configurations. By running it, you ensure your system is protected with a:
- firewall
- fail2ban
- automatic security updates
- secure SSH configuration.
