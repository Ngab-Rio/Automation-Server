# Ansible Automation Server Setup

![Ansible](https://img.shields.io/badge/Ansible-5C4EE5?style=for-the-badge&logo=ansible&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)


Repository Ansible untuk mengotomasi deployment dan konfigurasi server dengan multiple services: **Nginx**, **Samba**, dan **ProFTPd**.

## 📁 Project Structure
```bash
├── ansible.cfg
├── group_vars
│   └── all
│       └── vault.yml
├── inventories
│   └── inventory
├── openssl
├── playbooks
│   └── main.yaml
└── roles
    ├── nginx
    │   ├── files
    │   │   └── nginx.conf
    │   ├── nginx.sh
    │   ├── tasks
    │   │   └── main.yml
    │   └── WEB
    │       ├── mains
    │       │   └── index.html
    │       └── profiles
    │           ├── foto.jpg
    │           └── profile.html
    ├── proftpd
    │   ├── files
    │   │   └── proftpd.conf
    │   ├── proftpd.sh
    │   └── tasks
    │       └── main.yml
    └── samba
        ├── files
        │   └── samba.conf
        ├── handler
        ├── samba.sh
        └── tasks
            └── main.yml
```


## 🚀 Services yang Diinstall

### 1. Nginx Web Server
- **Port**: 7777 & 7778
- **Web Root**: `/var/www/projects/Ansible-Web/`
- **Features**: Dua virtual host terpisah untuk different content

### 2. Samba File Sharing
- **Shares**:
  - `[datacenter]`: Authenticated share (user: `shared`)
  - `[datapublic]`: Public read-only share
- **Paths**: `/tmp/datacenter` dan `/tmp/datapublic`

### 3. ProFTPd FTP Server
- **Port**: 2101
- **User**: `shared` (authenticated access)
- **Restriction**: Hanya bisa mengakses `/home/shared`

## ⚙️ Prerequisites

- **Ansible** terinstall pada control node
- **SSH access** ke target server(s)
- **Python** terinstall pada target server(s)

## 🔐 Setup Vault Password

Repository ini menggunakan Ansible Vault untuk mengamankan sensitive data.

### Create vault password file:
```bash
echo "your_vault_password_here" > ~/.ansible/vault_pass.txt
chmod 600 ~/.ansible/vault_pass.txt
```

### Edit encrypted variables:
```bash
ansible-vault edit group_vars/all/vault.yml
```

## 🎯Usage

### 1. Konfigurasi Inventory
Edit file ```inventories/inventory```
```ini
[server_hosts]
your-server-ip-or-hostname

[server_hosts:vars]
ansible_user=your-ssh-user
ansible_ssh_private_key_file=~/.ssh/your-private-key
```

### 2. Jalankan Semua Roles
```bash
# Dari root project directory
cd Automation-Server

# Jalankan semua services
ansible-playbook -i inventories/inventory playbooks/main.yaml --ask-vault-pass --ask-become-pass
```

### 3. Jalankan Specific Role saja
```bash
# Hanya Nginx
ansible-playbook -i inventories/inventory playbooks/main.yaml --tags nginx --ask-vault-pass

# Hanya Samba
ansible-playbook -i inventories/inventory playbooks/main.yaml --tags samba --ask-vault-pass

# Hanya ProFTPd
ansible-playbook -i inventories/inventory playbooks/main.yaml --tags proftpd --ask-vault-pass
```

## 🔧 Customization
Variables yang Digunakan

-   samba_password: Password untuk user Samba (disimpan di vault)

Konfigurasi Default

-   Nginx: Port 7777 & 7778

-   Samba: Shares di /tmp/

-   ProFTPd: Port 2101, user shared

-   User: System user shared untuk Samba dan FTP

## 📝 Notes
- Pastikan firewall sudah dikonfigurasi untuk allow ports yang digunakan

- File konfigurasi custom ditempatkan di direktori conf.d masing-masing service

- Handler digunakan untuk restart service hanya ketika ada perubahan konfigurasi
