<powershell>
# Windows Server User Data Script

# Set execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable PowerShell logging
Start-Transcript -Path "C:\Windows\Temp\userdata.log" -Append

Write-Output "Starting Windows Server configuration..."

# Create local user account with credentials from GitHub secrets
$username = "${username}"
$password = "${password}"

if ($username -and $password) {
    Write-Output "Creating user account: $username"
    
    # Convert password to SecureString
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    
    try {
        # Check if user already exists
        $existingUser = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
        
        if ($existingUser) {
            Write-Output "User $username already exists. Updating password..."
            Set-LocalUser -Name $username -Password $securePassword
        } else {
            # Create new local user
            New-LocalUser -Name $username -Password $securePassword -FullName $username -Description "User created by Terraform from GitHub secrets" -PasswordNeverExpires:$true -AccountNeverExpires:$true
            Write-Output "User $username created successfully"
        }
        
        # Ensure user is in Administrators group
        $isAdmin = Get-LocalGroupMember -Group "Administrators" -Member $username -ErrorAction SilentlyContinue
        if (-not $isAdmin) {
            Add-LocalGroupMember -Group "Administrators" -Member $username
            Write-Output "User $username added to Administrators group"
        } else {
            Write-Output "User $username is already in Administrators group"
        }
        
        # Enable the account (in case it was disabled)
        Enable-LocalUser -Name $username
        Write-Output "User account configuration completed successfully"
    }
    catch {
        Write-Output "Error configuring user: $($_.Exception.Message)"
        Write-Output "Stack trace: $($_.Exception.StackTrace)"
    }
} else {
    Write-Output "ERROR: Username or password not provided from GitHub secrets"
    Write-Output "Please ensure USERNAME and PASSWORD secrets are configured in GitHub"
}

# Disable Windows Firewall completely for initial setup
Write-Output "Disabling Windows Firewall for remote access..."
try {
    netsh advfirewall set allprofiles state off
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Write-Output "Windows Firewall disabled successfully"
}
catch {
    Write-Output "Error disabling Windows Firewall: $($_.Exception.Message)"
}

# Enable RDP with comprehensive configuration
Write-Output "Enabling RDP with comprehensive settings..."
try {
    # Enable RDP in registry
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0
    
    # Enable RDP through Windows Features
    Enable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart -ErrorAction SilentlyContinue
    
    # Configure RDP settings
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
    
    # Enable Remote Desktop firewall rules
    netsh firewall set service remotedesktop enable
    netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
    
    Write-Output "RDP enabled successfully"
}
catch {
    Write-Output "Error enabling RDP: $($_.Exception.Message)"
}

# Ensure Administrator account is enabled and configured
Write-Output "Configuring Administrator account..."
try {
    # Enable Administrator account
    net user Administrator /active:yes
    
    # Set password for Administrator if provided
    if ($username -and $password) {
        net user $username $password /add /y
        net localgroup "Administrators" $username /add
        net localgroup "Remote Desktop Users" $username /add
        Write-Output "User $username configured successfully"
    }
    
    # Also ensure Administrator has the password
    if ($password) {
        net user Administrator $password
        Write-Output "Administrator password set successfully"
    }
}
catch {
    Write-Output "Error configuring user accounts: $($_.Exception.Message)"
}

# Enable WinRM for Ansible
Write-Output "Configuring WinRM for remote management..."
try {
    # Enable PowerShell remoting
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    
    # Configure WinRM service
    winrm quickconfig -q -force
    winrm set winrm/config/service/Auth '@{Basic="true"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service '@{CertificateThumbprint=""}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/client '@{TrustedHosts="*"}'
    
    # Create WinRM HTTP listener
    winrm create winrm/config/Listener?Address=*+Transport=HTTP -ErrorAction SilentlyContinue
    
    # Start and configure WinRM service
    Stop-Service WinRM -Force -ErrorAction SilentlyContinue
    Start-Service WinRM
    Set-Service WinRM -StartupType Automatic
    
    Write-Output "WinRM service configured successfully"
}
catch {
    Write-Output "Error configuring WinRM: $($_.Exception.Message)"
}

# Enable firewall rules for WinRM
try {
    New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName "WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow -ErrorAction SilentlyContinue
    Write-Output "WinRM firewall rules configured successfully"
}
catch {
    Write-Output "Error configuring WinRM firewall rules: $($_.Exception.Message)"
}

# Install IIS and management tools
Write-Output "Installing IIS and required features..."
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45 -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole -All

# Install .NET Framework 4.8 or later (required for modern .NET apps)
Write-Output "Installing .NET Framework..."
$dotnetUrl = "https://download.microsoft.com/download/2/d/e/2de47459-26fe-4d9c-a21a-c9040d89d8c2/NDP48-x86-x64-AllOS-ENU.exe"
$dotnetPath = "C:\Windows\Temp\NDP48-x86-x64-AllOS-ENU.exe"

try {
    Invoke-WebRequest -Uri $dotnetUrl -OutFile $dotnetPath
    Start-Process -FilePath $dotnetPath -ArgumentList "/quiet" -Wait
    Write-Output ".NET Framework installation completed"
}
catch {
    Write-Output "Error installing .NET Framework: $($_.Exception.Message)"
}

# Install .NET Core Runtime
Write-Output "Installing .NET Core Runtime..."
$dotnetCoreUrl = "https://download.microsoft.com/download/6/0/2/602a459f-94d0-45d9-aec9-da8b6a83c81c/dotnet-hosting-6.0.28-win.exe"
$dotnetCorePath = "C:\Windows\Temp\dotnet-hosting-6.0.28-win.exe"

try {
    Invoke-WebRequest -Uri $dotnetCoreUrl -OutFile $dotnetCorePath
    Start-Process -FilePath $dotnetCorePath -ArgumentList "/quiet" -Wait
    Write-Output ".NET Core Runtime installation completed"
}
catch {
    Write-Output "Error installing .NET Core Runtime: $($_.Exception.Message)"
}

# Start IIS
Write-Output "Starting IIS service..."
Start-Service W3SVC
Set-Service W3SVC -StartupType Automatic

# Create default application directory
$appDir = "C:\Apps\WebApp"
if (!(Test-Path $appDir)) {
    New-Item -ItemType Directory -Path $appDir -Force
    Write-Output "Created application directory: $appDir"
}

# Set permissions on app directory
icacls $appDir /grant "IIS_IUSRS:(OI)(CI)F" /T

# Create a simple HTML page to verify deployment
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>CloudBuilder Prototype - Server Ready</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin: 50px; }
        .container { max-width: 600px; margin: 0 auto; }
        .status { color: green; font-size: 24px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>CloudBuilder Prototype</h1>
        <p class="status">✅ Server is ready for deployment!</p>
        <p>Windows Server with IIS is configured and running.</p>
        <p>Server configured at: $(Get-Date)</p>
        <p>Username: $username</p>
    </div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding UTF8

# Final diagnostic check
Write-Output "=== FINAL CONFIGURATION STATUS ==="
Write-Output "Windows Firewall Status:"
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table

Write-Output "WinRM Service Status:"
Get-Service WinRM | Format-Table

Write-Output "WinRM Configuration:"
winrm enumerate winrm/config/listener

Write-Output "RDP Configuration:"
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"

Write-Output "IIS Service Status:"
Get-Service W3SVC | Format-Table

Write-Output "Network Connections:"
Get-NetTCPConnection -LocalPort 5985,5986,3389,80,443 -ErrorAction SilentlyContinue | Format-Table

# Write configuration status to Windows Event Log
try {
    New-EventLog -LogName Application -Source "CloudBuilderSetup" -ErrorAction SilentlyContinue
    Write-EventLog -LogName Application -Source "CloudBuilderSetup" -EventId 1001 -EntryType Information -Message "CloudBuilder Windows setup completed successfully. RDP and WinRM should be accessible."
}
catch {
    Write-Output "Could not write to event log: $($_.Exception.Message)"
}

# Create a simple status file
$statusInfo = @{
    "Timestamp" = Get-Date
    "Username" = $username
    "RDPEnabled" = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections -eq 0
    "WinRMRunning" = (Get-Service WinRM).Status -eq "Running"
    "FirewallDisabled" = (Get-NetFirewallProfile | Where-Object {$_.Enabled -eq $true}).Count -eq 0
    "IISRunning" = (Get-Service W3SVC).Status -eq "Running"
}

$statusInfo | ConvertTo-Json | Out-File -FilePath "C:\CloudBuilderStatus.json" -Encoding UTF8

Write-Output "Server configuration completed successfully!"
Write-Output "IIS is running and ready for application deployment."
Write-Output "Status file created at C:\CloudBuilderStatus.json"
Write-Output "=== END CONFIGURATION STATUS ==="

Stop-Transcript
</powershell>