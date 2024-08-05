Split-Path -Path $PSScriptRoot -Qualifier
$DriverPath = "$(Split-Path -Path $PSScriptRoot -Qualifier)\Drivers\HP_Z2_SFF_G4_Workstation_Win10_x64\e1d68x64.inf_amd64_26255692c8b1c6b6"

$DriverPath|Set-Clipboard

Start-Process -FilePath "devmgmt.msc" -Wait

& "$(Split-Path -Path $PSScriptRoot -Qualifier)\PS_Apps\Run-ClientApp.ps1"

Exit