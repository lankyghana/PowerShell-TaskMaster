# PowerShell TaskMaster - PowerShell Automation, Security, Network, and File Copier Tool
# Author: Lanky iTech Solutions
# Version: 1.0
# Date: 2025-06-13

# --- Module Import & Custom Task Loader ---
function Import-Modules {
    $modulesPath = Join-Path $PSScriptRoot 'Modules'
    Get-ChildItem -Path $modulesPath -Directory | ForEach-Object {
        $psm1 = Join-Path $_.FullName ($_.Name + '.psm1')
        if (Test-Path $psm1) {
            Import-Module $psm1 -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-CustomTasks {
    $tasksRoot = Join-Path $PSScriptRoot 'CustomTasks'
    if (-not (Test-Path $tasksRoot)) { return @() }
    $taskDirs = Get-ChildItem -Path $tasksRoot -Directory -ErrorAction SilentlyContinue
    $list = @()
    foreach ($d in $taskDirs) {
        $manifest = Join-Path $d.FullName 'task.json'
        $script = Join-Path $d.FullName 'run.ps1'
        if ((Test-Path $manifest) -and (Test-Path $script)) {
            try {
                $meta = Get-Content $manifest -Raw | ConvertFrom-Json
                $list += [pscustomobject]@{
                    Id = $meta.id
                    Name = $meta.name
                    Description = $meta.description
                    Params = $meta.params
                    Script = $script
                    Dir = $d.FullName
                }
            } catch {
                Write-Warning "Failed to read manifest in $($d.Name): $_"
            }
        }
    }
    return $list
}

function Invoke-CustomTask {
    param([Parameter(Mandatory)]$Task, [Hashtable]$ParameterValues)
    . $Task.Script
    if (Get-Command -Name Invoke-Task -ErrorAction SilentlyContinue) {
        try {
            Invoke-Task -Params $ParameterValues
        } finally {
            if (Get-Command Invoke-Task -ErrorAction SilentlyContinue) {
                Remove-Item Function:\Invoke-Task -ErrorAction SilentlyContinue
            }
        }
    } else {
        Throw "Task script does not expose Invoke-Task function."
    }
}

Import-Modules

function Show-Welcome {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "         Welcome to PowerShell TaskMaster!" -ForegroundColor Green
    Write-Host "   Your all-in-one automation & security tool" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Version 1.0 | Developed by Lanky iTech Solutions | Date: 2025-06-13`n" -ForegroundColor Gray
}

$correctPassword = "ass"
$maxAttempts = 3
$attempts = 0
$authenticated = $false

while ($attempts -lt $maxAttempts -and -not $authenticated) {
    $inputPassword = Read-Host -AsSecureString "Enter the software password"
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputPassword))
    if ($plainPassword -eq $correctPassword) {
        $authenticated = $true
    } else {
        $attempts++
        Write-Host "Incorrect password. Attempts left: $($maxAttempts - $attempts)"
    }
}

if (-not $authenticated) {
    Write-Host "Too many incorrect attempts. Exiting..."
    exit
}

function Show-Menu {
    Write-Host "`nSelect an option:"
    Write-Host "1. Automation Tasks"
    Write-Host "2. Security Checks"
    Write-Host "3. Copy Music Files"
    Write-Host "4. Copy Image Files"
    Write-Host "5. Copy Video Files"
    Write-Host "6. Format a Hard Disk Drive"
    Write-Host "7. Network & Internet Tools"
    Write-Host "8. Exit"
    Write-Host "9. Custom Automation Tasks"
}

function Invoke-AutomationTask {
    Write-Host "\nAutomation Tasks Menu:"
    Write-Host "1. Open Microsoft Word"
    Write-Host "2. Open Microsoft Excel"
    Write-Host "3. Open Notepad"
    Write-Host "4. Open Calculator"
    Write-Host "5. Search the Web (Bing)"
    Write-Host "6. Back to Main Menu"
    $autoChoice = Read-Host "Enter your choice (1-6)"
    switch ($autoChoice) {
        '1' {
            Write-Host "Opening Microsoft Word..."
            Start-Process winword
        }
        '2' {
            Write-Host "Opening Microsoft Excel..."
            Start-Process excel
        }
        '3' {
            Write-Host "Opening Notepad..."
            Start-Process notepad
        }
        '4' {
            Write-Host "Opening Calculator..."
            Start-Process calc
        }
        '5' {
            $query = Read-Host "Enter your research/search query"
            $url = "https://www.bing.com/search?q=$($query -replace ' ', '+')"
            Write-Host "Opening Bing search for: $query"
            Start-Process $url
        }
        '6' { return }
        default { Write-Host "Invalid choice. Returning to main menu." }
    }
}

function Invoke-SecurityCheck {
    Write-Host "Running security checks..."
    # List running processes
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
    # List open TCP ports
    Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' } | Select-Object LocalAddress,LocalPort
}

function Get-SoftwareRootFolder {
    $root = Join-Path (Get-Location) 'AllInOneTool_Files'
    if (!(Test-Path $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
    return $root
}

function Copy-MusicFiles {
    $musicDest = Join-Path (Get-SoftwareRootFolder) 'Music'
    $musicTypes = @('*.mp3','*.wav','*.aac','*.flac','*.ogg','*.wma','*.m4a')
    $exclude = (Get-SoftwareRootFolder)
    Get-ChildItem -Path C:\ -Recurse -Include $musicTypes -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notlike "$exclude*" } |
        ForEach-Object {
            if (!(Test-Path $musicDest)) { New-Item -ItemType Directory -Path $musicDest -Force | Out-Null }
            $destPath = Join-Path $musicDest $_.Name
            Copy-Item $_.FullName -Destination $destPath -Force
        }
    Write-Host "All music files copied successfully to $musicDest."
}

function Copy-ImageFiles {
    $imageDest = Join-Path (Get-SoftwareRootFolder) 'Images'
    $imageTypes = @('*.jpg','*.jpeg','*.png','*.gif','*.bmp','*.tiff','*.tif','*.ico','*.webp','*.svg','*.heic','*.raw')
    $exclude = (Get-SoftwareRootFolder)
    Get-ChildItem -Path C:\ -Recurse -Include $imageTypes -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notlike "$exclude*" } |
        ForEach-Object {
            if (!(Test-Path $imageDest)) { New-Item -ItemType Directory -Path $imageDest -Force | Out-Null }
            $destPath = Join-Path $imageDest $_.Name
            Copy-Item $_.FullName -Destination $destPath -Force
        }
    Write-Host "All image files copied successfully to $imageDest."
}

function Copy-VideoFiles {
    $videoDest = Join-Path (Get-SoftwareRootFolder) 'Videos'
    $videoTypes = @('*.mp4','*.avi','*.mov','*.mkv','*.wmv','*.flv','*.webm','*.mpeg','*.mpg','*.3gp','*.m4v')
    $exclude = (Get-SoftwareRootFolder)
    Get-ChildItem -Path C:\ -Recurse -Include $videoTypes -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notlike "$exclude*" } |
        ForEach-Object {
            if (!(Test-Path $videoDest)) { New-Item -ItemType Directory -Path $videoDest -Force | Out-Null }
            $destPath = Join-Path $videoDest $_.Name
            Copy-Item $_.FullName -Destination $destPath -Force
        }
    Write-Host "All video files copied successfully to $videoDest."
}

function Format-HardDiskDrive {
    $driveLetter = Read-Host "Enter the drive letter to format (e.g., E:)"
    $confirm = Read-Host "Are you sure you want to format drive $driveLetter? This will erase all data! (Y/N)"
    if ($confirm -eq 'Y') {
        try {
            Format-Volume -DriveLetter $driveLetter.TrimEnd(':') -FileSystem NTFS -Confirm:$false
            Write-Host "Drive $driveLetter formatted successfully."
        } catch {
            Write-Host "Failed to format drive: $_"
        }
    } else {
        Write-Host "Format cancelled."
    }
}

function Show-NetworkMenu {
    Write-Host "`nNetwork & Internet Options:"
    Write-Host "1. Show IP Configuration"
    Write-Host "2. Show Active Network Connections"
    Write-Host "3. Test Internet Connectivity (Ping Google)"
    Write-Host "4. Show Wi-Fi Profiles"
    Write-Host "5. Back to Main Menu"
}

function Show-IPConfig {
    Write-Host "`n--- IP Configuration ---"
    ipconfig | Write-Host
}

function Show-NetworkConnections {
    Write-Host "`n--- Active Network Connections ---"
    netstat -ano | Write-Host
}

function Test-InternetConnectivity {
    Write-Host "`n--- Testing Internet Connectivity (Ping google.com) ---"
    Test-Connection google.com -Count 4 | Write-Host
}

function Show-WiFiProfiles {
    Write-Host "`n--- Saved Wi-Fi Profiles and Passwords ---"
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
        ($_ -split ":\s+")[1].Trim()
    }
    $wifiInfo = @()
    $index = 1
    foreach ($wifiProfile in $profiles) {
        $keyOutput = netsh wlan show profile name="$wifiProfile" key=clear
        $passwordLine = $keyOutput | Select-String "Key Content" | ForEach-Object { ($_ -split ":\s+")[1].Trim() }
        $password = if ($passwordLine) { $passwordLine } else { "(No Password Found)" }
        $line = "[$index] Profile: $wifiProfile`n    Password: $password"
        Write-Host $line
        $wifiInfo += $line
        $index++
    }
    $save = Read-Host "Do you want to save this info to a text file? (Y/N)"
    if ($save -eq 'Y') {
        $txtPath = Join-Path (Get-SoftwareRootFolder) "WiFiProfiles_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $content = $wifiInfo -join "`r`n`r`n"
        Set-Content -Path $txtPath -Value $content -Encoding UTF8
        Write-Host "Wi-Fi profiles and passwords saved to $txtPath"
    }
}

function Show-NetworkInternetMenu {
    while ($true) {
        Show-NetworkMenu
        $netChoice = Read-Host "Enter your choice (1-5)"
        switch ($netChoice) {
            '1' { Show-IPConfig }
            '2' { Show-NetworkConnections }
            '3' { Test-InternetConnectivity }
            '4' { Show-WiFiProfiles }
            '5' { break }
            default { Write-Host "Invalid choice. Please try again." }
        }
    }
}

Show-Welcome

while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-9)"
    switch ($choice) {
        '1' { Invoke-AutomationTask }
        '2' { Invoke-SecurityCheck }
        '3' { Copy-MusicFiles }
        '4' { Copy-ImageFiles }
        '5' { Copy-VideoFiles }
        '6' { Format-HardDiskDrive }
        '7' { Show-NetworkInternetMenu }
        '8' { break }
        '9' {
            $customTasks = Get-CustomTasks
            if ($customTasks.Count -gt 0) {
                Write-Host "Custom Automation Tasks Available:" -ForegroundColor Cyan
                for ($i=0; $i -lt $customTasks.Count; $i++) {
                    Write-Host "$($i+1)): $($customTasks[$i].Name) - $($customTasks[$i].Description)"
                }
                $choice2 = Read-Host 'Select a custom task number (or Enter to skip)'
                if ([int]::TryParse($choice2, [ref]$n) -and $n -ge 1 -and $n -le $customTasks.Count) {
                    $selected = $customTasks[$n-1]
                    $paramValues = @{}
                    foreach ($p in $selected.Params) {
                        $val = Read-Host "Enter value for $($p.name) [$($p.type)]"
                        $paramValues[$p.name] = $val
                    }
                    Invoke-CustomTask -Task $selected -ParameterValues $paramValues
                }
            } else {
                Write-Host "No custom tasks found in CustomTasks folder."
            }
        }
        default { Write-Host "Invalid choice. Please try again." }
    }
}
