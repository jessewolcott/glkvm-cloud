#!/usr/bin/env bash
# =========================================================
# GLKVM Cloud - Uninstaller
# =========================================================
# Removes GLKVM Cloud installation and optionally:
# - Docker containers and volumes
# - Installation directory
# - Firewall rules
# - Service user
#
# Usage: sudo bash uninstall.sh
# =========================================================

# Ensure we're running in bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash. Please run with: sudo bash $0"
    exit 1
fi

set -e

# =========================================================
# Configuration
# =========================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_INSTALL_DIR="${SCRIPT_DIR}/glkvm_cloud"
DEFAULT_SERVICE_USER="glkvm"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# =========================================================
# Helper Functions
# =========================================================

print_banner() {
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}          ${BOLD}GLKVM Cloud Uninstaller${NC}                          ${RED}║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_substep() {
    echo -e "    ${CYAN}→${NC} $1"
}

print_success() {
    echo -e "    ${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "    ${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "    ${RED}✗${NC} $1"
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -r -p "    $prompt" response
    response=${response:-$default}

    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

prompt() {
    local var_name="$1"
    local prompt_text="$2"
    local default="$3"
    local response

    if [ -n "$default" ]; then
        read -r -p "    $prompt_text [$default]: " response
        response=${response:-$default}
    else
        read -r -p "    $prompt_text: " response
    fi

    eval "$var_name=\"$response\""
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_error "This script must be run as root (use: sudo bash $0)"
        exit 1
    fi
}

detect_platform() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_ID_LIKE=$ID_LIKE

        if [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID_LIKE" == *"debian"* ]]; then
            PLATFORM="debian"
        elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" || "$OS_ID" == "almalinux" || "$OS_ID" == "rocky" || "$OS_ID_LIKE" == *"rhel"* ]]; then
            PLATFORM="redhat"
        else
            PLATFORM="unknown"
        fi
    else
        PLATFORM="unknown"
    fi
}

detect_compose_command() {
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD=""
    fi
}

# =========================================================
# Uninstall Functions
# =========================================================

find_installation() {
    print_step "Finding GLKVM Cloud Installation"

    # Check common locations
    FOUND_DIRS=()

    # Check script directory
    if [ -d "$DEFAULT_INSTALL_DIR" ]; then
        FOUND_DIRS+=("$DEFAULT_INSTALL_DIR")
    fi

    # Check home directories
    for home_dir in /root /home/*; do
        if [ -d "$home_dir/glkvm_cloud" ] && [ "$home_dir/glkvm_cloud" != "$DEFAULT_INSTALL_DIR" ]; then
            FOUND_DIRS+=("$home_dir/glkvm_cloud")
        fi
    done

    # Check current directory
    if [ -d "./glkvm_cloud" ] && [ "$(realpath ./glkvm_cloud)" != "$(realpath $DEFAULT_INSTALL_DIR 2>/dev/null)" ]; then
        FOUND_DIRS+=("$(realpath ./glkvm_cloud)")
    fi

    if [ ${#FOUND_DIRS[@]} -eq 0 ]; then
        print_warning "No GLKVM Cloud installation found in common locations"
        prompt INSTALL_DIR "Enter installation directory path" ""
        if [ ! -d "$INSTALL_DIR" ]; then
            print_error "Directory does not exist: $INSTALL_DIR"
            exit 1
        fi
    elif [ ${#FOUND_DIRS[@]} -eq 1 ]; then
        INSTALL_DIR="${FOUND_DIRS[0]}"
        print_success "Found installation: $INSTALL_DIR"
    else
        echo "    Found multiple installations:"
        for i in "${!FOUND_DIRS[@]}"; do
            echo "      $((i+1)). ${FOUND_DIRS[$i]}"
        done
        prompt choice "Select installation to remove (1-${#FOUND_DIRS[@]})" "1"
        INSTALL_DIR="${FOUND_DIRS[$((choice-1))]}"
    fi

    # Detect installation type
    if [ -f "$INSTALL_DIR/docker-compose.traefik.yml" ]; then
        INSTALL_TYPE="traefik"
        COMPOSE_FILE="docker-compose.traefik.yml"
        print_substep "Installation type: Traefik mode"
    elif [ -f "$INSTALL_DIR/docker-compose.yml" ]; then
        INSTALL_TYPE="standard"
        COMPOSE_FILE="docker-compose.yml"
        print_substep "Installation type: Standard mode"
    else
        INSTALL_TYPE="unknown"
        COMPOSE_FILE=""
        print_warning "Could not determine installation type"
    fi
}

stop_containers() {
    print_step "Stopping Docker Containers"

    if [ -z "$COMPOSE_CMD" ]; then
        print_warning "Docker Compose not found, attempting direct docker commands"

        # Stop containers by name
        for container in glkvm_cloud glkvm_traefik glkvm_coturn glkvm_crowdsec glkvm_crowdsec_bouncer; do
            if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
                print_substep "Stopping $container..."
                docker stop "$container" 2>/dev/null || true
                docker rm "$container" 2>/dev/null || true
                print_success "Removed $container"
            fi
        done
    else
        if [ -n "$COMPOSE_FILE" ] && [ -f "$INSTALL_DIR/$COMPOSE_FILE" ]; then
            print_substep "Stopping services via docker-compose..."
            cd "$INSTALL_DIR"
            $COMPOSE_CMD -f "$COMPOSE_FILE" down 2>/dev/null || true
            print_success "Services stopped"
        else
            # Fallback to direct docker commands
            for container in glkvm_cloud glkvm_traefik glkvm_coturn glkvm_crowdsec glkvm_crowdsec_bouncer; do
                if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
                    print_substep "Stopping $container..."
                    docker stop "$container" 2>/dev/null || true
                    docker rm "$container" 2>/dev/null || true
                    print_success "Removed $container"
                fi
            done
        fi
    fi
}

remove_volumes() {
    print_step "Removing Docker Volumes"

    echo ""
    echo -e "    ${YELLOW}WARNING: This will permanently delete all GLKVM Cloud data!${NC}"
    echo "    This includes:"
    echo "      - Database (device registrations, settings)"
    echo "      - TLS certificates"
    echo "      - CrowdSec configuration and decisions"
    echo ""

    if prompt_yes_no "Remove Docker volumes and all data?" "n"; then
        VOLUMES=(
            "glkvm_traefik_letsencrypt"
            "glkvm_traefik_logs"
            "glkvm_crowdsec_config"
            "glkvm_crowdsec_data"
        )

        for volume in "${VOLUMES[@]}"; do
            if docker volume ls --format '{{.Name}}' | grep -q "^${volume}$"; then
                print_substep "Removing volume: $volume"
                docker volume rm "$volume" 2>/dev/null || true
                print_success "Removed $volume"
            fi
        done

        # Also remove any volumes with glkvm prefix
        for volume in $(docker volume ls --format '{{.Name}}' | grep -E '^glkvm_'); do
            print_substep "Removing volume: $volume"
            docker volume rm "$volume" 2>/dev/null || true
        done

        print_success "Docker volumes removed"
    else
        print_warning "Skipping volume removal (data preserved)"
    fi
}

remove_installation_directory() {
    print_step "Removing Installation Directory"

    echo ""
    echo "    Directory: $INSTALL_DIR"
    echo ""

    if prompt_yes_no "Remove installation directory?" "y"; then
        if [ -d "$INSTALL_DIR" ]; then
            rm -rf "$INSTALL_DIR"
            print_success "Removed $INSTALL_DIR"
        else
            print_warning "Directory already removed"
        fi
    else
        print_warning "Skipping directory removal"
    fi
}

remove_firewall_rules() {
    print_step "Removing Firewall Rules"

    echo ""
    echo "    The following ports were opened during installation:"
    if [ "$INSTALL_TYPE" = "traefik" ]; then
        echo "      - 80/TCP (HTTP redirect)"
        echo "      - 443/TCP (HTTPS)"
    else
        echo "      - 443/TCP (Web UI)"
        echo "      - 10443/TCP (Device proxy)"
    fi
    echo "      - 5912/TCP (Device connection)"
    echo "      - 3478/TCP+UDP (TURN server)"
    echo ""

    if prompt_yes_no "Remove firewall rules?" "n"; then
        if [ "$PLATFORM" = "debian" ]; then
            if command -v ufw &> /dev/null; then
                print_substep "Removing UFW rules..."

                if [ "$INSTALL_TYPE" = "traefik" ]; then
                    ufw delete allow 80/tcp 2>/dev/null || true
                else
                    ufw delete allow 10443/tcp 2>/dev/null || true
                fi
                ufw delete allow 443/tcp 2>/dev/null || true
                ufw delete allow 5912/tcp 2>/dev/null || true
                ufw delete allow 3478/tcp 2>/dev/null || true
                ufw delete allow 3478/udp 2>/dev/null || true

                print_success "UFW rules removed"
            fi
        elif [ "$PLATFORM" = "redhat" ]; then
            if command -v firewall-cmd &> /dev/null; then
                print_substep "Removing firewalld rules..."

                if [ "$INSTALL_TYPE" = "traefik" ]; then
                    firewall-cmd --permanent --remove-port=80/tcp 2>/dev/null || true
                else
                    firewall-cmd --permanent --remove-port=10443/tcp 2>/dev/null || true
                fi
                firewall-cmd --permanent --remove-port=443/tcp 2>/dev/null || true
                firewall-cmd --permanent --remove-port=5912/tcp 2>/dev/null || true
                firewall-cmd --permanent --remove-port=3478/tcp 2>/dev/null || true
                firewall-cmd --permanent --remove-port=3478/udp 2>/dev/null || true
                firewall-cmd --reload 2>/dev/null || true

                print_success "Firewalld rules removed"
            fi
        else
            print_warning "Unknown platform, skipping firewall cleanup"
        fi
    else
        print_warning "Skipping firewall rule removal"
    fi
}

remove_service_user() {
    print_step "Removing Service User"

    # Check if service user exists
    if id "$DEFAULT_SERVICE_USER" &>/dev/null; then
        echo ""
        echo "    Found service user: $DEFAULT_SERVICE_USER"
        echo ""

        if prompt_yes_no "Remove service user '$DEFAULT_SERVICE_USER'?" "n"; then
            print_substep "Removing user: $DEFAULT_SERVICE_USER"

            # Kill any processes owned by the user
            pkill -u "$DEFAULT_SERVICE_USER" 2>/dev/null || true

            # Remove user
            userdel -r "$DEFAULT_SERVICE_USER" 2>/dev/null || userdel "$DEFAULT_SERVICE_USER" 2>/dev/null || true

            if ! id "$DEFAULT_SERVICE_USER" &>/dev/null; then
                print_success "User '$DEFAULT_SERVICE_USER' removed"
            else
                print_warning "Could not fully remove user (may have active processes)"
            fi
        else
            print_warning "Skipping service user removal"
        fi
    else
        print_substep "No service user found"
    fi
}

remove_docker_images() {
    print_step "Removing Docker Images"

    echo ""
    echo "    The following images may have been pulled for GLKVM Cloud:"
    echo "      - glzhitong/glkvm-cloud"
    echo "      - coturn/coturn"
    echo "      - traefik"
    echo "      - crowdsecurity/crowdsec"
    echo "      - fbonalair/traefik-crowdsec-bouncer"
    echo ""

    if prompt_yes_no "Remove Docker images?" "n"; then
        IMAGES=(
            "glzhitong/glkvm-cloud"
            "coturn/coturn"
            "traefik"
            "crowdsecurity/crowdsec"
            "fbonalair/traefik-crowdsec-bouncer"
        )

        for image in "${IMAGES[@]}"; do
            if docker images --format '{{.Repository}}' | grep -q "^${image}$"; then
                print_substep "Removing image: $image"
                docker rmi "$image" 2>/dev/null || true
            fi
        done

        # Prune unused images
        print_substep "Pruning unused images..."
        docker image prune -f 2>/dev/null || true

        print_success "Docker images cleaned up"
    else
        print_warning "Skipping image removal"
    fi
}

print_summary() {
    print_step "Uninstallation Complete"

    echo ""
    echo -e "    ${GREEN}GLKVM Cloud has been uninstalled.${NC}"
    echo ""
    echo "    What was removed:"
    echo "      - Docker containers (glkvm_*)"
    [ "$VOLUMES_REMOVED" = "true" ] && echo "      - Docker volumes (data deleted)"
    [ "$DIR_REMOVED" = "true" ] && echo "      - Installation directory"
    [ "$FIREWALL_REMOVED" = "true" ] && echo "      - Firewall rules"
    [ "$USER_REMOVED" = "true" ] && echo "      - Service user"
    [ "$IMAGES_REMOVED" = "true" ] && echo "      - Docker images"
    echo ""

    if [ "$VOLUMES_REMOVED" != "true" ]; then
        echo -e "    ${YELLOW}Note:${NC} Docker volumes were preserved. To remove them manually:"
        echo "      docker volume rm glkvm_traefik_letsencrypt glkvm_crowdsec_config glkvm_crowdsec_data"
        echo ""
    fi

    echo "    Thank you for using GLKVM Cloud!"
    echo ""
}

# =========================================================
# Main
# =========================================================

main() {
    print_banner

    echo -e "    ${YELLOW}WARNING: This will remove GLKVM Cloud from your system.${NC}"
    echo ""

    if ! prompt_yes_no "Are you sure you want to continue?" "n"; then
        echo ""
        echo "    Uninstallation cancelled."
        echo ""
        exit 0
    fi

    check_root
    detect_platform
    detect_compose_command

    find_installation
    stop_containers

    # Track what was removed for summary
    VOLUMES_REMOVED="false"
    DIR_REMOVED="false"
    FIREWALL_REMOVED="false"
    USER_REMOVED="false"
    IMAGES_REMOVED="false"

    remove_volumes && VOLUMES_REMOVED="true" || true
    remove_installation_directory && DIR_REMOVED="true" || true
    remove_firewall_rules && FIREWALL_REMOVED="true" || true
    remove_service_user && USER_REMOVED="true" || true
    remove_docker_images && IMAGES_REMOVED="true" || true

    print_summary
}

main "$@"
