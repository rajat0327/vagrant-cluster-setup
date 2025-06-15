````markdown
# ⚙️ Virtualized Kubernetes Cluster with Vagrant + PowerShell

This repository contains a Vagrant configuration and PowerShell automation script for setting up a local multi-node Kubernetes cluster using VirtualBox.

---

## 📋 Prerequisites

Ensure you have the following installed:

- [VirtualBox](https://www.virtualbox.org/) (6.x or higher)
- [Vagrant](https://www.vagrantup.com/) (2.2.x or higher)
- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (on Windows/macOS/Linux)
- OpenSSH (`ssh`, `ssh-copy-id`) available in your PowerShell environment
- Git (optional, for cloning this repo)

---

## 🚀 Initial Setup Instructions

1. **Clone this repository**:

```bash
git clone https://github.com/rajat0327/vagrant-cluster-setup.git
cd vagrant-cluster-setup
```

2. **Start the Virtual Machines**:

```bash
vagrant up
```

This provisions 3 VMs:

* `master-1` – Kubernetes master node
* `worker-1` – Kubernetes worker node
* `worker-2` – Kubernetes worker node

3. **Verify VM Status**:

```bash
vagrant status
```

---

## 🛠️ Cluster Setup with PowerShell

Once the VMs are up and running:

1. Open PowerShell in admin mode and run:

```powershell
.\Setup-Cluster.ps1
```

This script performs:

* SSH key generation & distribution
* Host alias setup in `.bashrc`
* Custom MOTD banner setup for each node
* Basic configuration for Kubernetes cluster networking

💡 The script auto-detects and configures `master-1`, `worker-1`, and `worker-2` using their static IPs defined in the `Vagrantfile`.

---

## 🔁 Common Vagrant Commands

| Task                 | Command                 |
| -------------------- | ----------------------- |
| Start all VMs        | `vagrant up`            |
| SSH into a VM        | `vagrant ssh <vm-name>` |
| Stop all VMs         | `vagrant halt`          |
| Suspend (pause) VMs  | `vagrant suspend`       |
| Resume suspended VMs | `vagrant resume`        |
| Reload VMs           | `vagrant reload`        |
| Destroy all VMs      | `vagrant destroy`       |
| Show status          | `vagrant status`        |
| Re-run provisioning  | `vagrant provision`     |

---

## 📁 Project Structure

```
.
├── Vagrantfile            # Defines 3-node cluster and provisioning shell scripts
├── Setup-Cluster.ps1      # PowerShell automation to configure and secure the cluster
└── README.md              # You're reading it!
```

---
