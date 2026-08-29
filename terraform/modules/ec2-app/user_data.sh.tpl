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

# Install Docker Compose plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

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
        proxy_pass http://127.0.0.1:30000;
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

# Install Git
dnf install git -y

mkdir -p /home/ec2-user/app

cd /home/ec2-user/app

git clone https://github.com/ItsmePatrice/Discreta.git

# Install Kubernetes client
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install conteinerd for Kubernetes
sudo dnf install -y containerd

# configure containerd for Kubernetes
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Kubernetes should use the systemd cgroup driver with containerd
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# restart containerd to apply the new configuration
sudo systemctl restart containerd

# make sure containerd starts automatically after rebout
sudo systemctl enable containerd

# add Kubernetes package repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
EOF

# install Kubeadm
sudo dnf install -y kubelet kubeadm

# enable kubelet
sudo systemctl enable --now kubelet

# initialize the kubernetes cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# configure kubectl so kubectl can communicate with the cluster as ec2-user
mkdir -p /home/ec2-user/.kube
cp /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# Tell kubectl which cluster configuration to use
export KUBECONFIG=/home/ec2-user/.kube/config

# use Flannel as the CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# remove the restriction that prevents from scheduling pods on the controll plane node
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Create Kubernetes secret used to pull private images from Amazon ECR
aws ecr get-login-password --region ca-central-1 | \
  kubectl create secret docker-registry ecr-secret \
    --docker-server=590183781247.dkr.ecr.ca-central-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=-

# Create Kubernetes Service
cat > /home/ec2-user/app/discreta-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: discreta

spec:
  type: NodePort

  selector:
    app: discreta

  ports:
    - protocol: TCP
      port: 30000
      targetPort: 3000
      nodePort: 30000
EOF

kubectl apply -f /home/ec2-user/app/discreta-service.yaml

chown -R ec2-user:ec2-user /home/ec2-user/app