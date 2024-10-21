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
