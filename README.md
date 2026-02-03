# Self-Deployed Lightweight Cloud KVM Remote Management Platform

[中文文档](./README.zh-CN.md) | English

Self-Deployed Lightweight Cloud is a lightweight KVM remote cloud platform tailored for individuals and small businesses. This project is developed based on [rttys](https://github.com/zhaojh329/rttys), designed for users who need to **quickly** build a remote access platform while prioritizing **data security**.

#### Main Functions and Features

-  **Device Management** - Online device list monitoring
-  **Script Deployment** - Convenient script-based device addition
-  **Remote SSH** - Web SSH remote connections
-  **Remote Control** - Web remote desktop control
-  **Batch Operations** - Batch command execution capabilities
-  **Rapid Deployment** - Quick self-deployment with simple operations
-  **Data Security** - Private deployment with full data control
-  **Dedicated Bandwidth** - Exclusive bandwidth for self-hosted deployments
-  **Lightweight Design** - Optimized for small businesses and individual users
-  **Enterprise Authentication** -  Supports both **LDAP** and **OIDC** login methods for enterprise users.

-  **Deployment** - Supports both **internal network** and **public internet** deployments
-  **Platform Compatibility** - Supports both **x86_64** and **arm64** platforms

## Self-Hosting Guide

The following mainstream operating systems have been tested and verified

#### Debian Family

- Ubuntu 18.04 / 20.04 / 22.04 / 24.04
- Debian 11 / 12

#### Red Hat Family

- AlmaLinux 8 / 9
- Rocky Linux 8 / 9
- CentOS Stream 9

#### Requirements

|      Component      | Minimum Requirement |
| :-----------------: | :-----------------: |
|         CPU         |  1 core or above   |
|       Memory        |       ≥ 1 GB        |
|       Storage       |       ≥ 40 GB       |
| Network Bandwidth   | ≥ 3 Mbps      |
| KVM Device Firmware |      ≥ v1.5.0       |

------

## Installation Options

We provide **three** installation methods:

| Method | Best For | TLS Certificates | Features |
|--------|----------|------------------|----------|
| **A) Interactive Installer** | Production deployments | Auto Let's Encrypt or self-signed | Full wizard, Traefik + CrowdSec, service user, firewall config |
| **B) One-line Installer** | Quick testing | Self-signed | Fastest setup, downloads from gl-inet |
| **C) Manual Docker Compose** | Custom deployments | Your choice | Full control |

---

### A) Interactive Installer (Recommended)

The interactive installer provides a guided setup with two deployment modes:

#### Standard Mode
- Self-signed TLS certificate
- Access via IP address
- Quick setup for testing or internal networks

#### Traefik Mode (Production)
- **Automatic Let's Encrypt certificates** (including wildcard)
- **CrowdSec brute-force protection**
- Domain-based access with proper TLS
- Supports DigitalOcean, Cloudflare, AWS Route53, Google Cloud DNS

#### Security Features (Both Modes)
- **Dedicated service user** - Option to create a non-root user (`glkvm`) to manage Docker services
- **Automatic credential generation** - Secure random passwords and tokens
- **Firewall configuration** - Automatic UFW/firewalld rules

**Run as root:**

```bash
git clone https://github.com/jessewolcott/glkvm-cloud.git
cd glkvm-cloud
sudo ./installer-interactive.sh
```

**The installer will prompt you for:**

1. **Installation mode** - Standard or Traefik
2. **Service user** - Create dedicated `glkvm` user (recommended)
3. **Domain & email** (Traefik mode) - For Let's Encrypt certificates
4. **DNS provider** (Traefik mode) - DigitalOcean, Cloudflare, Route53, or GCloud
5. **Credentials** - Auto-generated with option to customize
6. **Traefik dashboard** (optional) - Web UI for Traefik management

---

### B) One-line Installer (Quick Start)

> **Note:** Downloads pre-built images from gl-inet servers. Supports **x86_64 (amd64)** only.

**Run as root:**

```bash
curl -fsSL https://kvm-cloud.gl-inet.com/selfhost/install.sh | sudo bash
```

---

### C) Manual Docker Compose

> Full reference: see [`Source/docker-compose/README.md`](Source/docker-compose/README.md)
>
> **Platform:** supports both **x86_64 (amd64)** and **arm64 (AArch64)**.

```bash
git clone https://github.com/jessewolcott/glkvm-cloud.git
cd glkvm-cloud/Source/docker-compose

# For x86_64:
cp .env.example .env

# For arm64:
cp .env.arm64.example .env

# Edit configuration
nano .env

# Start services
docker-compose up -d
```

---

## 🔐 Cloud Security Group Settings

If your server provider uses a **cloud security group** (e.g., AWS, Aliyun, etc.), please ensure the following ports are **open**:

#### Standard Installation

| Port  | Protocol | Purpose                        |
| ----- | -------- | ------------------------------ |
| 443   | TCP      | Web UI access                  |
| 10443 | TCP      | WebSocket proxy                |
| 5912  | TCP      | Device connection              |
| 3478  | TCP/UDP  | TURN server for WebRTC support |

#### Traefik Installation

| Port  | Protocol | Purpose                        |
| ----- | -------- | ------------------------------ |
| 80    | TCP      | HTTP (redirects to HTTPS)      |
| 443   | TCP      | HTTPS (Web UI & Device Access) |
| 5912  | TCP      | Device connection              |
| 3478  | TCP/UDP  | TURN server for WebRTC support |

> **Important:** These ports will be **used by GLKVM Cloud**. Please ensure **no other applications or services** on your server are binding to these ports.

---

## 🌐 Platform Access

### Standard Installation (IP-based)

```
https://<your_server_public_ip>
```

> **Note**: Accessing via IP address will trigger a **browser certificate warning**.

### Traefik Installation (Domain-based)

```
https://www.your-domain.com      # Web UI
https://your-domain.com          # Web UI (alternate)
https://<device-id>.your-domain.com  # Device access
```

Certificates are automatically provisioned by Let's Encrypt - no browser warnings!

---

## 🔑 Web UI Login Password

The default login password for the Web UI will be displayed in the installation script output:

```
🔐 Please check the installation console for your web login password.
```

![](img/password.png)

---

## Feature Demonstrations

###  Add KVM Devices to the Lightweight Cloud

- Copy script

![Add KVM Devices to the Lightweight Cloud](img/adddevice.png)

- Run the script in the device terminal

![Add KVM Devices to the Lightweight Cloud](img/rundevicescript.png)

- Devices connected to the cloud

![Add KVM Devices to the Lightweight Cloud](img/devicelist.png)


### Remote SSH Connection

![Remote SSH Screenshot](img/ssh.png)

### Remote Desktop Control

![Remote Control Screenshot](img/web.png)

---

## Advanced Configuration

### Use your own SSL Certificate (Standard Mode Only)

> **Note**: If using Traefik mode, certificates are managed automatically by Let's Encrypt.

For standard installations, replace the default certificates with your own **wildcard SSL certificate** that supports:

- `*.your-domain.com` (for device access)
- `www.your-domain.com` (for platform access)

Replace the following files in:

```
~/glkvm_cloud/certificate
```

- `glkvm.cer`
- `glkvm.key`

> **Make sure the filenames remain unchanged.**

---

### 🌐 DNS Configuration

#### For Traefik Installation

Add these A records pointing to your server IP:

| Hostname | Type | Value | Purpose |
|----------|------|-------|---------|
| `@` (or domain) | A | Your public IP | Web UI access |
| `www` | A | Your public IP | Web UI access |
| `*` | A | Your public IP | Device access (wildcard) |
| `traefik` | A | Your public IP | Traefik dashboard (optional) |

#### For Standard Installation with Custom Domain

| Hostname | Type | Value | Purpose |
|----------|------|-------|---------|
| `www` | A | Your public IP | Web access to the platform |
| `*` | A | Your public IP | Remote access to KVMs |

---

### 🔐 LDAP Authentication (Optional)

GLKVM Cloud supports LDAP authentication for enterprise environments, allowing you to integrate with existing directory services like Active Directory, OpenLDAP, or FreeIPA.

**Key Features:**
- **Dual Authentication Mode**: Support both LDAP and traditional password authentication simultaneously
- **Group-based Authorization**: Restrict access to specific LDAP groups
- **User-based Authorization**: Allow access for specific users only
- **TLS/SSL Support**: Secure LDAP connections with encryption
- **Multiple LDAP Systems**: Compatible with Active Directory, OpenLDAP, FreeIPA, and generic LDAP servers

**Configuration:**
For detailed LDAP configuration options and setup instructions, see the [Docker Compose README](Source/docker-compose/README.md).

**Note**: When LDAP is enabled, users can choose between:
- **LDAP Authentication**: Enter username and password for directory service authentication
- **Legacy Authentication**: Leave username empty and use the web management password

---

### 🔐 OIDC Authentication (Optional)

GLKVM Cloud provides full support for **OIDC (OpenID Connect)** authentication, allowing seamless integration with modern identity providers such as **Google, Auth0, Authing** and any other standard-compliant OIDC provider.

 **Key Features**

- **Modern Authentication**
   Secure sign-in through any OIDC provider supporting Authorization Code Flow.
- **Email / Username / Group Whitelisting**
   Restrict access based on:
  - Email or domain (e.g. *@example.com*)
  - Stable user ID (*sub*)
  - Username (*preferred_username* or *name*)
  - Groups attribute
- **Full OpenID Connect Compliance**
   Supports issuer validation, token signature verification, and nonce protection.
- **Flexible Provider Support**
   Works with public clouds (Google, Azure AD, Auth0, Okta) and self-hosted solutions.

 **Configuration**

For detailed OIDC configuration options and setup instructions, see the **[Docker Compose README](Source/docker-compose/README.md)**.

---

### 👤 Service User (Security Best Practice)

The interactive installer offers to create a dedicated service user (`glkvm` by default) to run Docker services. This is a security best practice that:

- Isolates the application from root privileges
- Limits potential damage from container escapes
- Follows the principle of least privilege

**If you enabled the service user, run commands as that user:**

```bash
# Using sudo
sudo -u glkvm docker-compose -f /path/to/glkvm_cloud/docker-compose.yml up -d

# Or switch to the service user
sudo -su glkvm
cd ~/glkvm_cloud && docker-compose up -d
```

---

### 🔄 Restart Services After Configuration Changes

After replacing certificates or updating configuration, restart the GLKVM Cloud services:

**Standard Installation (as root or service user):**
```bash
cd ~/glkvm_cloud
docker-compose down && docker-compose up -d

# Or with service user:
sudo -u glkvm docker-compose -f ~/glkvm_cloud/docker-compose.yml down
sudo -u glkvm docker-compose -f ~/glkvm_cloud/docker-compose.yml up -d
```

**Traefik Installation:**
```bash
cd ~/glkvm_cloud
docker-compose -f docker-compose.traefik.yml down
docker-compose -f docker-compose.traefik.yml up -d

# Or with service user:
sudo -u glkvm docker-compose -f ~/glkvm_cloud/docker-compose.traefik.yml down
sudo -u glkvm docker-compose -f ~/glkvm_cloud/docker-compose.traefik.yml up -d
```

Or, on systems with the Docker CLI plugin:
```bash
docker compose -f docker-compose.traefik.yml down
docker compose -f docker-compose.traefik.yml up -d
```

---

## Project Structure

```
glkvm-cloud/
├── installer-interactive.sh    # Interactive installer (recommended)
├── install.sh                  # One-line installer (downloads from gl-inet)
├── README.md                   # This file
└── Source/
    └── docker-compose/
        ├── docker-compose.yml          # Standard deployment
        ├── docker-compose.traefik.yml  # Traefik + Let's Encrypt deployment
        ├── .env.example                # Environment template (x86_64)
        ├── .env.arm64.example          # Environment template (arm64)
        ├── .env.traefik.example        # Traefik environment template
        ├── traefik/                    # Traefik configuration
        │   ├── traefik.yml             # Static config
        │   └── dynamic/                # Dynamic config (CrowdSec middleware)
        ├── crowdsec/                   # CrowdSec configuration
        ├── certificate/                # Default self-signed certificates
        ├── templates/                  # Service configuration templates
        └── scripts/                    # Container entrypoint scripts
```

---

## Troubleshooting

### Certificate Issues (Traefik Mode)

Check Traefik logs for ACME/Let's Encrypt errors:
```bash
docker logs glkvm_traefik 2>&1 | grep -i acme
```

### CrowdSec Not Blocking

Verify CrowdSec is parsing logs:
```bash
docker exec glkvm_crowdsec cscli metrics
```

Check decisions:
```bash
docker exec glkvm_crowdsec cscli decisions list
```

### Service Status

```bash
# Standard mode
cd ~/glkvm_cloud && docker-compose ps

# Traefik mode
cd ~/glkvm_cloud && docker-compose -f docker-compose.traefik.yml ps

# With service user
sudo -u glkvm docker-compose -f ~/glkvm_cloud/docker-compose.traefik.yml ps
```

### View Logs

```bash
# All services
cd ~/glkvm_cloud && docker-compose logs -f

# Specific service
docker logs glkvm_cloud -f
docker logs glkvm_traefik -f
docker logs glkvm_crowdsec -f
```

### Service User Issues

If Docker commands fail with permission errors when using the service user:

```bash
# Verify user is in docker group
groups glkvm

# If not, add them
sudo usermod -aG docker glkvm

# User may need to log out/in or restart Docker
sudo systemctl restart docker
```
