#!/usr/bin/env bash
# =========================================================
# GLKVM Cloud - Interactive Installer
# =========================================================
# A comprehensive installer with two deployment modes:
#
# 1. Standard Mode: Quick setup with self-signed certificates
#    - Best for testing or internal networks
#    - Access via IP address
#
# 2. Traefik Mode: Production setup with Let's Encrypt + CrowdSec
#    - Automatic TLS certificates (including wildcard)
#    - Brute-force protection via CrowdSec
#    - Requires a domain name
#
# Usage: sudo bash installer-interactive.sh
# =========================================================

# Ensure we're running in bash, not sh
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash. Please run with: sudo bash $0"
    exit 1
fi

set -e

# =========================================================
# Configuration
# =========================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/Source/docker-compose"
INSTALL_DIR="${SCRIPT_DIR}/glkvm_cloud"
DEFAULT_SERVICE_USER="glkvm"
SERVICE_USER=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# =========================================================
# Helper Functions
# =========================================================

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║              GLKVM Cloud Interactive Installer                ║"
    echo "║                                                               ║"
    echo "║          Remote KVM Device Management Platform                ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_substep() {
    echo -e "${CYAN}  → $1${NC}"
}

print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}  ✗ $1${NC}"
}

print_info() {
    echo -e "${MAGENTA}  ℹ $1${NC}"
}

prompt() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="$3"
    local is_secret="$4"

    if [ -n "$default_value" ]; then
        prompt_text="${prompt_text} [${default_value}]"
    fi

    if [ "$is_secret" = "true" ]; then
        read -sp "    ${prompt_text}: " value
        echo ""
    else
        read -p "    ${prompt_text}: " value
    fi

    if [ -z "$value" ] && [ -n "$default_value" ]; then
        value="$default_value"
    fi

    eval "$var_name=\"$value\""
}

prompt_yes_no() {
    local prompt_text="$1"
    local default="$2"

    if [ "$default" = "y" ]; then
        prompt_text="${prompt_text} [Y/n]"
    else
        prompt_text="${prompt_text} [y/N]"
    fi

    read -p "    ${prompt_text}: " response

    if [ -z "$response" ]; then
        response="$default"
    fi

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

generate_password() {
    local length="${1:-32}"
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length" 2>/dev/null || \
    openssl rand -base64 "$length" 2>/dev/null | tr -dc 'a-zA-Z0-9' | head -c "$length" || \
    date +%s%N | sha256sum | head -c "$length"
}

get_public_ip() {
    local ip=""

    ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        return 0
    fi

    ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null)
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        return 0
    fi

    ip=$(dig +short -4 myip.opendns.com @resolver1.opendns.com 2>/dev/null)
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        return 0
    fi

    return 1
}

detect_architecture() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# =========================================================
# System Setup Functions
# =========================================================

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_error "This script must be run as root (use: sudo bash $0)"
        exit 1
    fi
}

check_source_files() {
    if [ ! -d "$SOURCE_DIR" ]; then
        print_error "Source directory not found: $SOURCE_DIR"
        echo "    Please ensure the Source/docker-compose folder exists."
        exit 1
    fi
}

configure_service_user() {
    print_step "Service User Configuration"

    echo -e "    ${BOLD}Security Best Practice${NC}"
    echo "    Running Docker services as a dedicated non-root user improves security."
    echo "    The installer can create a service user to own and manage GLKVM Cloud."
    echo ""

    if prompt_yes_no "Create a dedicated service user for GLKVM Cloud?" "y"; then
        CREATE_SERVICE_USER="true"

        prompt SERVICE_USER "Service username" "$DEFAULT_SERVICE_USER"

        # Validate username
        if [[ ! "$SERVICE_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            print_error "Invalid username. Using default: $DEFAULT_SERVICE_USER"
            SERVICE_USER="$DEFAULT_SERVICE_USER"
        fi
    else
        CREATE_SERVICE_USER="false"
        SERVICE_USER="root"
        print_warning "Services will run as root (not recommended for production)"
    fi
}

create_service_user() {
    if [ "$CREATE_SERVICE_USER" != "true" ]; then
        return 0
    fi

    print_substep "Creating service user: $SERVICE_USER..."

    # Check if user already exists
    if id "$SERVICE_USER" &>/dev/null; then
        print_warning "User '$SERVICE_USER' already exists"
    else
        # Create user with no login shell and no home directory login
        if [ "$PLATFORM" = "debian" ]; then
            useradd -r -s /usr/sbin/nologin -M "$SERVICE_USER" 2>/dev/null || \
            useradd -r -s /bin/false -M "$SERVICE_USER" 2>/dev/null || true
        else
            useradd -r -s /sbin/nologin -M "$SERVICE_USER" 2>/dev/null || \
            useradd -r -s /bin/false -M "$SERVICE_USER" 2>/dev/null || true
        fi

        if id "$SERVICE_USER" &>/dev/null; then
            print_success "Created user: $SERVICE_USER"
        else
            print_error "Failed to create user: $SERVICE_USER"
            print_warning "Falling back to root"
            SERVICE_USER="root"
            CREATE_SERVICE_USER="false"
            return 0
        fi
    fi

    # Add user to docker group
    print_substep "Adding $SERVICE_USER to docker group..."

    if getent group docker > /dev/null 2>&1; then
        usermod -aG docker "$SERVICE_USER" 2>/dev/null || true
        print_success "Added $SERVICE_USER to docker group"
    else
        print_warning "Docker group not found - creating it"
        groupadd docker 2>/dev/null || true
        usermod -aG docker "$SERVICE_USER" 2>/dev/null || true
    fi

    # Get user's UID and GID for later use
    SERVICE_USER_UID=$(id -u "$SERVICE_USER" 2>/dev/null || echo "")
    SERVICE_USER_GID=$(id -g "$SERVICE_USER" 2>/dev/null || echo "")
}

set_directory_ownership() {
    if [ "$CREATE_SERVICE_USER" != "true" ] || [ -z "$SERVICE_USER" ] || [ "$SERVICE_USER" = "root" ]; then
        return 0
    fi

    print_substep "Setting ownership of $INSTALL_DIR to $SERVICE_USER..."

    chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR" 2>/dev/null || \
    chown -R "$SERVICE_USER" "$INSTALL_DIR" 2>/dev/null || true

    # Ensure proper permissions
    chmod -R u+rw "$INSTALL_DIR" 2>/dev/null || true

    print_success "Directory ownership set to $SERVICE_USER"
}

run_as_service_user() {
    local cmd="$1"

    if [ "$CREATE_SERVICE_USER" = "true" ] && [ -n "$SERVICE_USER" ] && [ "$SERVICE_USER" != "root" ]; then
        # Run command as service user
        su - "$SERVICE_USER" -s /bin/bash -c "cd $INSTALL_DIR && $cmd" 2>/dev/null || \
        sudo -u "$SERVICE_USER" bash -c "cd $INSTALL_DIR && $cmd" 2>/dev/null || \
        eval "cd $INSTALL_DIR && $cmd"
    else
        eval "cd $INSTALL_DIR && $cmd"
    fi
}

detect_os() {
    print_substep "Detecting operating system..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_ID_LIKE=$ID_LIKE
        OS_PRETTY_NAME=$PRETTY_NAME
    else
        print_error "Cannot determine OS. /etc/os-release not found."
        exit 1
    fi

    if [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID_LIKE" == *"debian"* ]]; then
        PLATFORM="debian"
        COMPOSE_CMD="docker-compose"
    elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "almalinux" || "$OS_ID" == "rocky" || "$OS_ID_LIKE" == *"rhel"* ]]; then
        PLATFORM="redhat"
        COMPOSE_CMD="docker compose"
    else
        print_error "Unsupported OS: $OS_PRETTY_NAME"
        echo "    Supported: Debian, Ubuntu, CentOS, RHEL, AlmaLinux, Rocky Linux"
        exit 1
    fi

    print_success "Detected: $OS_PRETTY_NAME ($PLATFORM)"
}

install_dependencies() {
    print_substep "Installing dependencies..."

    if [ "$PLATFORM" = "debian" ]; then
        export DEBIAN_FRONTEND=noninteractive

        # Configure needrestart for automatic restarts
        if [ -f /etc/needrestart/needrestart.conf ]; then
            sed -i -e "s/^\s*#\?\s*\$nrconf{restart}.*/\$nrconf{restart} = 'a';/" \
                /etc/needrestart/needrestart.conf 2>/dev/null || true
        fi

        apt-get update -qq
        apt-get install -y -qq docker.io docker-compose curl ufw > /dev/null 2>&1

        print_success "Installed: docker, docker-compose, curl, ufw"

    elif [ "$PLATFORM" = "redhat" ]; then
        dnf makecache -q
        dnf install -y -q curl dnf-plugins-core > /dev/null 2>&1

        # Add Docker repository if not present
        if ! dnf repolist | grep -q docker-ce; then
            dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1
        fi

        dnf install -y -q docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null 2>&1
        systemctl enable --now docker > /dev/null 2>&1

        print_success "Installed: docker, docker-compose-plugin, curl"
    fi
}

configure_firewall() {
    print_substep "Configuring firewall..."

    local ports_standard="443/tcp 10443/tcp 5912/tcp 3478/tcp 3478/udp"
    local ports_traefik="80/tcp 443/tcp 5912/tcp 3478/tcp 3478/udp"

    if [ "$INSTALL_MODE" = "traefik" ]; then
        FIREWALL_PORTS="$ports_traefik"
    else
        FIREWALL_PORTS="$ports_standard"
    fi

    if [ "$PLATFORM" = "debian" ]; then
        for port in $FIREWALL_PORTS; do
            ufw allow "$port" > /dev/null 2>&1 || true
        done
        print_success "UFW rules configured"

    elif [ "$PLATFORM" = "redhat" ]; then
        for port in $FIREWALL_PORTS; do
            firewall-cmd --permanent --add-port="$port" > /dev/null 2>&1 || true
        done
        firewall-cmd --reload > /dev/null 2>&1 || true
        print_success "Firewalld rules configured"
    fi
}

# =========================================================
# Installation Mode Selection
# =========================================================

select_install_mode() {
    print_step "Select Installation Mode"

    echo -e "    ${BOLD}1) Standard Installation${NC}"
    echo "       • Self-signed TLS certificate"
    echo "       • Access via IP address"
    echo "       • Quick setup for testing/internal use"
    echo ""
    echo -e "    ${BOLD}2) Traefik + Let's Encrypt + CrowdSec${NC}"
    echo "       • Automatic TLS certificates from Let's Encrypt"
    echo "       • Wildcard certificate support for device subdomains"
    echo "       • CrowdSec brute-force protection"
    echo "       • Requires a domain name"
    echo ""

    while true; do
        read -p "    Select mode [1/2]: " mode_choice
        case "$mode_choice" in
            1)
                INSTALL_MODE="standard"
                print_success "Selected: Standard Installation"
                break
                ;;
            2)
                INSTALL_MODE="traefik"
                print_success "Selected: Traefik + Let's Encrypt + CrowdSec"
                break
                ;;
            *)
                print_error "Invalid selection. Please enter 1 or 2."
                ;;
        esac
    done
}

# =========================================================
# Standard Installation
# =========================================================

configure_standard() {
    print_step "Standard Installation Configuration"

    # Get public IP
    print_substep "Detecting public IP address..."
    PUBLIC_IP=$(get_public_ip)
    if [ -z "$PUBLIC_IP" ]; then
        print_warning "Could not auto-detect public IP"
        prompt PUBLIC_IP "Enter your server's public IP address" ""
    else
        print_success "Detected public IP: $PUBLIC_IP"
        if ! prompt_yes_no "Use this IP address?" "y"; then
            prompt PUBLIC_IP "Enter your server's public IP address" "$PUBLIC_IP"
        fi
    fi

    # Generate credentials
    print_substep "Generating secure credentials..."

    RTTYS_TOKEN=$(generate_password 32)
    RTTYS_PASS=$(generate_password 16)
    TURN_USER="glkvmwebrtc$(generate_password 8)"
    TURN_PASS=$(generate_password 24)

    print_success "Credentials generated"

    # Optional: Custom credentials
    if prompt_yes_no "Would you like to customize the credentials?" "n"; then
        echo ""
        prompt RTTYS_PASS "Web UI password" "$RTTYS_PASS"
        prompt RTTYS_TOKEN "Device connection token" "$RTTYS_TOKEN"
    fi

    # Architecture-specific images
    ARCH=$(detect_architecture)
    if [ "$ARCH" = "arm64" ]; then
        GLKVM_IMAGE="glzhitong/glkvm-cloud:latest-arm64"
        COTURN_IMAGE="coturn/coturn:edge-alpine-arm64v8"
    else
        GLKVM_IMAGE="glzhitong/glkvm-cloud:latest"
        COTURN_IMAGE="coturn/coturn:edge-alpine"
    fi
}

install_standard() {
    print_step "Installing Standard Mode"

    # Create installation directory
    print_substep "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    print_success "Created: $INSTALL_DIR"

    # Copy files
    print_substep "Copying configuration files..."
    cp -r "$SOURCE_DIR"/* "$INSTALL_DIR/"

    # Remove Traefik-specific files (not needed in standard mode)
    rm -rf "$INSTALL_DIR/traefik" "$INSTALL_DIR/crowdsec" \
           "$INSTALL_DIR/docker-compose.traefik.yml" \
           "$INSTALL_DIR/.env.traefik.example" \
           "$INSTALL_DIR/install-traefik.sh" 2>/dev/null || true

    print_success "Configuration files copied"

    # Generate .env
    print_substep "Generating environment configuration..."

    cat > "$INSTALL_DIR/.env" << EOF
# GLKVM Cloud Configuration
# Generated by installer-interactive.sh on $(date)

# Images
GLKVM_IMAGE=${GLKVM_IMAGE}
COTURN_IMAGE=${COTURN_IMAGE}

# Server Access
GLKVM_ACCESS_IP=${PUBLIC_IP}

# Credentials
RTTYS_TOKEN=${RTTYS_TOKEN}
RTTYS_PASS=${RTTYS_PASS}

# Ports
RTTYS_DEVICE_PORT=5912
RTTYS_WEBUI_PORT=443
RTTYS_HTTP_PROXY_PORT=10443

# TURN Server (WebRTC)
TURN_PORT=3478
TURN_USER=${TURN_USER}
TURN_PASS=${TURN_PASS}

# Reverse Proxy (disabled in standard mode)
REVERSE_PROXY_ENABLED=false
DEVICE_ENDPOINT_HOST=
WEB_UI_HOST=

# LDAP (disabled by default)
LDAP_ENABLED=false
LDAP_SERVER=
LDAP_PORT=389
LDAP_USE_TLS=false
LDAP_BIND_DN=
LDAP_BIND_PASSWORD=
LDAP_BASE_DN=
LDAP_USER_FILTER=(uid=%s)
LDAP_ALLOWED_GROUPS=
LDAP_ALLOWED_USERS=

# OIDC (disabled by default)
OIDC_ENABLED=false
OIDC_ISSUER=
OIDC_CLIENT_ID=
OIDC_CLIENT_SECRET=
OIDC_AUTH_URL=
OIDC_TOKEN_URL=
OIDC_REDIRECT_URL=
OIDC_SCOPES=openid profile email
OIDC_ALLOWED_USERS=
OIDC_ALLOWED_SUBS=
OIDC_ALLOWED_USERNAMES=
OIDC_ALLOWED_GROUPS=
EOF

    print_success "Environment configuration created"

    # Set directory ownership
    set_directory_ownership

    # Start services
    print_substep "Starting GLKVM Cloud services..."
    cd "$INSTALL_DIR"

    if [ "$CREATE_SERVICE_USER" = "true" ] && [ "$SERVICE_USER" != "root" ]; then
        # Run docker-compose as service user
        sudo -u "$SERVICE_USER" $COMPOSE_CMD up -d > /dev/null 2>&1 || \
        $COMPOSE_CMD up -d > /dev/null 2>&1
    else
        $COMPOSE_CMD up -d > /dev/null 2>&1
    fi

    print_success "Services started"

    # Summary
    COMPOSE_FILE="docker-compose.yml"
}

# =========================================================
# Traefik Installation
# =========================================================

configure_traefik() {
    print_step "Traefik + Let's Encrypt Configuration"

    # Domain
    echo -e "    ${BOLD}Domain Configuration${NC}"
    echo "    Your GLKVM Cloud will be accessible at:"
    echo "      • Web UI: https://www.<domain> and https://<domain>"
    echo "      • Devices: https://<device-id>.<domain>"
    echo ""

    prompt DOMAIN "Enter your domain (e.g., kvm.example.com)" ""
    while [ -z "$DOMAIN" ]; do
        print_error "Domain is required for Traefik mode"
        prompt DOMAIN "Enter your domain" ""
    done

    # Email for Let's Encrypt
    echo ""
    echo -e "    ${BOLD}Let's Encrypt Configuration${NC}"
    prompt ACME_EMAIL "Email for certificate notifications" ""
    while [ -z "$ACME_EMAIL" ]; do
        print_error "Email is required for Let's Encrypt"
        prompt ACME_EMAIL "Email address" ""
    done

    # DNS Provider
    echo ""
    echo -e "    ${BOLD}DNS Provider (for wildcard certificates)${NC}"
    echo "    Select your DNS provider:"
    echo ""
    echo "      1) DigitalOcean"
    echo "      2) Cloudflare"
    echo "      3) AWS Route53"
    echo "      4) Google Cloud DNS"
    echo ""

    while true; do
        read -p "    Select provider [1-4]: " dns_choice
        case "$dns_choice" in
            1)
                DNS_PROVIDER="digitalocean"
                echo ""
                echo "    Create a token at: https://cloud.digitalocean.com/account/api/tokens"
                prompt DO_AUTH_TOKEN "DigitalOcean API token" "" "true"
                break
                ;;
            2)
                DNS_PROVIDER="cloudflare"
                echo ""
                echo "    Create a token at: https://dash.cloudflare.com/profile/api-tokens"
                echo "    Use the 'Edit zone DNS' template"
                prompt CF_DNS_API_TOKEN "Cloudflare API token" "" "true"
                break
                ;;
            3)
                DNS_PROVIDER="route53"
                echo ""
                echo "    You need AWS credentials with Route53 permissions"
                prompt AWS_ACCESS_KEY_ID "AWS Access Key ID" ""
                prompt AWS_SECRET_ACCESS_KEY "AWS Secret Access Key" "" "true"
                prompt AWS_REGION "AWS Region" "us-east-1"
                break
                ;;
            4)
                DNS_PROVIDER="gcloud"
                echo ""
                echo "    You need a GCP service account with DNS admin permissions"
                prompt GCE_PROJECT "GCP Project ID" ""
                prompt GCE_SERVICE_ACCOUNT_FILE "Path to service account JSON" ""
                break
                ;;
            *)
                print_error "Invalid selection"
                ;;
        esac
    done

    # Public IP (for TURN/WebRTC)
    echo ""
    print_substep "Detecting public IP for WebRTC..."
    PUBLIC_IP=$(get_public_ip)
    if [ -n "$PUBLIC_IP" ]; then
        print_success "Detected: $PUBLIC_IP"
    else
        prompt PUBLIC_IP "Enter your server's public IP" ""
    fi

    # Credentials
    echo ""
    echo -e "    ${BOLD}GLKVM Cloud Credentials${NC}"

    RTTYS_TOKEN=$(generate_password 32)
    RTTYS_PASS=$(generate_password 16)
    TURN_USER="glkvmwebrtc$(generate_password 8)"
    TURN_PASS=$(generate_password 24)

    if prompt_yes_no "Customize credentials? (default: auto-generated)" "n"; then
        prompt RTTYS_PASS "Web UI password" "$RTTYS_PASS"
        prompt RTTYS_TOKEN "Device token" "$RTTYS_TOKEN"
    fi

    # Traefik Dashboard
    echo ""
    echo -e "    ${BOLD}Traefik Dashboard (Optional)${NC}"
    if prompt_yes_no "Enable Traefik dashboard at https://traefik.${DOMAIN}?" "n"; then
        ENABLE_DASHBOARD="true"
        prompt DASHBOARD_USER "Dashboard username" "admin"
        prompt DASHBOARD_PASS "Dashboard password" "" "true"
        if [ -z "$DASHBOARD_PASS" ]; then
            DASHBOARD_PASS=$(generate_password 16)
            echo "    Generated password: $DASHBOARD_PASS"
        fi

        # Generate htpasswd
        SALT=$(openssl rand -base64 8 | tr -dc 'a-zA-Z0-9' | head -c 8)
        HASH=$(openssl passwd -apr1 -salt "$SALT" "$DASHBOARD_PASS" 2>/dev/null)
        TRAEFIK_DASHBOARD_AUTH=$(echo "${DASHBOARD_USER}:${HASH}" | sed 's/\$/\$\$/g')
    else
        ENABLE_DASHBOARD="false"
        TRAEFIK_DASHBOARD_AUTH='admin:$$apr1$$disabled$$x'
    fi

    # Architecture-specific images
    ARCH=$(detect_architecture)
    if [ "$ARCH" = "arm64" ]; then
        GLKVM_IMAGE="glzhitong/glkvm-cloud:latest-arm64"
        COTURN_IMAGE="coturn/coturn:edge-alpine-arm64v8"
    else
        GLKVM_IMAGE="glzhitong/glkvm-cloud:latest"
        COTURN_IMAGE="coturn/coturn:edge-alpine"
    fi
}

install_traefik() {
    print_step "Installing Traefik Mode"

    # Create installation directory
    print_substep "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    print_success "Created: $INSTALL_DIR"

    # Copy all files (including Traefik configs)
    print_substep "Copying configuration files..."
    cp -r "$SOURCE_DIR"/* "$INSTALL_DIR/"
    print_success "Configuration files copied"

    # Update Traefik config for DNS provider
    print_substep "Configuring DNS provider: $DNS_PROVIDER..."
    sed -i "s/provider: digitalocean/provider: $DNS_PROVIDER/" \
        "$INSTALL_DIR/traefik/traefik.yml" 2>/dev/null || true
    print_success "DNS provider configured"

    # Generate .env
    print_substep "Generating environment configuration..."

    # Generate escaped domain for Traefik v3 HostRegexp (escape dots)
    # e.g., example.com -> example\.com
    DOMAIN_REGEXP=$(printf '%s' "$DOMAIN" | sed 's/\./\\./g')

    cat > "$INSTALL_DIR/.env" << EOF
# GLKVM Cloud - Traefik Mode Configuration
# Generated by installer-interactive.sh on $(date)

# Domain & Certificates
DOMAIN=${DOMAIN}
DOMAIN_REGEXP=${DOMAIN_REGEXP}
ACME_EMAIL=${ACME_EMAIL}

# DNS Provider: ${DNS_PROVIDER}
EOF

    # Add DNS provider credentials
    case "$DNS_PROVIDER" in
        digitalocean)
            echo "DO_AUTH_TOKEN=${DO_AUTH_TOKEN}" >> "$INSTALL_DIR/.env"
            ;;
        cloudflare)
            echo "CF_DNS_API_TOKEN=${CF_DNS_API_TOKEN}" >> "$INSTALL_DIR/.env"
            ;;
        route53)
            cat >> "$INSTALL_DIR/.env" << EOF
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION=${AWS_REGION}
EOF
            ;;
        gcloud)
            cat >> "$INSTALL_DIR/.env" << EOF
GCE_PROJECT=${GCE_PROJECT}
GCE_SERVICE_ACCOUNT_FILE=${GCE_SERVICE_ACCOUNT_FILE}
EOF
            ;;
    esac

    cat >> "$INSTALL_DIR/.env" << EOF

# CrowdSec (auto-generated after startup)
CROWDSEC_BOUNCER_API_KEY=

# Traefik Dashboard
TRAEFIK_DASHBOARD_AUTH=${TRAEFIK_DASHBOARD_AUTH}

# Images
GLKVM_IMAGE=${GLKVM_IMAGE}
COTURN_IMAGE=${COTURN_IMAGE}

# Server Access (for WebRTC)
GLKVM_ACCESS_IP=${PUBLIC_IP}

# Credentials
RTTYS_TOKEN=${RTTYS_TOKEN}
RTTYS_PASS=${RTTYS_PASS}

# Ports (internal - Traefik handles 80/443)
RTTYS_DEVICE_PORT=5912
RTTYS_WEBUI_PORT=1443
RTTYS_HTTP_PROXY_PORT=10443

# TURN Server (WebRTC)
TURN_PORT=3478
TURN_USER=${TURN_USER}
TURN_PASS=${TURN_PASS}

# Domain Configuration
# Note: WEB_UI_HOST should be the base domain (not www.) so both
# kvm.example.com AND www.kvm.example.com are allowed
DEVICE_ENDPOINT_HOST=${DOMAIN}
WEB_UI_HOST=${DOMAIN}

# LDAP (disabled by default)
LDAP_ENABLED=false
LDAP_SERVER=
LDAP_PORT=389
LDAP_USE_TLS=false
LDAP_BIND_DN=
LDAP_BIND_PASSWORD=
LDAP_BASE_DN=
LDAP_USER_FILTER=(uid=%s)
LDAP_ALLOWED_GROUPS=
LDAP_ALLOWED_USERS=

# OIDC (disabled by default)
OIDC_ENABLED=false
OIDC_ISSUER=
OIDC_CLIENT_ID=
OIDC_CLIENT_SECRET=
OIDC_AUTH_URL=
OIDC_TOKEN_URL=
OIDC_REDIRECT_URL=
OIDC_SCOPES=openid profile email
OIDC_ALLOWED_USERS=
OIDC_ALLOWED_SUBS=
OIDC_ALLOWED_USERNAMES=
OIDC_ALLOWED_GROUPS=
EOF

    print_success "Environment configuration created"

    # Set directory ownership
    set_directory_ownership

    # Start services
    print_substep "Starting GLKVM Cloud services..."
    cd "$INSTALL_DIR"

    if [ "$CREATE_SERVICE_USER" = "true" ] && [ "$SERVICE_USER" != "root" ]; then
        # Run docker-compose as service user
        sudo -u "$SERVICE_USER" $COMPOSE_CMD -f docker-compose.traefik.yml up -d > /dev/null 2>&1 || \
        $COMPOSE_CMD -f docker-compose.traefik.yml up -d > /dev/null 2>&1
    else
        $COMPOSE_CMD -f docker-compose.traefik.yml up -d > /dev/null 2>&1
    fi

    print_success "Services started"

    # Wait for CrowdSec and generate bouncer key
    print_substep "Waiting for CrowdSec to initialize..."
    sleep 15

    print_substep "Generating CrowdSec bouncer API key..."
    BOUNCER_KEY=$(docker exec glkvm_crowdsec cscli bouncers add traefik-bouncer -o raw 2>/dev/null || echo "")

    if [ -n "$BOUNCER_KEY" ]; then
        sed -i "s/^CROWDSEC_BOUNCER_API_KEY=.*/CROWDSEC_BOUNCER_API_KEY=${BOUNCER_KEY}/" "$INSTALL_DIR/.env"
        print_success "CrowdSec bouncer key generated"

        print_substep "Restarting services with CrowdSec protection..."
        if [ "$CREATE_SERVICE_USER" = "true" ] && [ "$SERVICE_USER" != "root" ]; then
            sudo -u "$SERVICE_USER" $COMPOSE_CMD -f docker-compose.traefik.yml restart traefik crowdsec-bouncer > /dev/null 2>&1 || \
            $COMPOSE_CMD -f docker-compose.traefik.yml restart traefik crowdsec-bouncer > /dev/null 2>&1
        else
            $COMPOSE_CMD -f docker-compose.traefik.yml restart traefik crowdsec-bouncer > /dev/null 2>&1
        fi
        print_success "CrowdSec protection activated"
    else
        print_warning "Could not auto-generate CrowdSec key"
        echo "    Run manually: docker exec glkvm_crowdsec cscli bouncers add traefik-bouncer"
    fi

    COMPOSE_FILE="docker-compose.traefik.yml"
}

# =========================================================
# Summary
# =========================================================

print_summary_standard() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}            ${GREEN}Installation Complete!${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Access Information:${NC}"
    echo ""
    echo -e "    ${GREEN}Web UI:${NC}         https://${PUBLIC_IP}"
    echo -e "    ${GREEN}Device Port:${NC}    ${PUBLIC_IP}:5912 (TCP)"
    echo -e "    ${GREEN}TURN Port:${NC}      ${PUBLIC_IP}:3478 (TCP/UDP)"
    echo ""
    echo -e "${BOLD}Credentials:${NC}"
    echo ""
    echo -e "    ${GREEN}Web Password:${NC}   ${RTTYS_PASS}"
    echo -e "    ${GREEN}Device Token:${NC}   ${RTTYS_TOKEN}"
    echo ""
    echo -e "${YELLOW}Note:${NC} Accessing via IP will show a browser certificate warning."
    echo "      For production use, consider the Traefik installation mode."
    echo ""
}

print_summary_traefik() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}            ${GREEN}Installation Complete!${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Access Information:${NC}"
    echo ""
    echo -e "    ${GREEN}Web UI:${NC}         https://www.${DOMAIN}"
    echo -e "    ${GREEN}Web UI:${NC}         https://${DOMAIN}"
    echo -e "    ${GREEN}Devices:${NC}        https://<device-id>.${DOMAIN}"
    if [ "$ENABLE_DASHBOARD" = "true" ]; then
        echo -e "    ${GREEN}Traefik:${NC}        https://traefik.${DOMAIN}"
    fi
    echo ""
    echo -e "    ${GREEN}Device Port:${NC}    ${DOMAIN}:5912 (TCP)"
    echo -e "    ${GREEN}TURN Port:${NC}      ${DOMAIN}:3478 (TCP/UDP)"
    echo ""
    echo -e "${BOLD}Credentials:${NC}"
    echo ""
    echo -e "    ${GREEN}Web Password:${NC}   ${RTTYS_PASS}"
    echo -e "    ${GREEN}Device Token:${NC}   ${RTTYS_TOKEN}"
    if [ "$ENABLE_DASHBOARD" = "true" ]; then
        echo -e "    ${GREEN}Dashboard:${NC}      ${DASHBOARD_USER}"
    fi
    echo ""
    echo -e "${YELLOW}Required DNS Records:${NC}"
    echo ""
    echo "    Add these A records pointing to your server IP (${PUBLIC_IP}):"
    echo ""
    echo "      ${DOMAIN}           →  ${PUBLIC_IP}"
    echo "      www.${DOMAIN}       →  ${PUBLIC_IP}"
    echo "      *.${DOMAIN}         →  ${PUBLIC_IP}"
    if [ "$ENABLE_DASHBOARD" = "true" ]; then
        echo "      traefik.${DOMAIN}   →  ${PUBLIC_IP}"
    fi
    echo ""
}

print_common_info() {
    echo -e "${BOLD}Installation Directory:${NC}"
    echo ""
    echo "    ${INSTALL_DIR}"
    echo ""

    # Service user info
    if [ "$CREATE_SERVICE_USER" = "true" ] && [ "$SERVICE_USER" != "root" ]; then
        echo -e "${BOLD}Service User:${NC}"
        echo ""
        echo -e "    ${GREEN}Username:${NC}    $SERVICE_USER"
        echo -e "    ${GREEN}Group:${NC}       docker"
        echo ""
        echo -e "${BOLD}Commands (run as root or with sudo):${NC}"
        echo ""
        echo "    Start:    sudo -u $SERVICE_USER $COMPOSE_CMD -f $INSTALL_DIR/$COMPOSE_FILE up -d"
        echo "    Stop:     sudo -u $SERVICE_USER $COMPOSE_CMD -f $INSTALL_DIR/$COMPOSE_FILE down"
        echo "    Logs:     sudo -u $SERVICE_USER $COMPOSE_CMD -f $INSTALL_DIR/$COMPOSE_FILE logs -f"
        echo "    Status:   sudo -u $SERVICE_USER $COMPOSE_CMD -f $INSTALL_DIR/$COMPOSE_FILE ps"
        echo ""
        echo -e "    ${CYAN}Or switch to the service user:${NC}"
        echo "    sudo -su $SERVICE_USER"
        echo "    cd $INSTALL_DIR && $COMPOSE_CMD -f $COMPOSE_FILE up -d"
    else
        echo -e "${BOLD}Commands:${NC}"
        echo ""
        echo "    Start:    cd $INSTALL_DIR && $COMPOSE_CMD -f $COMPOSE_FILE up -d"
        echo "    Stop:     cd $INSTALL_DIR && $COMPOSE_CMD -f $COMPOSE_FILE down"
        echo "    Logs:     cd $INSTALL_DIR && $COMPOSE_CMD -f $COMPOSE_FILE logs -f"
        echo "    Status:   cd $INSTALL_DIR && $COMPOSE_CMD -f $COMPOSE_FILE ps"
    fi
    echo ""
    echo -e "${BOLD}Firewall Ports:${NC}"
    echo ""
    if [ "$INSTALL_MODE" = "traefik" ]; then
        echo "    80/TCP    - HTTP (redirects to HTTPS)"
        echo "    443/TCP   - HTTPS (Web UI & Device Access)"
    else
        echo "    443/TCP   - HTTPS (Web UI)"
        echo "    10443/TCP - Device Web Access"
    fi
    echo "    5912/TCP  - Device Connections"
    echo "    3478/TCP  - TURN Server"
    echo "    3478/UDP  - TURN Server"
    echo ""
}

# =========================================================
# Main
# =========================================================

main() {
    print_banner

    # Pre-flight checks
    check_root
    check_source_files

    # System setup
    print_step "System Preparation"
    detect_os

    # Installation mode
    select_install_mode

    # Service user configuration
    configure_service_user

    # Install dependencies
    print_step "Installing Dependencies"
    install_dependencies
    configure_firewall

    # Create service user (after docker is installed)
    if [ "$CREATE_SERVICE_USER" = "true" ]; then
        print_step "Creating Service User"
        create_service_user
    fi

    # Mode-specific installation
    if [ "$INSTALL_MODE" = "standard" ]; then
        configure_standard
        install_standard
        print_summary_standard
    else
        configure_traefik
        install_traefik
        print_summary_traefik
    fi

    print_common_info
}

# Run
main "$@"
