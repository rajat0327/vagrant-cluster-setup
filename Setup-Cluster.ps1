$ErrorActionPreference = "Stop"

# Paths and VM info
$sshDir = "$HOME\.ssh"
$idRsa = "$sshDir\id_rsa"
$idRsaPub = "$sshDir\id_rsa.pub"

$nodes = @(
    @{ name = "master-1"; ip = "192.168.56.11" },
    @{ name = "worker-1"; ip = "192.168.56.12" },
    @{ name = "worker-2"; ip = "192.168.56.13" }
)

# SSH helper function
function Invoke-SSH {
    param (
        [string]$ip,
        [string]$command
    )
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "rajat@$ip" "$command" 2>$null
}

# Ensure SSH directory exists
if (-Not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
}

# Generate SSH key if not present
if (-Not (Test-Path $idRsa)) {
    Write-Host "🔐 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f $idRsa -N ""
}

# Remove old known_hosts entries
foreach ($node in $nodes) {
    Write-Host "🧹 Removing known_hosts entry for $($node["ip"])..."
    ssh-keygen -R $node["ip"] | Out-Null
}

# Copy SSH key to each node
foreach ($node in $nodes) {
    Write-Host "📤 Copying SSH key to $($node["name"]) ($($node["ip"]))..."
    $pubKey = Get-Content $idRsaPub -Raw
    Invoke-SSH $node["ip"] "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && grep -qxF '$pubKey' ~/.ssh/authorized_keys || echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
}

# Collect public keys from all servers
$publicKeys = @{}
foreach ($node in $nodes) {
    Write-Host "🔐 Generating VM key on $($node["name"])..."
    Invoke-SSH $node["ip"] '[[ -f ~/.ssh/id_rsa ]] || ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""'
    $key = ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "rajat@$($node["ip"])" "cat ~/.ssh/id_rsa.pub" 2>$null

    if (-not $key) {
        throw "❌ Failed to retrieve public key from $($node["name"])"
    }

    $publicKeys[$node["name"]] = $key
}

# Get local public key
$localKey = Get-Content $idRsaPub -Raw

# Distribute all keys across all nodes (mesh + local)
foreach ($target in $nodes) {
    Write-Host "🔁 Setting authorized_keys on $($target["name"])..."

    $allKeys = @(
        $publicKeys["master-1"]
        $publicKeys["worker-1"]
        $publicKeys["worker-2"]
        $localKey
    )

    $joinedKeys = ($allKeys -join "`n").Replace("`r", "")
    $escapedKeys = $joinedKeys.Replace('"', '\"')

    Invoke-SSH $target["ip"] "mkdir -p ~/.ssh && echo `"$escapedKeys`" > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
}

# Disable dynamic MOTD and set static MOTD
foreach ($node in $nodes) {
    $motd = "🌟 Welcome to $($node["name"]) node IP: $($node["ip"])🌟"
    Write-Host "📣 Setting MOTD on $($node["name"])..."


    $setupMotd = @"
sudo chmod -x /etc/update-motd.d/* &&
echo -e $motd | sudo tee /etc/motd >/dev/null
"@

    Invoke-SSH $node["ip"] $setupMotd
}

# Add SSH aliases to each node's .bashrc using heredoc (no quoting issues)
foreach ($node in $nodes) {
    Write-Host "🔗 Creating SSH aliases on $($node["name"])..."

    $aliasCommands = @(
        "alias m1='ssh master-1'",
        "alias w1='ssh worker-1'",
        "alias w2='ssh worker-2'"
    )

    foreach ($aliasCmd in $aliasCommands) {
        Invoke-SSH $node["ip"] "grep -qxF '$aliasCmd' ~/.bashrc || echo `"$aliasCmd`" >> ~/.bashrc"
    }
}


# Add PowerShell aliases locally
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

foreach ($node in $nodes) {
    $aliasName = $node["name"]
    $sshCommand = "ssh -i `"$idRsa`" rajat@$($node["ip"])"
    $aliasLine = "Set-Alias -Name $aliasName -Value `"$sshCommand`""

    if (-not (Select-String -Path $profilePath -Pattern $aliasName -Quiet)) {
        Add-Content -Path $profilePath -Value $aliasLine
    }
}

Write-Host "`n🎯 Completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "✅ Reload PowerShell with `. `$PROFILE` or restart the terminal to use the aliases."
