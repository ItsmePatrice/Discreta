#!/bin/bash
set -e

# Update system
dnf update -y

# Install NGINX
dnf install -y nginx

# Create webroot for Certbot ACME challenge (required for webroot validation mode)
mkdir -p /var/www/certbot

# Write HTTP-only NGINX config first (required before Certbot can run)
cat > /etc/nginx/conf.d/discreta.conf << 'EOF'
server {
    listen 80;
    server_name ${domain_name};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}
EOF

# Validate config, then start NGINX so Certbot's webroot challenge can succeed
nginx -t
systemctl enable nginx
systemctl restart nginx

# Install Docker
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install Certbot
dnf install -y python3-pip
pip3 install certbot certbot-nginx

# Request certificate via webroot (NGINX must already be serving port 80 by now)
certbot certonly --webroot -w /var/www/certbot -d ${domain_name} --non-interactive --agree-tos -m patriceammah@gmail.com

# Append HTTPS server block now that cert files exist
cat >> /etc/nginx/conf.d/discreta.conf << 'EOF'

server {
    listen 443 ssl;
    server_name ${domain_name};

    ssl_certificate     /etc/letsencrypt/live/${domain_name}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain_name}/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Reload NGINX with the complete config (starts nothing new, just re-reads config)
nginx -t && systemctl reload nginx

# Install NodeJS
dnf install nodejs -y

mkdir -p /home/ec2-user/app