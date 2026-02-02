#!/bin/bash
echo "GLKVM cloud is building..."

# Initialize platform variable
PLATFORM="unknown"

# Detect operating system type
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_ID_LIKE=$ID_LIKE
else
    echo "Cannot determine OS. Exiting."
    exit 1
fi

# Debian/Ubuntu series
if [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID_LIKE" == *"debian"* ]]; then
    export DEBIAN_FRONTEND=noninteractive

    # If needrestart exists, set automatic restart mode (a = automatic)
    if [ -f /etc/needrestart/needrestart.conf ]; then
        sed -i \
        -e "s/^\s*#\?\s*\$nrconf{restart}.*/\$nrconf{restart} = 'a';/" \
        /etc/needrestart/needrestart.conf || true
    fi
    PLATFORM="debian"
    echo "Detected Debian-based system: $PRETTY_NAME"

    apt update
    apt install -y docker.io docker-compose curl ufw

    # Firewall rules
    ufw allow 443/tcp
    ufw allow 10443/tcp
    ufw allow 5912/tcp
    ufw allow 3478/tcp
    ufw allow 3478/udp
    echo "Firewall rules updated via UFW."

# RedHat/CentOS/AlmaLinux series
elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "almalinux" || "$OS_ID" == "rocky" || "$OS_ID_LIKE" == *"rhel"* ]]; then
    PLATFORM="redhat"
    echo "Detected Red Hat-based system: $PRETTY_NAME"

    dnf makecache
    dnf install -y curl dnf-plugins-core

    # Add Docker repository
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Install Docker
    dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Enable service
    systemctl enable --now docker

    # Firewall rules
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=10443/tcp
    firewall-cmd --permanent --add-port=5912/tcp
    firewall-cmd --permanent --add-port=3478/tcp
    firewall-cmd --permanent --add-port=3478/udp
    firewall-cmd --reload
    echo "Firewall rules updated via firewalld."

else
    echo "Unsupported OS: $PRETTY_NAME"
    exit 1
fi

# ✅ Output platform marker (subsequent logic can use $PLATFORM to check)
echo "Platform detected: $PLATFORM"


GLKVM_DIR="$PWD/glkvm_cloud"

if [ ! -d "$GLKVM_DIR" ]; then
    mkdir -p "$GLKVM_DIR"
    echo "Created directory: $GLKVM_DIR"
else
    echo "Directory already exists: $GLKVM_DIR"
fi


BASE_DOMAIN="https://kvm-cloud.gl-inet.com"

IMAGE_URL="$BASE_DOMAIN/selfhost/glkvmcloud.tar"
IMAGE_PATH="$GLKVM_DIR/glkvm-cloud.tar"
echo "Downloading Docker image from: $IMAGE_URL"
curl -L -o "$IMAGE_PATH" "$IMAGE_URL"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download image. Please check network or URL."
    exit 1
fi
echo "Downloaded image to: $IMAGE_PATH"


COTURN_URL="$BASE_DOMAIN/selfhost/glkvmcoturn.tar"
COTURN_PATH="$GLKVM_DIR/glkvm-coturn.tar"
echo "Downloading Docker image from: $COTURN_URL"
curl -L -o "$COTURN_PATH" "$COTURN_URL"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download image. Please check network or URL."
    exit 1
fi
echo "Downloaded image to: $COTURN_PATH"

echo "Importing Docker image..."
docker load -i "$IMAGE_PATH"
docker load -i "$COTURN_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Docker image imported successfully."
else
    echo "❌ Docker image import failed."
    exit 1
fi

DOCKER_COMPOSE_URL="$BASE_DOMAIN/selfhost/docker-compose.tar.gz"
DOCKER_COMPOSE_PATH="$GLKVM_DIR/docker-compose.tar.gz"

echo "Downloading docker-compose package from: $DOCKER_COMPOSE_URL"
curl -L -o "$DOCKER_COMPOSE_PATH" "$DOCKER_COMPOSE_URL"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download docker-compose package. Please check network or URL."
    exit 1
fi
echo "Downloaded docker-compose package to: $DOCKER_COMPOSE_PATH"

# Extract docker-compose.tar.gz into current directory
echo "Extracting docker-compose package..."
tar -xzf "$DOCKER_COMPOSE_PATH" -C "$GLKVM_DIR"
if [ $? -eq 0 ]; then
    echo "✅ docker-compose package extracted successfully."
else
    echo "❌ Failed to extract docker-compose package."
    exit 1
fi

cd "$GLKVM_DIR" || exit 1

# Prepare .env file
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists, skipping copy."
else
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
fi

get_public_ip() {
    ip=$(curl -s --max-time 5 https://api.ipify.org)
    if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
    fi

    ip=$(curl -s --max-time 5 https://ifconfig.me)
    if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
    fi

    return 1
}

PUBLIC_IP=$(get_public_ip)
if [[ -z "$PUBLIC_IP" ]]; then
    echo "❌ Failed to get public IP from both sources. Please check your network."
    exit 1
fi

echo "Detected public IP: $PUBLIC_IP"


generate_random_string() {
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32
}

TOKEN=$(generate_random_string)
PASSWORD=$(generate_random_string)
WEBRTC_USERNAME=$(generate_random_string)
WEBRTC_PASSWORD=$(generate_random_string)


# Replace placeholders in .env with generated variables
sed -i "s|^RTTYS_TOKEN=.*|RTTYS_TOKEN=$TOKEN|" .env
sed -i "s|^RTTYS_PASS=.*|RTTYS_PASS=$PASSWORD|" .env
sed -i "s|^TURN_USER=.*|TURN_USER=$WEBRTC_USERNAME|" .env
sed -i "s|^TURN_PASS=.*|TURN_PASS=$WEBRTC_PASSWORD|" .env
sed -i "s|^GLKVM_ACCESS_IP=.*|GLKVM_ACCESS_IP=$PUBLIC_IP|" .env

echo "✅ Updated .env with generated credentials."

if [ "$PLATFORM" = "debian" ]; then
    cd $GLKVM_DIR && docker-compose up -d
   
else
    cd $GLKVM_DIR && docker compose up -d
fi
echo ""
echo "✅ GLKVM Cloud has been successfully initialized at:"
echo "   $GLKVM_DIR"
echo ""
echo "   If your server provider enforces a cloud security group (e.g., on AWS, Aliyun, etc.),"
echo "   please ensure the following ports are allowed through:"
echo ""
echo "     - 443/TCP       (Web UI access)"
echo "     - 10443/TCP     (Device Web remote access)"
echo "     - 5912/TCP      (Device connection)"
echo "     - 3478/TCP/UDP  (TURN server for WebRTC)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Web Access:"
echo ""
echo "   🌐 You can now access the GLKVM Cloud platform via:"
echo "       https://$PUBLIC_IP"
echo ""
echo "   ⚠️  Note: Accessing via IP will trigger a browser certificate warning."
echo "       To remove this warning, please configure your own domain and SSL certificate."
echo ""
echo "   🔑 Web UI password:"
echo "       $PASSWORD"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

