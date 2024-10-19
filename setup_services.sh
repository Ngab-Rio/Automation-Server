#!/bin/bash

set -e

echo "Starting automation script..."

# =========================
# Setup Packages
# =========================

echo "Install packages"
apt install bind9 dnsutils nginx proftpd samba -y

echo "Instaling packages finished..."

# =========================
# Setup Folder
# =========================

echo "Create Folder..."

mkdir -p /home/myCA
mkdir -p /home/myCA/private
mkdir -p /home/myCA/certs
mkdir -p /home/ftp
chown -R uki:uki /home/ftp
mkdir -p /home/datacenter
mkdir -p /home/datapublic

# =========================
# 1. Konfigurasi BIND9
# =========================


echo "Setting up BIND zone files..."
cat > /etc/bind/db.domain <<EOL
; BIND data file for local loopback interface
\$TTL 604800
@    IN    SOA    smkth18760.lab. root.smkth18760.lab. (
              2        ; Serial
         604800        ; Refresh
          86400        ; Retry
        2419200        ; Expire
         604800 )      ; Negative Cache TTL

@       IN    NS    smkth18760.lab.
@       IN    A     192.168.1.118
ns      IN    A     192.168.1.118
uki     IN    A     192.168.1.118
ftp     IN    A     192.168.1.118
EOL

cat > /etc/bind/db.ip <<EOL
; BIND reverse data file for local loopback interface
\$TTL 604800
@    IN    SOA    ns.smkth18760.lab. root.smkth18760.lab. (
              1        ; Serial
         604800        ; Refresh
          86400        ; Retry
        2419200        ; Expire
         604800 )      ; Negative Cache TTL

@       IN  NS    ns.
118     IN  PTR   ns.smkth18760.lab.
EOL


echo "Configuring BIND zone definitions..."
cat >> /etc/bind/named.conf.local <<EOL
zone "smkth18760.lab" {
    type master;
    file "/etc/bind/db.domain";
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.ip";
};
EOL

echo "Configuring BIND options..."
cat >> /etc/bind/named.conf.options <<EOL
options {
	directory "/var/cache/bind";

	// If there is a firewall between you and nameservers you want
	// to talk to, you may need to fix the firewall to allow multiple
	// ports to talk.  See http://www.kb.cert.org/vuls/id/800113

	// If your ISP provided one or more IP addresses for stable 
	// nameservers, you probably want to use them as forwarders.  
	// Uncomment the following block, and insert the addresses replacing 
	// the all-0's placeholder.

	forwarders {
	192.168.1.118;
	};

	//========================================================================
	// If BIND logs error messages about the root key being expired,
	// you will need to update your keys.  See https://www.isc.org/bind-keys
	//========================================================================
	dnssec-validation auto;

	listen-on-v6 { any; };
};
EOL

echo "Reloading and enabling BIND service..."
systemctl reload bind9
systemctl enable bind9
systemctl start bind9

# =========================
# 2. Konfigurasi Nginx
# =========================

echo "Setting up Nginx virtual host configuration..."
cat > /etc/nginx/conf.d/site.conf <<EOL
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    ssl_certificate     /home/myCA/certs/smkth18760.lab.crt;
    ssl_certificate_key /home/myCA/private/smkth18760.lab.key;

    server_name smkth18760.lab;

    root /var/www/smkth18760.lab;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    ssl_certificate     /home/myCA/certs/uki.smkth18760.lab.crt;
    ssl_certificate_key /home/myCA/private/uki.smkth18760.lab.key;

    server_name uki.smkth18760.lab;

    root /var/www/uki.smkth18760.lab;
    index profile.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

cp -r NGINX/WEB/smkth18760.lab /var/www/.
cp -r NGINX/WEB/uki.smkth18760.lab /var/www/.

echo "Reloading and enabling Nginx service..."
systemctl reload nginx
systemctl enable nginx
systemctl start nginx

# =========================
# 3. Konfigurasi Samba
# =========================

echo "Setting up Samba configuration..."
cat >> /etc/samba/smb.conf <<EOL
[datacenter]
path          = /home/datacenter
valid users   = uki
writeable     = yes
browseable    = yes
create mask   = 770

[datapublic]
path          = /home/datapublic
guest ok      = yes
read only     = yes
EOL

echo "Reloading and enabling Samba service..."
systemctl reload smbd
systemctl enable smbd
systemctl start smbd


# =========================
# 4. Konfigurasi proFTPD
# =========================

echo "Setting up ProFTPD configuration..."
cat > /etc/proftpd/proftpd.conf <<EOL
# /etc/proftpd/proftpd.conf -- Simplified configuration

# Includes DSO modules
Include /etc/proftpd/modules.conf

UseIPv6				on
IdentLookups		off

ServerName			"ftp.smkth18760.lab"
ServerType			standalone
DeferWelcome		off

TimeoutNoTransfer	600
TimeoutStalled		600
TimeoutIdle			1200

MaxInstances		30
User				proftpd
Group				nogroup

Umask				022  022
AllowOverwrite		on

TransferLog			/var/log/proftpd/xferlog
SystemLog			/var/log/proftpd/proftpd.log

# Konfigurasi untuk pengguna yang bisa membuat folder
<Anonymous /home/ftp>
   User				uki
   Group			uki
   <Limit WRITE>
       AllowAll
   </Limit>
</Anonymous>

# Memberikan izin untuk membuat folder di direktori tertentu
<Directory /home/ftp>
   <Limit WRITE>
       AllowAll
   </Limit>
   <Limit MKD>
       AllowAll
   </Limit>
</Directory>

Include /etc/proftpd/conf.d/
EOL

echo "Reloading and enabling ProFTPD service..."
systemctl reload proftpd
systemctl enable proftpd
systemctl start proftpd


# =========================
# 5. Konfigurasi resolv
# =========================

echo "Configuring resolv.conf"
cat > /etc/resolv.conf <<EOL
nameserver 192.168.1.118
search smkth18760.lab
search uki.smkth18760.lab
EOL


echo "All configurations completed successfully!"