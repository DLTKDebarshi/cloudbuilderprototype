<powershell>
# Windows Server User Data Script
# Configure the server with username and password from GitHub secrets

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

# Enable WinRM for Ansible
Write-Output "Configuring WinRM for remote management..."
winrm quickconfig -q
winrm set winrm/config/service/Auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'

# Enable firewall rules for WinRM
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
New-NetFirewallRule -DisplayName "WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

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

Write-Output "Server configuration completed successfully!"
Write-Output "IIS is running and ready for application deployment."

Stop-Transcript
</powershell>