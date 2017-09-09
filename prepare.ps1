Import-Module BitsTransfer

# 1. Chocolatey installs 
choco install directx -y
choco install 7zip -y
choco install emulationstation.install -y


# 2. Acqurie files 
$requirementsFolder = "$PSScriptRoot\requirements\"
New-Item -ItemType Directory -Force -Path $requirementsFolder

Get-Content download_list.json | ConvertFrom-Json | Select -expand downloads | ForEach-Object {

    $url = $_.url
    $file = $_.file
    $output = $requirementsFolder + $file

    if(![System.IO.File]::Exists($output)){

        Write-Host $file "does not exist...Downloading."
        Start-BitsTransfer -Source $url -Destination $output
        Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    } else {

        Write-Host $file "Already exists...Skipping download."

    }

}


# 3. Generate es_systems.cfg
& 'C:\Program Files (x86)\EmulationStation\emulationstation.exe'
$configPath = $env:userprofile+"\.emulationstation\es_systems.cfg"

while (!(Test-Path $configPath)) { 
    Write-Host "Checking for config file..."
    Start-Sleep 2
}

Stop-Process -Name "emulationstation"


# 4. Prepare retroarch
$retroArchPath = $env:userprofile + "\.emulationstation\systems\retroarch\"
$retroArchBinary = $requirementsFolder + "\RetroArch.7z"

New-Item -ItemType Directory -Force -Path $retroArchPath

Function Expand-Archive([string]$Path, [string]$Destination) {
    $7z_Application = "C:\Program Files\7-Zip\7z.exe"
    $7z_Arguments = @(
        'x'                         ## eXtract files with full paths
        '-y'                        ## assume Yes on all queries
        "`"-o$($Destination)`""     ## set Output directory
        "`"$($Path)`""              ## <archive_name>
    )
    & $7z_Application $7z_Arguments 
}

Expand-Archive -Path $retroArchBinary -Destination $retroArchPath


# 5. Prepare cores
$coresPath = $retroArchPath + "\cores\"
$coreZipFile = $requirementsFolder + "\Cores-v1.0.0.2-64-bit.zip" # After all the messing around with JSON its come to this. Time for a beer.
New-Item -ItemType Directory -Force -Path $coresPath
Expand-Archive -Path $coreZipFile -Destination $coresPath

