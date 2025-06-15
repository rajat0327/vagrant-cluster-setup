# ⚙️ Virtualized Cluster with Vagrant + PowerShell

This repository provides a fully automated setup for a 3-node cluster using Vagrant and PowerShell. It's designed for local development and testing environments using VirtualBox.

---

## 📋 Prerequisites

Before getting started, ensure the following tools are installed:

- [VirtualBox](https://www.virtualbox.org/) (v6.x or higher)
- [Vagrant](https://www.vagrantup.com/) (v2.2.x or higher)
- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- OpenSSH (`ssh`, `ssh-copy-id`) available in your system PATH
- Git (optional, for cloning the repository)

---

## 🚀 Initial Setup Instructions

1. **Clone the Repository**

```bash
git clone https://github.com/rajat0327/vagrant-cluster-setup.git
cd vagrant-cluster-setup
```

2. **Start the Virtual Machines**

```bash
vagrant up
```

This will bring up and provision the following VMs:
- `master-1`
- `worker-1`
- `worker-2`

3. **Verify the VM Status**

```bash
vagrant status
```

---

## 🛠️ Cluster Setup Using PowerShell

After the VMs are running:

1. Run the following command in PowerShell:

```powershell
.\Setup-Cluster.ps1
```

### ✅ What This Script Does:
- Generates and distributes SSH keys to all nodes
- Sets up host aliases in `.bashrc`
- Adds a custom MOTD (Welcome message)
- Configures essential cluster properties

The script dynamically picks IPs and names from the Vagrantfile for full automation.

---

## 🔁 Common Vagrant Commands

| Task                     | Command                            |
|--------------------------|-------------------------------------|
| Start all VMs            | `vagrant up`                       |
| SSH into a VM            | `vagrant ssh <vm-name>`            |
| Stop all VMs             | `vagrant halt`                     |
| Suspend (pause) VMs      | `vagrant suspend`                  |
| Resume suspended VMs     | `vagrant resume`                   |
| Reload VMs               | `vagrant reload`                   |
| Destroy all VMs          | `vagrant destroy`                  |
| Show VM status           | `vagrant status`                   |
| Re-run provisioning      | `vagrant provision`                |

> ℹ️ Example: `vagrant ssh master-1`

---

## 📁 Project Structure

```
.
├── Vagrantfile            # Defines VMs and static IPs
├── Setup-Cluster.ps1      # PowerShell script to configure the cluster
└── README.md              # Project documentation
```

---

## 💾 Backup and Restore

You can back up and restore your Vagrant environment and VM data using the following approaches:

### 🔐 Backup

1. **Backup Vagrant State and Files**
   - Compress the project directory:
     ```bash
     tar -czvf vagrant-cluster-backup.tar.gz vagrant-cluster-setup/
     ```

2. **Snapshot Individual VMs (Optional)**
   - Take a snapshot of a specific VM:
     ```bash
     vagrant snapshot save <vm-name> <snapshot-name>
     ```
     Example:
     ```bash
     vagrant snapshot save master-1 pre-k8s-setup
     ```

### ♻️ Restore

1. **Restore from Snapshot**
   - Restore a specific VM to a previous snapshot:
     ```bash
     vagrant snapshot restore <vm-name> <snapshot-name>
     ```

2. **Restore from Backup Archive**
   - Extract the backup and re-initialize:
     ```bash
     tar -xzvf vagrant-cluster-backup.tar.gz
     cd vagrant-cluster-setup
     vagrant up
     ```

> ⚠️ Snapshots are stored locally per machine and are not portable. For long-term backups or shared environments, use full project directory backup.
