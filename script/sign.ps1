#!/usr/bin/env pwsh
$ErrorActionPreference = 'Continue'

if (-not $Env:DLIB_PATH) {
  Write-Host "Skipping Windows code signing; DLIB_PATH not set"
  exit 0
}
if (-not $Env:METADATA_PATH) {
  Write-Host "Skipping Windows code signing; METADATA_PATH not set"
  exit 0
}

$signtool = (Resolve-Path 'C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe' | Select-Object -Last 1).Path
Write-Host "Using signtool: $signtool"

$target = $Args[0]
Write-Host "Target file: $target"

tree D:\a\cli\cli\dist /F

$cmd = @(
  'sign','/v','/debug',
  '/d','GitHub CLI',
  '/fd','sha256',
  '/td','sha256',
  '/tr','http://timestamp.acs.microsoft.com',
  '/dlib',"$Env:DLIB_PATH",
  '/dmdf',"$Env:METADATA_PATH",
  $target
)

Write-Host "Running: $signtool $($cmd -join ' ')"

$output = & $signtool @cmd 2>&1
$exit = $LASTEXITCODE

Write-Host '----- signtool combined output begin -----'
$output | ForEach-Object { Write-Host $_ }
Write-Host '----- signtool combined output end -----'

exit $exit
