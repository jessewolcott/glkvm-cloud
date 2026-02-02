#!/bin/bash
# =========================================================
# GLKVM Cloud - Traefik + Let's Encrypt + CrowdSec Installer
# =========================================================
# Interactive setup script for deploying GLKVM Cloud with:
# - Traefik reverse proxy
# - Automatic Let's Encrypt certificates (including wildcard)
# - CrowdSec brute-force protection
#
# Usage: ./install-traefik.sh
# =========================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.traefik.yml"

# =========================================================
# Helper Functions
# =========================================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     GLKVM Cloud - Traefik + Let's Encrypt Installer       ║"
    echo "║              with CrowdSec Protection                     ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
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
        read -sp "${prompt_text}: " value
        echo ""
    else
        read -p "${prompt_text}: " value
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

    read -p "${prompt_text}: " response

    if [ -z "$response" ]; then
        response="$default"
    fi

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

generate_password() {
    local length="${1:-24}"
    if command -v openssl &> /dev/null; then
        openssl rand -base64 "$length" | tr -dc 'a-zA-Z0-9' | head -c "$length"
    elif [ -f /dev/urandom ]; then
        tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
    else
        date +%s%N | sha256sum | head -c "$length"
    fi
}

check_dependencies() {
    print_step "Checking dependencies..."

    local missing=()

    if ! command -v docker &> /dev/null; then
        missing+=("docker")
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
        missing+=("docker-compose")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing[*]}"
        echo "Please install them and run this script again."
        exit 1
    fi

    print_success "All dependencies found"
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
# Main Installation
# =========================================================

main() {
    print_banner

    # Check if running from correct directory
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "docker-compose.traefik.yml not found!"
        echo "Please run this script from the docker-compose directory."
        exit 1
    fi

    check_dependencies

    # Detect architecture
    ARCH=$(detect_architecture)
    print_success "Detected architecture: $ARCH"

    # =========================================================
    # Domain Configuration
    # =========================================================
    print_step "Domain Configuration"
    echo "Your GLKVM Cloud will be accessible at:"
    echo "  - Web UI: https://www.<domain> and https://<domain>"
    echo "  - Devices: https://<device-id>.<domain>"
    echo ""

    prompt DOMAIN "Enter your domain (e.g., kvm.example.com)" ""

    while [ -z "$DOMAIN" ]; do
        print_error "Domain is required"
        prompt DOMAIN "Enter your domain (e.g., kvm.example.com)" ""
    done

    # =========================================================
    # Let's Encrypt Configuration
    # =========================================================
    print_step "Let's Encrypt Configuration"
    echo "An email is required for Let's Encrypt certificate notifications."
    echo ""

    prompt ACME_EMAIL "Enter your email address" ""

    while [ -z "$ACME_EMAIL" ]; do
        print_error "Email is required for Let's Encrypt"
        prompt ACME_EMAIL "Enter your email address" ""
    done

    # =========================================================
    # DNS Provider Configuration
    # =========================================================
    print_step "DNS Provider Configuration"
    echo "Wildcard certificates require DNS-01 challenge."
    echo "Select your DNS provider:"
    echo ""
    echo "  1) DigitalOcean"
    echo "  2) Cloudflare"
    echo "  3) AWS Route53"
    echo "  4) Google Cloud DNS"
    echo "  5) Other (manual configuration required)"
    echo ""

    read -p "Select provider [1-5]: " dns_choice

    case "$dns_choice" in
        1)
            DNS_PROVIDER="digitalocean"
            DNS_ENV_VAR="DO_AUTH_TOKEN"
            echo ""
            echo "Create a DigitalOcean API token at:"
            echo "  https://cloud.digitalocean.com/account/api/tokens"
            echo ""
            prompt DO_AUTH_TOKEN "Enter your DigitalOcean API token" "" "true"
            ;;
        2)
            DNS_PROVIDER="cloudflare"
            DNS_ENV_VAR="CF_DNS_API_TOKEN"
            echo ""
            echo "Create a Cloudflare API token at:"
            echo "  https://dash.cloudflare.com/profile/api-tokens"
            echo "  (Use 'Edit zone DNS' template)"
            echo ""
            prompt CF_DNS_API_TOKEN "Enter your Cloudflare API token" "" "true"
            ;;
        3)
            DNS_PROVIDER="route53"
            DNS_ENV_VAR="AWS_ACCESS_KEY_ID"
            echo ""
            echo "You'll need AWS credentials with Route53 permissions."
            echo ""
            prompt AWS_ACCESS_KEY_ID "Enter your AWS Access Key ID" ""
            prompt AWS_SECRET_ACCESS_KEY "Enter your AWS Secret Access Key" "" "true"
            prompt AWS_REGION "Enter your AWS Region" "us-east-1"
            ;;
        4)
            DNS_PROVIDER="gcloud"
            DNS_ENV_VAR="GCE_PROJECT"
            echo ""
            echo "You'll need a GCP service account with DNS admin permissions."
            echo ""
            prompt GCE_PROJECT "Enter your GCP Project ID" ""
            prompt GCE_SERVICE_ACCOUNT_FILE "Enter path to service account JSON file" ""
            ;;
        5|*)
            DNS_PROVIDER="manual"
            print_warning "Manual configuration selected."
            echo "You'll need to edit traefik/traefik.yml to configure your DNS provider."
            echo "See: https://doc.traefik.io/traefik/https/acme/#providers"
            ;;
    esac

    # =========================================================
    # GLKVM Cloud Credentials
    # =========================================================
    print_step "GLKVM Cloud Credentials"

    DEFAULT_TOKEN=$(generate_password 32)
    DEFAULT_PASS=$(generate_password 16)

    echo "Device Token: Used by KVM devices to connect to the cloud."
    prompt RTTYS_TOKEN "Enter device token" "$DEFAULT_TOKEN"

    echo ""
    echo "Web Password: Used for legacy password authentication."
    prompt RTTYS_PASS "Enter web UI password" "$DEFAULT_PASS"

    # =========================================================
    # Traefik Dashboard
    # =========================================================
    print_step "Traefik Dashboard (Optional)"

    if prompt_yes_no "Enable Traefik dashboard at https://traefik.${DOMAIN}?" "n"; then
        ENABLE_DASHBOARD="true"
        echo ""
        echo "Set credentials for the Traefik dashboard:"
        prompt DASHBOARD_USER "Dashboard username" "admin"
        prompt DASHBOARD_PASS "Dashboard password" "" "true"

        if [ -z "$DASHBOARD_PASS" ]; then
            DASHBOARD_PASS=$(generate_password 16)
            echo "Generated password: $DASHBOARD_PASS"
        fi

        # Generate htpasswd format
        if command -v htpasswd &> /dev/null; then
            TRAEFIK_DASHBOARD_AUTH=$(htpasswd -nb "$DASHBOARD_USER" "$DASHBOARD_PASS" | sed 's/\$/\$\$/g')
        else
            # Fallback: use openssl for apr1 hash
            SALT=$(openssl rand -base64 8 | tr -dc 'a-zA-Z0-9' | head -c 8)
            HASH=$(openssl passwd -apr1 -salt "$SALT" "$DASHBOARD_PASS")
            TRAEFIK_DASHBOARD_AUTH="${DASHBOARD_USER}:${HASH}" | sed 's/\$/\$\$/g'
        fi
    else
        ENABLE_DASHBOARD="false"
        TRAEFIK_DASHBOARD_AUTH='admin:$$apr1$$disabled$$disabled'
    fi

    # =========================================================
    # TURN Server Configuration
    # =========================================================
    print_step "TURN Server Configuration (WebRTC)"

    TURN_USER="glkvmcloudwebrtcuser"
    TURN_PASS=$(generate_password 24)

    echo "Generated TURN credentials (for WebRTC media relay)."

    # =========================================================
    # Architecture-specific images
    # =========================================================
    if [ "$ARCH" = "arm64" ]; then
        GLKVM_IMAGE="glzhitong/glkvm-cloud:latest-arm64"
        COTURN_IMAGE="coturn/coturn:edge-alpine-arm64v8"
    else
        GLKVM_IMAGE="glzhitong/glkvm-cloud:latest"
        COTURN_IMAGE="coturn/coturn:edge-alpine"
    fi

    # =========================================================
    # Generate .env file
    # =========================================================
    print_step "Generating configuration..."

    cat > "$ENV_FILE" << EOF
# =========================================================
# GLKVM Cloud - Traefik + Let's Encrypt + CrowdSec
# Generated by install-traefik.sh on $(date)
# =========================================================

# Domain & Certificate Configuration
DOMAIN=${DOMAIN}
ACME_EMAIL=${ACME_EMAIL}

# DNS Provider: ${DNS_PROVIDER}
EOF

    # Add DNS provider specific variables
    case "$DNS_PROVIDER" in
        digitalocean)
            echo "DO_AUTH_TOKEN=${DO_AUTH_TOKEN}" >> "$ENV_FILE"
            ;;
        cloudflare)
            echo "CF_DNS_API_TOKEN=${CF_DNS_API_TOKEN}" >> "$ENV_FILE"
            # Update traefik.yml for Cloudflare
            sed -i 's/provider: digitalocean/provider: cloudflare/' "${SCRIPT_DIR}/traefik/traefik.yml"
            ;;
        route53)
            echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> "$ENV_FILE"
            echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> "$ENV_FILE"
            echo "AWS_REGION=${AWS_REGION}" >> "$ENV_FILE"
            sed -i 's/provider: digitalocean/provider: route53/' "${SCRIPT_DIR}/traefik/traefik.yml"
            ;;
        gcloud)
            echo "GCE_PROJECT=${GCE_PROJECT}" >> "$ENV_FILE"
            echo "GCE_SERVICE_ACCOUNT_FILE=${GCE_SERVICE_ACCOUNT_FILE}" >> "$ENV_FILE"
            sed -i 's/provider: digitalocean/provider: gcloud/' "${SCRIPT_DIR}/traefik/traefik.yml"
            ;;
    esac

    cat >> "$ENV_FILE" << EOF

# CrowdSec (generate after first run - see instructions below)
CROWDSEC_BOUNCER_API_KEY=

# Traefik Dashboard
TRAEFIK_DASHBOARD_AUTH=${TRAEFIK_DASHBOARD_AUTH}

# Container Images
GLKVM_IMAGE=${GLKVM_IMAGE}
COTURN_IMAGE=${COTURN_IMAGE}

# GLKVM Cloud Credentials
RTTYS_TOKEN=${RTTYS_TOKEN}
RTTYS_PASS=${RTTYS_PASS}

# Port Configuration (internal, Traefik handles 80/443)
RTTYS_DEVICE_PORT=5912
RTTYS_WEBUI_PORT=1443
RTTYS_HTTP_PROXY_PORT=10443

# TURN Server (WebRTC)
TURN_PORT=3478
TURN_USER=${TURN_USER}
TURN_PASS=${TURN_PASS}

# Domain Configuration (auto-configured from DOMAIN)
DEVICE_ENDPOINT_HOST=${DOMAIN}
WEB_UI_HOST=www.${DOMAIN}

# LDAP Authentication (disabled by default)
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

# OIDC Authentication (disabled by default)
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

    print_success "Configuration saved to .env"

    # =========================================================
    # Start Services
    # =========================================================
    print_step "Deployment"

    if prompt_yes_no "Start GLKVM Cloud now?" "y"; then
        echo ""
        echo "Starting services..."

        # Determine docker compose command
        if docker compose version &> /dev/null 2>&1; then
            COMPOSE_CMD="docker compose"
        else
            COMPOSE_CMD="docker-compose"
        fi

        cd "$SCRIPT_DIR"
        $COMPOSE_CMD -f docker-compose.traefik.yml up -d

        print_success "Services started!"

        # Wait for CrowdSec to initialize
        echo ""
        echo "Waiting for CrowdSec to initialize..."
        sleep 10

        # Generate CrowdSec bouncer API key
        echo ""
        print_step "Generating CrowdSec bouncer API key..."

        BOUNCER_KEY=$(docker exec glkvm_crowdsec cscli bouncers add traefik-bouncer -o raw 2>/dev/null || echo "")

        if [ -n "$BOUNCER_KEY" ]; then
            # Update .env with the bouncer key
            sed -i "s/^CROWDSEC_BOUNCER_API_KEY=.*/CROWDSEC_BOUNCER_API_KEY=${BOUNCER_KEY}/" "$ENV_FILE"
            print_success "CrowdSec bouncer key generated and saved"

            # Restart traefik and bouncer to apply the key
            echo "Restarting Traefik and CrowdSec bouncer..."
            $COMPOSE_CMD -f docker-compose.traefik.yml restart traefik crowdsec-bouncer

            print_success "CrowdSec protection activated!"
        else
            print_warning "Could not generate CrowdSec bouncer key automatically."
            echo "Run this command manually after services are fully started:"
            echo "  docker exec glkvm_crowdsec cscli bouncers add traefik-bouncer"
            echo "Then add the key to .env as CROWDSEC_BOUNCER_API_KEY and restart."
        fi
    fi

    # =========================================================
    # Summary
    # =========================================================
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Your GLKVM Cloud is configured at:"
    echo ""
    echo -e "  ${GREEN}Web UI:${NC}      https://www.${DOMAIN}"
    echo -e "  ${GREEN}Web UI:${NC}      https://${DOMAIN}"
    echo -e "  ${GREEN}Devices:${NC}     https://<device-id>.${DOMAIN}"
    if [ "$ENABLE_DASHBOARD" = "true" ]; then
        echo -e "  ${GREEN}Traefik:${NC}     https://traefik.${DOMAIN}"
    fi
    echo ""
    echo -e "  ${GREEN}Device Port:${NC} ${DOMAIN}:5912 (TCP)"
    echo -e "  ${GREEN}TURN Port:${NC}   ${DOMAIN}:3478 (TCP/UDP)"
    echo ""
    echo "Credentials:"
    echo ""
    echo -e "  ${GREEN}Web Password:${NC}  ${RTTYS_PASS}"
    echo -e "  ${GREEN}Device Token:${NC}  ${RTTYS_TOKEN}"
    if [ "$ENABLE_DASHBOARD" = "true" ]; then
        echo -e "  ${GREEN}Dashboard:${NC}     ${DASHBOARD_USER} / (see above)"
    fi
    echo ""
    echo "Configuration file: ${ENV_FILE}"
    echo ""
    echo -e "${YELLOW}DNS Setup Required:${NC}"
    echo "  Add these DNS records to your domain:"
    echo ""
    echo "    ${DOMAIN}         A     <your-server-ip>"
    echo "    www.${DOMAIN}     A     <your-server-ip>"
    echo "    *.${DOMAIN}       A     <your-server-ip>"
    if [ "$ENABLE_DASHBOARD" = "true" ]; then
        echo "    traefik.${DOMAIN} A     <your-server-ip>"
    fi
    echo ""
    echo "Commands:"
    echo ""
    echo "  Start:   docker-compose -f docker-compose.traefik.yml up -d"
    echo "  Stop:    docker-compose -f docker-compose.traefik.yml down"
    echo "  Logs:    docker-compose -f docker-compose.traefik.yml logs -f"
    echo "  Status:  docker-compose -f docker-compose.traefik.yml ps"
    echo ""
}

# Run main function
main "$@"
