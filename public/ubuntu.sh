#!/bin/bash

# Function for logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function for error handling
handle_error() {
    log "ERROR: $1"
    exit 1
}

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    handle_error "The script must be run with sudo"
fi

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        return $?
    else
        return 1
    fi
}

# Function to read input with timeout and validation
get_input() {
    local prompt="$1"
    local default="$2"
    local validation_func="$3"
    local input
    local valid=false
    
    while [ "$valid" = false ]; do
        # Use /dev/tty to ensure input can be read even through pipe
        exec < /dev/tty
        read -p "$prompt" input
        
        if [ -z "$input" ] && [ ! -z "$default" ]; then
            input="$default"
        fi
        
        if [ ! -z "$validation_func" ]; then
            if $validation_func "$input"; then
                valid=true
            else
                log "Invalid input, please try again"
                continue
            fi
        else
            valid=true
        fi
    done
    echo "$input"
}

# Function to check package installation status
check_package_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

# Function to backup configuration files
backup_config() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)" || handle_error "Failed to backup file $file"
    fi
}

# Function to install packages with retry
install_package() {
    local package="$1"
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log "Trying to install $package (Attempt $attempt of $max_attempts)"
        if apt-get install -y "$package"; then
            log "Successfully installed $package"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 5
    done
    handle_error "Failed to install $package after $max_attempts attempts"
}

# Main script starts here
log "Starting server configuration..."

# Request and validate input
user_ip=$(get_input "Enter IP address (e.g., 192.168.1.1): " "" validate_ip)
user_domain=$(get_input "Enter domain name (e.g., smkeki.sch.id): " "" )
mysql_root_password=$(get_input "Enter password for MySQL root: ")
phpmyadmin_password=$(get_input "Enter password for phpMyAdmin: ")
# Additional input for Samba
samba_username=$(get_input "Enter username for Samba (e.g., smkuser): " "")
samba_password=$(get_input "Enter password for Samba: ")

# Fix for interrupted dpkg
log "Fixing interrupted packages..."
dpkg --configure -a || handle_error "Failed to fix interrupted dpkg"

# Update system with proper error handling
log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive

# Clean apt cache and fix dependencies
apt-get clean
apt-get autoremove -y
apt-get autoclean

# Update with proper error handling
if ! apt-get update -y; then
    log "WARNING: Update failed, trying to fix..."
    rm -f /var/lib/apt/lists/lock
    rm -f /var/cache/apt/archives/lock
    rm -f /var/lib/dpkg/lock*
    dpkg --configure -a
    apt-get update -y || handle_error "Failed to update system"
fi

# Upgrade with proper error handling
if ! apt-get upgrade -y; then
    log "WARNING: Upgrade failed, trying to fix..."
    dpkg --configure -a
    apt-get upgrade -y || handle_error "Failed to upgrade system"
fi

# Add universe repository
add-apt-repository universe -y || handle_error "Failed to add universe repository"

# Set automatic configuration for MySQL and phpMyAdmin
debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_password"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_password"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $mysql_root_password"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $phpmyadmin_password"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"

# Install required packages with proper error handling
packages="bind9 apache2 mysql-server apache2-utils phpmyadmin samba"
for package in $packages; do
    if ! check_package_installed "$package"; then
        # Fix dpkg before installation
        dpkg --configure -a
        install_package "$package"
    fi
done

# Backup and configure important files
backup_config "/etc/resolv.conf"
backup_config "/etc/bind/named.conf.default-zones"
backup_config "/etc/apache2/sites-available/000-default.conf"
backup_config "/etc/samba/smb.conf"

# Configure DNS
cat > /etc/resolv.conf <<EOL
nameserver $user_ip
nameserver 8.8.8.8
search $user_domain
options edns0 trust-ad
EOL

# Configure Bind9 zones
reversed_ip=$(echo "$user_ip" | awk -F. '{print $3"."$2"."$1}')

cat > /etc/bind/named.conf.default-zones <<EOL
# Default zones
zone "localhost" {
    type master;
    file "/etc/bind/db.local";
};

zone "127.in-addr.arpa" {
    type master;
    file "/etc/bind/db.127";
};

zone "0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.0";
};

zone "255.in-addr.arpa" {
    type master;
    file "/etc/bind/db.255";
};

# Custom SMK zones
zone "$user_domain" {
     type master;
     file "/etc/bind/smk.db";
 };

zone "$reversed_ip.in-addr.arpa" {
     type master;
     file "/etc/bind/smk.ip";
 };
EOL

# Configure zone files
cat > /etc/bind/smk.db <<EOL
\$TTL    604800
@       IN      SOA     ns.$user_domain. root.$user_domain. (
                        $(date +%Y%m%d)01 ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL
;
@       IN      NS      ns.$user_domain.
@       IN      MX 10   $user_domain.
@       IN      A       $user_ip
ns      IN      A       $user_ip
www     IN      CNAME   ns
mail    IN      CNAME   ns
ftp     IN      CNAME   ns
ntp     IN      CNAME   ns
proxy   IN      CNAME   ns
EOL

# Configure PTR file
octet=$(echo "$user_ip" | awk -F. '{print $4}')
cat > /etc/bind/smk.ip <<EOL
@       IN      SOA     ns.$user_domain. root.$user_domain. (
                        $(date +%Y%m%d)01 ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL
;
@       IN      NS      ns.$user_domain.
$octet  IN      PTR     ns.$user_domain.
EOL

# Configure Apache
cat > /etc/apache2/sites-available/000-default.conf <<EOL
<VirtualHost $user_ip:80>
        ServerAdmin admin@$user_domain
        ServerName www.$user_domain
        DocumentRoot /var/www
        ErrorLog \${APACHE_LOG_DIR}/error.log
        LogLevel warn
        CustomLog \${APACHE_LOG_DIR}/access.log combined
        
        <Directory /var/www/>
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>
</VirtualHost>
EOL

# Create index.php
mkdir -p /var/www
cat > /var/www/index.php <<EOL
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to $user_domain</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Welcome to Server $user_domain</h1>
    <?php phpinfo(); ?>
</body>
</html>
EOL

# Set access permissions for /var/www more securely
chown -R www-data:www-data /var/www/
find /var/www/ -type d -exec chmod 755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;

# Configure Samba
useradd -m $samba_username 2>/dev/null || true
echo -e "$samba_password\n$samba_password" | passwd $samba_username

cat > /etc/samba/smb.conf <<EOL
[global]
   workgroup = WORKGROUP
   server string = Samba Server %v
   netbios name = $(hostname)
   security = user
   map to guest = bad user
   dns proxy = no

[www]
   path = /var/www/
   browseable = yes
   writeable = yes
   valid users = $samba_username
   create mask = 0644
   directory mask = 0755
   force user = www-data
EOL

# Set Samba password for user
echo -e "$samba_password\n$samba_password" | smbpasswd -a $samba_username

# Configure phpMyAdmin
echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

# Enable Apache modules
a2ensite 000-default.conf
a2enmod rewrite
a2enmod ssl

# Restart services with error handling
services="bind9 apache2 mysql smbd"
for service in $services; do
    systemctl restart $service || log "WARNING: Failed to restart $service"
    systemctl enable $service || log "WARNING: Failed to enable $service"
done

# Test configuration
log "Testing configuration..."
apache2ctl configtest || log "WARNING: Apache config test failed"
named-checkconf || log "WARNING: BIND config test failed"

log "==== Configuration Complete ===="
log "Domain: $user_domain"
log "IP Address: $user_ip"
log "phpMyAdmin URL: http://$user_ip/phpmyadmin"
log "Samba share available at: //$user_ip/www"
log "Samba Username: $samba_username"
EOL
