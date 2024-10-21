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
