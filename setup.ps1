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
    if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
        Write-Host "Winget is installed and functional." -ForegroundColor Green
        return $true
    } else {
        Write-Warning "Winget is not installed, or not found in PATH"
        return $false
    }
}

function Get-Winget {
    Write-Host "Attempting to install Winget from the Microsoft Store (App Installer)."

    If ($null -eq (Get-AppxPackage Microsoft.WindowsStore -ErrorAction SilentlyContinue)) {
        Write-Host "Microsoft Store not found."
    }
    Else {
        Write-Host "Attempting to open the Microsoft Store for Winget (App Installer)."
        Try {
            Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget" -ErrorAction Stop 
            Write-Host ""
            Write-Host "The Microsoft Store page for App Installer (which includes Winget) should now be open." -ForegroundColor Cyan
            Write-Host "Please install or update it from the Store." -ForegroundColor Cyan
            Write-Host "After the installation from the Store is complete, please RE-RUN THIS SCRIPT." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "This script will now exit to allow you to complete the Store installation."
            Exit 0
        }
        Catch {
            Write-Warning "Failed to open the Microsoft Store for Winget installation: $($_.Exception.Message)"
        }
    }

    If (!(Test-Winget)) {
        Write-Host "Could not install Winget. Aborting script."
        Exit 1
    }
}

function Get-UserProgramSelection {
    $selected = $null
    do {
        $selected = $programs | Out-GridView -Title "Select programs to install (Ctrl+Click for multiple)" -PassThru
        if ($null -eq $selected) {
            $title = "No programs selected"
            $msg = "No programs were selected. Do you want to exit the script?"
            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                "Will exit the script."
            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                "Will re-prompt program selection."
            $options = $yes, $no
    
            $response = Invoke-MenuPrompt $title $msg $options 1
            If ($response -eq 0) {
                Write-Host "Exiting script." -ForegroundColor Yellow
                Exit 1
            }
        }
    } while (
        $null -eq $selected
    )

    return $selected
}

function Get-UserProgramConfirmation {
    $title = "Program installation"
    $msg = "Proceed with installing these program(s)?"
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

function Install-WingetPackages {
    param (
        [pscustomobject[]]$packagesToInstall,
        [System.Collections.Generic.List[string]]$FailedList 
    )

    Write-Host "`nStarting program installations..." -ForegroundColor Cyan
    foreach ($package in $packagesToInstall) {
        Write-Host "------------------------------------------------------------"
        Write-Host "Attempting to install: $($package.Name) (ID: $($package.Id))"
        
        # Winget arguments:
        # --exact: Ensures the ID matches exactly.
        # --accept-package-agreements: Auto-accepts license agreements from the package.
        # --accept-source-agreements: Auto-accepts agreements from the source (e.g., winget repository).
        # --disable-interactivity: Attempts to run installers silently if supported by the package.
        $wingetArgs = @("install", "--id", $package.Id, "--exact", "--accept-package-agreements", "--accept-source-agreements", "--disable-interactivity")
        $wingetArgs += "--source", "winget"
        
        Write-Host "Executing: winget $($wingetArgs -join ' ')"

        try {
            $process = Start-Process winget -ArgumentList $wingetArgs -Wait -NoNewWindow -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "$($package.Name) installed successfully or was already installed." -ForegroundColor Green
            } else {
                Write-Warning "Failed to install $($package.Name). Winget process exited with code: $($process.ExitCode)."
                $FailedList.Add($package.Name)
            }
        }
        catch {
            Write-Error "An unexpected error occurred while trying to run winget for $($package.Name): $($_.Exception.Message)"
            $FailedList.Add($package.Name)
        }
    }
    Write-Host "------------------------------------------------------------"
}


# --------------------------------------------
# Main Script Execution
# --------------------------------------------

Write-Host "Clean Windows Program Installer" -ForegroundColor Cyan

If (!(Test-Winget)) {
    Get-Winget 
}

$confirm = 1
Do {
    $selected = Get-UserProgramSelection
    Write-Host "You have selected the following programs for installation:"
    $selected | Format-Table -Property Name, Id -AutoSize
    $confirm = Get-UserProgramConfirmation
} While (
    $confirm -eq 1
)

If ($confirm -eq 2) {
    Write-Host "Exiting script..." -ForegroundColor Yellow
    Exit 0
}

$failedInstallations = [System.Collections.Generic.List[string]]::new()

Install-WingetPackages $selected $failedInstallations

Write-Host "Script Execution Finished." -ForegroundColor Cyan

if ($failedInstallations.Count -gt 0) {
    Write-Warning "`nThe following $($failedInstallations.Count) package(s) may have failed to install or encountered errors:"
    foreach ($failedPackageName in $failedInstallations) {
        Write-Warning "- $failedPackageName"
    }
    Write-Warning "Please check the output above for specific error messages from Winget."
} else {
    Write-Host "`nAll selected programs were processed. Check output above for details." -ForegroundColor Green
}

Write-Host "You can now close this window." -ForegroundColor Green
