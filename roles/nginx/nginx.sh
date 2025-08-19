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
