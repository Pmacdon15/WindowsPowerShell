oh-my-posh init pwsh --config 'C:\Users\pmacd\AppData\Local\Programs\oh-my-posh\themes\kali.omp.json' | Invoke-Expression

Import-Module -Name Terminal-Icons

# fzf
Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -ScriptBlock {
    $file = fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($file)
}

# Replace ls with eza.exe
function Get-Func {
    [Alias('ls')]
    param (
        [string]$Path # path for ls
    )
    eza.exe --icons=always $Path
}


# use zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Set the default editor to code-insiders
$env:EDITOR = "code-insiders --wait"

# Go to the Desktop
z Desktop

# Helper functions
function makeQr {
    param(
        [string]$data,
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: makeQr [-data] [-h] [-help]"
        Write-Host "Generate a QR code for a URL."
        Write-Host "Options:"
        Write-Host "-data: The URL to generate a QR code for(switch optional)."
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }

    if (-not $data) {
        $data = Read-Host "Enter a URL"
    }    
    # Construct the QR code URL
    $qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$data"

    # Specify the desktop path
    $desktopPath = [System.Environment]::GetFolderPath('Desktop')

    # Extract the URL's hostname and path
    $urlParts = $data -split '/'
    $fileName = $urlParts[-1] + ".png"

    # Combine the desktop path and file name
    $qrCodeFilePath = Join-Path -Path $desktopPath -ChildPath $fileName

    # Download the QR code image to the desktop
    Invoke-WebRequest -Uri $qrCodeUrl -OutFile $qrCodeFilePath

    # Open the QR code image using the default application
    Invoke-Item $qrCodeFilePath
}
function hide {
    param(
        [string]$fileHost,
        [string]$fileSecret,
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: hide [-fileHost] [-fileSecret] [-s] [-h] [-help]"
        Write-Host "Hide a file in an image."
        Write-Host "Options:"
        Write-Host "-fileHost: The image file to hide the secret file in. (switch optional)"
        Write-Host "-fileSecret: The secret file to hide in the image.(switch optional)"        
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }
       
    steghide embed -cf $fileHost -ef $fileSecret
}
function extract {
    param(
        [string]$file,
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: extract [-file] [-s] [-h] [-help]"
        Write-Host "Extract a file from an image."
        Write-Host "Options:"
        Write-Host "-file: The image file to extract the secret file from.(switch optional)"        
        Write-Host "-h: Display this help message."
    }       
    steghide extract -sf $file
}

function speak {
    param(
        [string]$text,
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: speak [-text] [-h] [-help]"
        Write-Host "Make the computer speak."
        Write-Host "Options:"
        Write-Host "-text: The text for the computer to speak. Default is the text you enter.(switch optional)"
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }
    if (-not $text) {
        $text = Read-Host "Enter the text for me to speak"
    }
    Add-Type -AssemblyName System.Speech
    $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speak.Speak($text)
}

function ci {
    param(
        [string]$repo,
        [switch]$d,
        [switch]$help,
        [switch]$h
    )
    if ($help -or $h) {
        Write-Host "Usage: ci [-repo] [-d] [-h]"
        Write-Host "Open a repository in VS Code."
        Write-Host "Options:"
        Write-Host "-repo: The repository to open.(switch optional)"        
        Write-Host "-d: Open the repository in the Desktop."
        Write-Host "-h: Display this help message."
        return
    }
    if ($c) {
        code-insiders .\
        break
    }
    if ($d) {
        code-insiders C:\Users\pmacd\Desktop\ 
        break
    }
    code-insiders $repo
}
function clone {
    param(
        [string]$repo,
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: clone [-repo] [-h] [-help]"
        Write-Host "Clone a repository. If no repository is specified, the clipboard is used as the default."
        Write-Host "Options:"
        Write-Host "-repo: The repository to clone. Default is the clipboard.(switch optional)"
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }
    if (-not $repo) {
        $repo = Get-Clipboard -Format Text
    }
    git clone $repo
}


function get {
    param(
        [string]$url,
        [switch]$h,
        [switch]$help        
    )
    if ($help -or $h) {
        Write-Host "Usage: get [-url] [-h] [-help]"
        Write-Host "Make a GET request to a URL."
        Write-Host "Options:"
        Write-Host "-url: The URL to make a GET request to.(switch optional)"
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }
    Invoke-WebRequest -Uri $url -Method GET

}

function cleanNode {
    param(
        [string]$path = ".",
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: clean [-path] [-h] [-help]"
        Write-Host "Remove all node_modules directories in the specified path."
        Write-Host "Options:"
        Write-Host "-path: The path to search for node_modules. Default is current directory."
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }
    
    Get-ChildItem -Path $path -Filter "node_modules" -Recurse | Remove-Item -Recurse -Force
    Write-Host "Removed all node_modules directories in $path"
}
function sudo {
    param(
        [switch]$h,
        [switch]$help
    )
    if ($help -or $h) {
        Write-Host "Usage: sudo [-h] [-help]"
        Write-Host "Use 'sudo' to run PowerShell as an administrator."
        Write-Host "Options:"
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        return
    }
    Start-Process powershell -Verb RunAs
}

# Git functions
function gr {
    $remoteUrl = git remote -v | Select-String -Pattern "git@github.com" | Select-Object -First 1 | ForEach-Object { ($_ -split '\s+')[1] }
    $remoteUrl | clip
    Write-Output $remoteUrl
}

function ga { git add . }
function gitc {
    param (
        [string]$message,
        [switch]$h,
        [switch]$help,
        [switch]$fc
    )
    if ($help -or $h) {
        Write-Host "Usage: gitcm [-message] [-h] [-help] [-fc]"
        Write-Host "Commit changes to the repository."
        Write-Host "Options:"
        Write-Host "-message: The commit message."
        Write-Host "-h: Display this help message."
        Write-Host "-help: Display this help message."
        Write-Host "-fc: Commit all changes with the specified message 'first commit'."
        return
    }
    elseif ($fc) {
        git commit -m "first commit"
        return
    }    if (-not $message) {
        Write-Host "Error: Commit message is required."
        return
    } 
    git commit -m $message
}

function ghrc{gh repo create}

function ghb{gh browse}