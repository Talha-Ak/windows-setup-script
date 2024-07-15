# This script can be run using the following command in a PowerShell window:
# irm 'https://setup.talhaak.com' | iex
$programs = @(
    [pscustomobject]@{Name = "7-Zip"; Id = '7zip.7zip'; Source = "winget" },
    [pscustomobject]@{Name = "Arc"; Id = 'TheBrowserCompany.Arc'; Source = "winget" },
    [pscustomobject]@{Name = "Audacity"; Id = 'Audacity.Audacity'; Source = "winget" },
    [pscustomobject]@{Name = "Brave"; Id = 'Brave.Brave'; Source = "winget" },
    [pscustomobject]@{Name = "Bitwarden"; Id = 'Bitwarden.Bitwarden'; Source = "winget" },
    [pscustomobject]@{Name = "Chrome"; Id = 'Google.Chrome'; Source = "winget" },
    [pscustomobject]@{Name = "Discord"; Id = 'Discord.Discord'; Source = "winget" },
    [pscustomobject]@{Name = "Epic Games Launcher"; Id = 'EpicGames.EpicGamesLauncher'; Source = "winget" },
    [pscustomobject]@{Name = "Firefox"; Id = 'Mozilla.Firefox'; Source = "winget" },
    [pscustomobject]@{Name = "GeForce Experience"; Id = 'Nvidia.GeForceExperience'; Source = "winget" },
    [pscustomobject]@{Name = "Git"; Id = 'Git.Git'; Source = "winget" },
    [pscustomobject]@{Name = "HandBrake"; Id = 'HandBrake.HandBrake'; Source = "winget" },
    [pscustomobject]@{Name = "Heroic Games Launcher"; Id = 'HeroicGamesLauncher.HeroicGamesLauncher'; Source = "winget" },
    [pscustomobject]@{Name = "Nearby Share"; Id = 'Google.NearbyShare'; Source = "winget" },
    [pscustomobject]@{Name = "OBS Studio"; Id = 'OBSProject.OBSStudio'; Source = "winget" },
    [pscustomobject]@{Name = "Obsidian"; Id = 'Obsidian.Obsidian'; Source = "winget" },
    [pscustomobject]@{Name = "Parsec"; Id = 'Parsec.Parsec'; Source = "winget" },
    [pscustomobject]@{Name = "Plex"; Id = 'Plex.Plex'; Source = "winget" },
    [pscustomobject]@{Name = "PowerToys (Preview)"; Id = 'Microsoft.PowerToys'; Source = "winget" },
    [pscustomobject]@{Name = "qBittorrent"; Id = 'qBittorrent.qBittorrent'; Source = "winget" },
    [pscustomobject]@{Name = "Rainmeter"; Id = 'Rainmeter.Rainmeter'; Source = "winget" },
    [pscustomobject]@{Name = "Spicetify"; Id = 'Spicetify.Spicetify'; Source = "winget" },
    [pscustomobject]@{Name = "Spotify"; Id = 'Spotify.Spotify'; Source = "winget" },
    [pscustomobject]@{Name = "Steam"; Id = 'Valve.Steam'; Source = "winget" },
    [pscustomobject]@{Name = "Tailscale"; Id = 'tailscale.tailscale'; Source = "winget" },
    [pscustomobject]@{Name = "VLC"; Id = 'VideoLAN.VLC'; Source = "winget" },
    [pscustomobject]@{Name = "Voicemeeter Banana"; Id = 'VB-Audio.Voicemeeter.Banana'; Source = "winget" },
    [pscustomobject]@{Name = "VS Code"; Id = 'Microsoft.VisualStudioCode'; Source = "winget" },
    [pscustomobject]@{Name = "WinDynamicDesktop"; Id = 't1m0thyj.WinDynamicDesktop'; Source = "winget" },
    [pscustomobject]@{Name = "WizTree"; Id = 'AntibodySoftware.WizTree'; Source = "winget" },
    [pscustomobject]@{Name = "yt-dlp"; Id = 'yt-dlp.yt-dlp'; Source = "winget" }
)

function Invoke-MenuPrompt {
    param (
        [string]$title,
        [string]$msg, 
        [System.Management.Automation.Host.ChoiceDescription[]]$options,
        [int]$default = 0
    )

    $response = $Host.UI.PromptForChoice($title, $msg, $options, $default)
    Write-Host ""
    return $response
}

function Test-Winget {
    return Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe
}

function Get-Winget {
    $title = "Winget not installed"
    $msg = "Attempt to install winget? (Required)"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Will download & install winget."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Will exit the script."
    $options = $yes, $no

    $response = Invoke-MenuPrompt $title $msg $options

    If ($response -eq 1) {
        Write-Host "Not installing winget. Aborting script."
        break
    }

    If ($null -eq (Get-AppxPackage Microsoft.WindowsStore)) {
        Get-WingetManually
    }
    Else {
        Try {
            Write-Host "Trying to install Winget via Microsoft Store."
            Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
            $nid = (Get-Process AppInstaller).Id
            Wait-Process -Id $nid
        }
        Catch {    
            Get-WingetManually
        }
    }

    If (!(Test-Winget)) {
        Write-Host "Could not install Winget. Aborting script."
        break
    }
}

function Get-WingetManually {
    Write-Host "Trying to install Winget manually."
    $ProgressPreference = 'SilentlyContinue'
    Write-Host 'Downloading Visual C++ libraries...'
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Write-Host 'Installing Visual C++ libraries...'
    Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx

    $releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1
    
    Write-Host "Downloading Winget from $($latestRelease.browser_download_url)."
    Invoke-WebRequest -Uri $latestRelease.browser_download_url -OutFile $latestRelease.name
    Write-Host "Installing Winget."
    Add-AppxPackage -Path $latestRelease.name
    Write-Host ""
}

function Get-UserProgramSelection {
    $selected = $null
    do {
        $selected = $programs | Out-GridView -Title "Select one or more programs to install" -PassThru
        if ($null -eq $selected) {
            $title = "No programs selected"
            $msg = "Exit script?"
            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                "Will exit the script."
            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                "Will re-prompt program selection."
            $options = $yes, $no
    
            $response = Invoke-MenuPrompt $title $msg $options 1
            If ($response -eq 0) {
                Write-Host "Exiting script."
                Exit
            }
        }
    } while (
        $null -eq $selected
    )

    return $selected
}

function Get-UserProgramConfirmation {
    $title = "Program installation"
    $msg = "Install the selected programs?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Will install all selected programs."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Will not install any programs, and prompt for program re-selection."
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", `
        "Will not install any programs, and exit the script."
    $options = $yes, $no, $exit

    $response = Invoke-MenuPrompt $title $msg $options 0
    return $response
}

function Install-WingetPackages {
    param (
        [pscustomobject[]]$packages
    )

    foreach ($package in $packages) {
        If ("MS Store" -eq $package.Source) {
            Invoke-Expression "winget install --id=$($package.Id) --accept-package-agreements --accept-source-agreements -s msstore"
        }
        else {
            Invoke-Expression "winget install --id=$($package.Id) -e --accept-package-agreements --accept-source-agreements"
        }
    }
}

# --------------------------------------------

Write-Host "Clean Windows Program Installer"

If (!(Test-Winget)) {
    Get-Winget 
}

$confirm = $null
Do {
    $selected = Get-UserProgramSelection
    Write-Host "The following programs were selected."
    $selected | Format-Table -AutoSize
    $confirm = Get-UserProgramConfirmation
} While (
    $confirm -eq 1
)

If ($confirm -eq 2) {
    Write-Host "Exiting script..."
    Exit
}

Install-WingetPackages $selected
